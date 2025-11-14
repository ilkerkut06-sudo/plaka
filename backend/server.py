from fastapi import FastAPI, APIRouter, WebSocket, WebSocketDisconnect, HTTPException, UploadFile, File
from fastapi.responses import StreamingResponse
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timezone
import asyncio
import json
import psutil
import cv2
import numpy as np
from collections import deque
import requests
import base64

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Create the main app
app = FastAPI()
api_router = APIRouter(prefix="/api")

# ==================== MODELS ====================

class Site(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    blocks: List[Dict[str, Any]]  # [{name: "A Blok", apartments: 20}]
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

class SiteCreate(BaseModel):
    name: str
    blocks: List[Dict[str, Any]]

class Plate(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    site_id: str
    block_name: str
    apartment_number: str
    owner_name: str
    plates: List[str]  # Up to 3 plates
    valid_until: str
    status: str  # "allowed", "blocked"
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

class PlateCreate(BaseModel):
    site_id: str
    block_name: str
    apartment_number: str
    owner_name: str
    plates: List[str]
    valid_until: str
    status: str

class Door(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    ip: str
    endpoint: str  # /kapiac, /kapiac1, etc
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

class DoorCreate(BaseModel):
    name: str
    ip: str
    endpoint: str

class Camera(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    type: str  # "webcam", "rtsp", "http"
    url: str
    door_id: str
    fps: int = 15
    enabled: bool = True
    position: int = 0  # 0-3 for grid position
    created_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

class CameraCreate(BaseModel):
    name: str
    type: str
    url: str
    door_id: str
    fps: int = 15
    position: int = 0

class Detection(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    camera_id: str
    plate: str
    status: str  # "allowed", "unknown", "blocked"
    confidence: float
    timestamp: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())
    image_base64: Optional[str] = None
    owner_info: Optional[Dict[str, Any]] = None

class Settings(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = "system_settings"
    engine: str = "yolov8_tesseract"  # "yolov8_tesseract" or "yolov8_openalpr"
    compute_mode: str = "auto"  # "cpu", "gpu", "auto"
    camera_size: str = "medium"  # "small", "medium", "large"
    detection_confidence: float = 0.5
    updated_at: str = Field(default_factory=lambda: datetime.now(timezone.utc).isoformat())

class SettingsUpdate(BaseModel):
    engine: Optional[str] = None
    compute_mode: Optional[str] = None
    camera_size: Optional[str] = None
    detection_confidence: Optional[float] = None

# ==================== GLOBAL STATE ====================

active_cameras: Dict[str, Any] = {}
websocket_clients: List[WebSocket] = []
detection_buffer = deque(maxlen=20)

# ==================== PLATE RECOGNITION ENGINE ====================

class PlateRecognitionEngine:
    def __init__(self):
        self.current_engine = "yolov8_tesseract"
        self.compute_mode = "cpu"
        # Placeholder for actual models
        self.initialized = False
    
    def set_engine(self, engine: str):
        self.current_engine = engine
    
    def set_compute_mode(self, mode: str):
        self.compute_mode = mode
    
    async def detect_plate(self, frame: np.ndarray) -> Optional[Dict[str, Any]]:
        """Mock detection for demo - returns sample plate"""
        # In production, this would use YOLOv8 + OCR
        # For now, return mock data occasionally
        import random
        if random.random() > 0.95:  # 5% chance to detect
            sample_plates = ["34ABC123", "06DEF456", "41GHI789", "35JKL012"]
            return {
                "plate": random.choice(sample_plates),
                "confidence": random.uniform(0.7, 0.95),
                "bbox": [100, 100, 200, 150]
            }
        return None

plate_engine = PlateRecognitionEngine()

# ==================== CAMERA PROCESSING ====================

async def process_camera_stream(camera_id: str, camera_data: Dict[str, Any]):
    """Process camera stream and detect plates"""
    camera_url = camera_data["url"]
    camera_type = camera_data["type"]
    fps = camera_data.get("fps", 15)
    
    # Try to open real camera
    cap = None
    frame_count = 0
    is_demo_mode = False
    
    try:
        if camera_type == "webcam":
            # Try to parse as int for webcam index
            try:
                cam_index = int(camera_url)
                cap = cv2.VideoCapture(cam_index)
            except:
                cap = cv2.VideoCapture(camera_url)
        elif camera_type in ["rtsp", "http"]:
            cap = cv2.VideoCapture(camera_url)
        
        if cap and cap.isOpened():
            logger.info(f"Camera {camera_id} connected successfully")
        else:
            logger.warning(f"Camera {camera_id} connection failed, using demo mode")
            is_demo_mode = True
            if cap:
                cap.release()
            cap = None
    except Exception as e:
        logger.error(f"Camera {camera_id} error during initialization: {e}")
        is_demo_mode = True
        cap = None
    
    while camera_id in active_cameras:
        try:
            # Try to read from real camera
            if cap and cap.isOpened():
                ret, frame = cap.read()
                if not ret:
                    logger.error(f"Camera {camera_id} failed to read frame, switching to demo mode")
                    is_demo_mode = True
                    cap.release()
                    cap = None
            
            # Demo mode fallback
            if is_demo_mode or cap is None:
                frame = np.zeros((480, 640, 3), dtype=np.uint8)
                color = (
                    hash(camera_id) % 100 + 50,
                    (hash(camera_id) * 2) % 100 + 50,
                    (hash(camera_id) * 3) % 100 + 50
                )
                frame[:] = color
                cv2.putText(frame, f"DEMO MODE - {camera_data['name']}", (10, 30),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
                cv2.putText(frame, f"Camera not accessible", (10, 60),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.5, (255, 255, 255), 1)
                cv2.putText(frame, f"URL: {camera_url}", (10, 90),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.4, (200, 200, 200), 1)
            
            # Resize frame if needed
            if frame is not None and frame.shape[0] > 0:
                frame = cv2.resize(frame, (640, 480))
            
            # Attempt plate detection
            detection_result = await plate_engine.detect_plate(frame)
            
            if detection_result:
                plate_text = detection_result["plate"]
                confidence = detection_result["confidence"]
                
                # Check if plate is registered
                plate_record = await db.plates.find_one({
                    "plates": plate_text
                }, {"_id": 0})
                
                status = "unknown"
                owner_info = None
                
                if plate_record:
                    if plate_record["status"] == "blocked":
                        status = "blocked"
                    else:
                        status = "allowed"
                        # Trigger door opening
                        camera_info = await db.cameras.find_one({"id": camera_id}, {"_id": 0})
                        if camera_info:
                            door_info = await db.doors.find_one({"id": camera_info["door_id"]}, {"_id": 0})
                            if door_info:
                                try:
                                    requests.get(f"http://{door_info['ip']}{door_info['endpoint']}", timeout=2)
                                except:
                                    pass
                    
                    owner_info = {
                        "owner_name": plate_record["owner_name"],
                        "apartment": f"{plate_record['block_name']} - {plate_record['apartment_number']}"
                    }
                
                # Draw detection on frame
                bbox = detection_result["bbox"]
                color_map = {"allowed": (0, 255, 0), "blocked": (0, 0, 255), "unknown": (0, 255, 255)}
                cv2.rectangle(frame, (bbox[0], bbox[1]), (bbox[2], bbox[3]), color_map[status], 3)
                cv2.putText(frame, plate_text, (bbox[0], bbox[1] - 10),
                           cv2.FONT_HERSHEY_SIMPLEX, 0.9, color_map[status], 2)
                
                # Save detection
                _, buffer = cv2.imencode('.jpg', frame)
                img_base64 = base64.b64encode(buffer).decode('utf-8')
                
                detection = Detection(
                    camera_id=camera_id,
                    plate=plate_text,
                    status=status,
                    confidence=confidence,
                    image_base64=img_base64,
                    owner_info=owner_info
                )
                
                await db.detections.insert_one(detection.model_dump())
                detection_buffer.append(detection.model_dump())
                
                # Broadcast to websocket clients
                for ws_client in websocket_clients:
                    try:
                        await ws_client.send_json({
                            "type": "detection",
                            "data": detection.model_dump()
                        })
                    except:
                        pass
            
            # Store latest frame
            _, buffer = cv2.imencode('.jpg', frame, [cv2.IMWRITE_JPEG_QUALITY, 60])
            active_cameras[camera_id]["latest_frame"] = buffer.tobytes()
            active_cameras[camera_id]["status"] = status if detection_result else "monitoring"
            
            frame_count += 1
            await asyncio.sleep(1.0 / fps)
            
        except Exception as e:
            logger.error(f"Camera {camera_id} error: {e}")
            await asyncio.sleep(1)

# ==================== API ROUTES ====================

@api_router.get("/")
async def root():
    return {"message": "Evo Teknoloji Plaka Tanıma Sistemi API"}

# Sites
@api_router.post("/sites", response_model=Site)
async def create_site(site: SiteCreate):
    site_obj = Site(**site.model_dump())
    await db.sites.insert_one(site_obj.model_dump())
    return site_obj

@api_router.get("/sites", response_model=List[Site])
async def get_sites():
    sites = await db.sites.find({}, {"_id": 0}).to_list(1000)
    return sites

@api_router.put("/sites/{site_id}", response_model=Site)
async def update_site(site_id: str, site: SiteCreate):
    site_obj = Site(id=site_id, **site.model_dump())
    await db.sites.update_one({"id": site_id}, {"$set": site_obj.model_dump()})
    return site_obj

@api_router.delete("/sites/{site_id}")
async def delete_site(site_id: str):
    await db.sites.delete_one({"id": site_id})
    return {"message": "Site deleted"}

# Plates
@api_router.post("/plates", response_model=Plate)
async def create_plate(plate: PlateCreate):
    plate_obj = Plate(**plate.model_dump())
    await db.plates.insert_one(plate_obj.model_dump())
    return plate_obj

@api_router.get("/plates", response_model=List[Plate])
async def get_plates(site_id: Optional[str] = None, block_name: Optional[str] = None, status: Optional[str] = None):
    query = {}
    if site_id:
        query["site_id"] = site_id
    if block_name:
        query["block_name"] = block_name
    if status:
        query["status"] = status
    plates = await db.plates.find(query, {"_id": 0}).to_list(1000)
    return plates

@api_router.put("/plates/{plate_id}", response_model=Plate)
async def update_plate(plate_id: str, plate: PlateCreate):
    plate_obj = Plate(id=plate_id, **plate.model_dump())
    await db.plates.update_one({"id": plate_id}, {"$set": plate_obj.model_dump()})
    return plate_obj

@api_router.delete("/plates/{plate_id}")
async def delete_plate(plate_id: str):
    await db.plates.delete_one({"id": plate_id})
    return {"message": "Plate deleted"}

# Doors
@api_router.post("/doors", response_model=Door)
async def create_door(door: DoorCreate):
    door_obj = Door(**door.model_dump())
    await db.doors.insert_one(door_obj.model_dump())
    return door_obj

@api_router.get("/doors", response_model=List[Door])
async def get_doors():
    doors = await db.doors.find({}, {"_id": 0}).to_list(1000)
    return doors

@api_router.put("/doors/{door_id}", response_model=Door)
async def update_door(door_id: str, door: DoorCreate):
    door_obj = Door(id=door_id, **door.model_dump())
    await db.doors.update_one({"id": door_id}, {"$set": door_obj.model_dump()})
    return door_obj

@api_router.delete("/doors/{door_id}")
async def delete_door(door_id: str):
    await db.doors.delete_one({"id": door_id})
    return {"message": "Door deleted"}

@api_router.post("/doors/{door_id}/open")
async def open_door(door_id: str):
    door = await db.doors.find_one({"id": door_id}, {"_id": 0})
    if not door:
        raise HTTPException(status_code=404, detail="Door not found")
    try:
        response = requests.get(f"http://{door['ip']}{door['endpoint']}", timeout=3)
        return {"success": True, "message": "Door opened"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to open door: {str(e)}")

# Cameras
@api_router.post("/cameras", response_model=Camera)
async def create_camera(camera: CameraCreate):
    camera_obj = Camera(**camera.model_dump())
    await db.cameras.insert_one(camera_obj.model_dump())
    return camera_obj

@api_router.get("/cameras", response_model=List[Camera])
async def get_cameras():
    cameras = await db.cameras.find({}, {"_id": 0}).to_list(1000)
    return cameras

@api_router.put("/cameras/{camera_id}", response_model=Camera)
async def update_camera(camera_id: str, camera: CameraCreate):
    camera_obj = Camera(id=camera_id, **camera.model_dump())
    await db.cameras.update_one({"id": camera_id}, {"$set": camera_obj.model_dump()})
    return camera_obj

@api_router.delete("/cameras/{camera_id}")
async def delete_camera(camera_id: str):
    # Stop camera if active
    if camera_id in active_cameras:
        del active_cameras[camera_id]
    await db.cameras.delete_one({"id": camera_id})
    return {"message": "Camera deleted"}

@api_router.post("/cameras/{camera_id}/start")
async def start_camera(camera_id: str):
    camera = await db.cameras.find_one({"id": camera_id}, {"_id": 0})
    if not camera:
        raise HTTPException(status_code=404, detail="Camera not found")
    
    if camera_id in active_cameras:
        return {"message": "Camera already running"}
    
    active_cameras[camera_id] = {
        "name": camera["name"],
        "type": camera["type"],
        "url": camera["url"],
        "fps": camera.get("fps", 15),
        "latest_frame": None,
        "status": "starting"
    }
    
    asyncio.create_task(process_camera_stream(camera_id, active_cameras[camera_id]))
    return {"message": "Camera started"}

@api_router.post("/cameras/{camera_id}/stop")
async def stop_camera(camera_id: str):
    if camera_id in active_cameras:
        del active_cameras[camera_id]
    return {"message": "Camera stopped"}

@api_router.get("/cameras/{camera_id}/stream")
async def get_camera_stream(camera_id: str):
    if camera_id not in active_cameras:
        raise HTTPException(status_code=404, detail="Camera not active")
    
    def generate():
        while camera_id in active_cameras:
            frame = active_cameras[camera_id].get("latest_frame")
            if frame:
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')
            else:
                import time
                time.sleep(0.1)
    
    return StreamingResponse(generate(), media_type="multipart/x-mixed-replace; boundary=frame")

# Detections
@api_router.get("/detections", response_model=List[Detection])
async def get_detections(start_date: Optional[str] = None, end_date: Optional[str] = None, status: Optional[str] = None):
    query = {}
    if start_date and end_date:
        query["timestamp"] = {"$gte": start_date, "$lte": end_date}
    if status:
        query["status"] = status
    detections = await db.detections.find(query, {"_id": 0}).sort("timestamp", -1).to_list(1000)
    return detections

@api_router.get("/detections/recent")
async def get_recent_detections():
    return list(detection_buffer)

@api_router.get("/detections/stats")
async def get_detection_stats():
    today = datetime.now(timezone.utc).date().isoformat()
    
    total_today = await db.detections.count_documents({
        "timestamp": {"$gte": today}
    })
    
    allowed_today = await db.detections.count_documents({
        "timestamp": {"$gte": today},
        "status": "allowed"
    })
    
    blocked_today = await db.detections.count_documents({
        "timestamp": {"$gte": today},
        "status": "blocked"
    })
    
    unknown_today = await db.detections.count_documents({
        "timestamp": {"$gte": today},
        "status": "unknown"
    })
    
    return {
        "total_today": total_today,
        "allowed_today": allowed_today,
        "blocked_today": blocked_today,
        "unknown_today": unknown_today
    }

# Settings
@api_router.get("/settings", response_model=Settings)
async def get_settings():
    settings = await db.settings.find_one({"id": "system_settings"}, {"_id": 0})
    if not settings:
        settings = Settings().model_dump()
        await db.settings.insert_one(settings)
    return settings

@api_router.put("/settings", response_model=Settings)
async def update_settings(updates: SettingsUpdate):
    current = await db.settings.find_one({"id": "system_settings"}, {"_id": 0})
    if not current:
        current = Settings().model_dump()
    
    update_data = {k: v for k, v in updates.model_dump().items() if v is not None}
    update_data["updated_at"] = datetime.now(timezone.utc).isoformat()
    
    if "engine" in update_data:
        plate_engine.set_engine(update_data["engine"])
    if "compute_mode" in update_data:
        plate_engine.set_compute_mode(update_data["compute_mode"])
    
    await db.settings.update_one(
        {"id": "system_settings"},
        {"$set": update_data},
        upsert=True
    )
    
    updated = await db.settings.find_one({"id": "system_settings"}, {"_id": 0})
    return updated

# System
@api_router.get("/system/status")
async def get_system_status():
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    # Check GPU availability
    gpu_available = False
    gpu_info = "N/A"
    try:
        import torch
        gpu_available = torch.cuda.is_available()
        if gpu_available:
            gpu_info = torch.cuda.get_device_name(0)
    except:
        pass
    
    return {
        "cpu_percent": cpu_percent,
        "memory_percent": memory.percent,
        "memory_used_gb": round(memory.used / (1024**3), 2),
        "memory_total_gb": round(memory.total / (1024**3), 2),
        "gpu_available": gpu_available,
        "gpu_info": gpu_info,
        "active_cameras": len(active_cameras)
    }

# WebSocket
@api_router.websocket("/ws/detections")
async def websocket_detections(websocket: WebSocket):
    await websocket.accept()
    websocket_clients.append(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            # Keep connection alive
    except WebSocketDisconnect:
        websocket_clients.remove(websocket)

# Include router
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.on_event("shutdown")
async def shutdown_db_client():
    client.close()
