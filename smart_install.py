#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Plaka Tanıma Sistemi - Akıllı Kurulum
Tüm gereksinimleri kontrol eder, eksikleri indirir ve kurar
"""

import os
import sys
import subprocess
import platform
import winreg
import urllib.request
import json
from pathlib import Path
import shutil
import time

class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    END = '\033[0m'
    BOLD = '\033[1m'

class SmartInstaller:
    def __init__(self):
        self.log_file = Path("kurulum_log.txt")
        self.errors = []
        self.warnings = []
        self.fixes_applied = []
        
    def log(self, message, level="INFO"):
        """Log mesajlarını hem ekrana hem dosyaya yaz"""
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        log_msg = f"[{timestamp}] [{level}] {message}"
        
        with open(self.log_file, "a", encoding="utf-8") as f:
            f.write(log_msg + "\n")
        
        if level == "ERROR":
            print(f"{Colors.RED}[X] {message}{Colors.END}")
        elif level == "WARNING":
            print(f"{Colors.YELLOW}[!] {message}{Colors.END}")
        elif level == "SUCCESS":
            print(f"{Colors.GREEN}[OK] {message}{Colors.END}")
        elif level == "FIX":
            print(f"{Colors.BLUE}[FIX] {message}{Colors.END}")
        else:
            print(f"[i] {message}")
    
    def check_admin(self):
        """Yönetici yetkisi kontrolü"""
        try:
            return os.getuid() == 0
        except AttributeError:
            import ctypes
            return ctypes.windll.shell32.IsUserAnAdmin() != 0
    
    def run_command(self, cmd, shell=True, check=False):
        """Komut çalıştır ve sonucu döndür"""
        try:
            result = subprocess.run(
                cmd,
                shell=shell,
                capture_output=True,
                text=True,
                timeout=300
            )
            return result.returncode == 0, result.stdout, result.stderr
        except Exception as e:
            return False, "", str(e)
    
    def find_in_path(self, executable):
        """PATH'de executable bul"""
        return shutil.which(executable) is not None
    
    def find_in_registry(self, key_path, value_name=""):
        """Windows Registry'de ara"""
        try:
            key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path)
            value, _ = winreg.QueryValueEx(key, value_name)
            winreg.CloseKey(key)
            return value
        except:
            return None
    
    def add_to_path(self, path):
        """PATH'e kalıcı olarak ekle"""
        try:
            # Kullanıcı PATH'i için
            key = winreg.OpenKey(
                winreg.HKEY_CURRENT_USER,
                "Environment",
                0,
                winreg.KEY_READ | winreg.KEY_WRITE
            )
            current_path, _ = winreg.QueryValueEx(key, "Path")
            
            if path not in current_path:
                new_path = current_path + ";" + path
                winreg.SetValueEx(key, "Path", 0, winreg.REG_EXPAND_SZ, new_path)
                self.log(f"PATH'e eklendi: {path}", "FIX")
                self.fixes_applied.append(f"PATH: {path}")
            
            winreg.CloseKey(key)
            return True
        except Exception as e:
            self.log(f"PATH eklenirken hata: {e}", "ERROR")
            return False
    
    def check_python(self):
        """Python kontrolü ve düzeltme"""
        self.log("\n=== Python Kontrolü ===")
        
        if not self.find_in_path("python"):
            self.log("Python PATH'de bulunamadı", "ERROR")
            self.errors.append("Python PATH'de değil")
            
            # Python'u bul
            python_paths = [
                r"C:\Python39",
                r"C:\Python310",
                r"C:\Python311",
                r"C:\Python312",
                r"C:\Users\{}\AppData\Local\Programs\Python".format(os.getlogin())
            ]
            
            for path in python_paths:
                if Path(path).exists():
                    self.log(f"Python bulundu: {path}", "FIX")
                    self.add_to_path(path)
                    self.add_to_path(str(Path(path) / "Scripts"))
                    return True
            
            self.log("Python yüklü değil. Lütfen yükleyin:", "ERROR")
            self.log("https://www.python.org/downloads/", "ERROR")
            return False
        
        # Python versiyonu kontrol
        success, stdout, _ = self.run_command("python --version")
        if success:
            version = stdout.strip()
            self.log(f"Python bulundu: {version}", "SUCCESS")
            return True
        
        return False
    
    def check_nodejs(self):
        """Node.js kontrolü"""
        self.log("\n=== Node.js Kontrolü ===")
        
        if not self.find_in_path("node"):
            self.log("Node.js PATH'de bulunamadı", "ERROR")
            
            # Node.js'i bul
            nodejs_path = r"C:\Program Files\nodejs"
            if Path(nodejs_path).exists():
                self.log(f"Node.js bulundu: {nodejs_path}", "FIX")
                self.add_to_path(nodejs_path)
                return True
            
            self.log("Node.js yüklü değil. Lütfen yükleyin:", "ERROR")
            self.log("https://nodejs.org/", "ERROR")
            self.errors.append("Node.js yüklü değil")
            return False
        
        success, stdout, _ = self.run_command("node --version")
        if success:
            version = stdout.strip()
            self.log(f"Node.js bulundu: {version}", "SUCCESS")
            return True
        
        return False
    
    def check_mongodb(self):
        """MongoDB kontrolü ve düzeltme"""
        self.log("\n=== MongoDB Kontrolü ===")
        
        if not self.find_in_path("mongod"):
            self.log("MongoDB PATH'de bulunamadı, aranıyor...", "WARNING")
            
            # MongoDB'yi bul
            mongodb_paths = [
                r"C:\Program Files\MongoDB\Server\7.0\bin",
                r"C:\Program Files\MongoDB\Server\6.0\bin",
                r"C:\Program Files\MongoDB\Server\5.0\bin",
            ]
            
            found = False
            for path in mongodb_paths:
                if Path(path).exists():
                    self.log(f"MongoDB bulundu: {path}", "FIX")
                    self.add_to_path(path)
                    found = True
                    break
            
            if not found:
                self.log("MongoDB yüklü değil", "ERROR")
                self.log("https://www.mongodb.com/try/download/community", "ERROR")
                self.errors.append("MongoDB yüklü değil")
                return False
        
        # MongoDB versiyonu kontrol
        success, stdout, _ = self.run_command("mongod --version")
        if success:
            self.log("MongoDB bulundu ve çalışıyor", "SUCCESS")
            
            # MongoDB servisini başlat
            self.log("MongoDB servisi kontrol ediliyor...", "INFO")
            success, _, _ = self.run_command("net start MongoDB")
            if success:
                self.log("MongoDB servisi başlatıldı", "FIX")
            else:
                self.log("MongoDB servisi zaten çalışıyor veya manuel başlatılmalı", "WARNING")
            
            return True
        
        return False
    
    def check_tesseract(self):
        """Tesseract OCR kontrolü ve düzeltme"""
        self.log("\n=== Tesseract OCR Kontrolü ===")
        
        if not self.find_in_path("tesseract"):
            self.log("Tesseract PATH'de bulunamadı, aranıyor...", "WARNING")
            
            # Tesseract'ı bul
            tesseract_paths = [
                r"C:\Program Files\Tesseract-OCR",
                r"C:\Program Files (x86)\Tesseract-OCR",
                r"C:\Tesseract-OCR",
            ]
            
            found = False
            for path in tesseract_paths:
                if Path(path).exists():
                    self.log(f"Tesseract bulundu: {path}", "FIX")
                    self.add_to_path(path)
                    found = True
                    break
            
            if not found:
                self.log("Tesseract yüklü değil", "ERROR")
                self.log("https://github.com/UB-Mannheim/tesseract/wiki", "ERROR")
                self.errors.append("Tesseract yüklü değil")
                return False
        
        # Tesseract versiyonu kontrol
        success, stdout, _ = self.run_command("tesseract --version")
        if success:
            self.log("Tesseract OCR bulundu", "SUCCESS")
            
            # Türkçe dil paketi kontrolü
            if "tur" in stdout.lower() or Path(r"C:\Program Files\Tesseract-OCR\tessdata\tur.traineddata").exists():
                self.log("Türkçe dil paketi mevcut", "SUCCESS")
            else:
                self.log("Türkçe dil paketi eksik olabilir", "WARNING")
                self.warnings.append("Tesseract Türkçe dil paketi")
            
            return True
        
        return False
    
    def setup_backend(self):
        """Backend kurulumu"""
        self.log("\n=== Backend Kurulumu ===")
        
        backend_path = Path("backend")
        if not backend_path.exists():
            self.log("backend klasörü bulunamadı!", "ERROR")
            self.errors.append("backend klasörü yok")
            return False
        
        requirements_file = backend_path / "requirements.txt"
        if not requirements_file.exists():
            self.log("requirements.txt bulunamadı!", "ERROR")
            self.errors.append("requirements.txt yok")
            return False
        
        # Virtual environment oluştur
        venv_path = backend_path / "venv"
        if not venv_path.exists():
            self.log("Virtual environment oluşturuluyor...", "INFO")
            success, _, stderr = self.run_command(f"python -m venv {venv_path}")
            if not success:
                self.log(f"Virtual environment oluşturulamadı: {stderr}", "ERROR")
                self.errors.append("Virtual environment hatası")
                return False
            self.log("Virtual environment oluşturuldu", "FIX")
        
        # Pip'i güncelle
        pip_path = venv_path / "Scripts" / "pip.exe"
        self.log("pip güncelleniyor...", "INFO")
        self.run_command(f"{pip_path} install --upgrade pip")
        
        # Requirements'ı kur
        self.log("Python paketleri kuruluyor (bu biraz zaman alabilir)...", "INFO")
        success, stdout, stderr = self.run_command(
            f"{pip_path} install -r {requirements_file}"
        )
        
        if not success:
            self.log(f"Paket kurulumunda hata: {stderr}", "ERROR")
            self.errors.append("Backend paket kurulum hatası")
            return False
        
        self.log("Backend paketleri kuruldu", "SUCCESS")
        return True
    
    def setup_frontend(self):
        """Frontend kurulumu"""
        self.log("\n=== Frontend Kurulumu ===")
        
        frontend_path = Path("frontend")
        if not frontend_path.exists():
            self.log("frontend klasörü bulunamadı!", "ERROR")
            self.errors.append("frontend klasörü yok")
            return False
        
        package_json = frontend_path / "package.json"
        if not package_json.exists():
            self.log("package.json bulunamadı!", "ERROR")
            self.errors.append("package.json yok")
            return False
        
        os.chdir(frontend_path)
        
        # node_modules varsa temizle
        node_modules = Path("node_modules")
        if node_modules.exists():
            self.log("Eski node_modules temizleniyor...", "INFO")
            import shutil
            shutil.rmtree(node_modules, ignore_errors=True)
        
        # npm cache temizle
        self.log("npm cache temizleniyor...", "INFO")
        self.run_command("npm cache clean --force")
        
        # npm install
        self.log("Node paketleri kuruluyor (bu biraz zaman alabilir)...", "INFO")
        
        # İlk önce legacy-peer-deps ile kur (daha güvenli)
        success, stdout, stderr = self.run_command("npm install --legacy-peer-deps")
        
        if not success:
            self.log(f"npm install hatası: {stderr}", "ERROR")
            os.chdir("..")
            self.errors.append("Frontend paket kurulum hatası")
            return False
        
        # ajv kontrolü
        ajv_path = Path("node_modules/ajv")
        if not ajv_path.exists():
            self.log("ajv paketi eksik, yeniden kuruluyor...", "FIX")
            self.run_command("npm install ajv@8 --legacy-peer-deps")
        
        os.chdir("..")
        self.log("Frontend paketleri kuruldu", "SUCCESS")
        return True
    
    def setup_env_files(self):
        """Environment dosyalarını ayarla"""
        self.log("\n=== Ortam Değişkenleri Ayarlanıyor ===")
        
        # Backend .env
        backend_env = Path("backend/.env")
        if not backend_env.exists():
            self.log("backend/.env oluşturuluyor...", "FIX")
            with open(backend_env, "w", encoding="utf-8") as f:
                f.write("MONGO_URL=mongodb://localhost:27017\n")
                f.write("DB_NAME=plaka_tanima_db\n")
                f.write("CORS_ORIGINS=http://localhost:3000\n")
            self.log("backend/.env oluşturuldu", "SUCCESS")
        else:
            self.log("backend/.env mevcut", "SUCCESS")
        
        # Frontend .env
        frontend_env = Path("frontend/.env")
        if not frontend_env.exists():
            self.log("frontend/.env oluşturuluyor...", "FIX")
            with open(frontend_env, "w", encoding="utf-8") as f:
                f.write("REACT_APP_BACKEND_URL=http://localhost:8001\n")
            self.log("frontend/.env oluşturuldu", "SUCCESS")
        else:
            self.log("frontend/.env mevcut", "SUCCESS")
        
        return True
    
    def create_start_script(self):
        """Başlatma scripti oluştur"""
        self.log("\n=== Başlatma Scripti Oluşturuluyor ===")
        
        start_script = Path("BASLA.bat")
        with open(start_script, "w", encoding="utf-8") as f:
            f.write("@echo off\n")
            f.write("echo Plaka Tanima Sistemi Baslatiliyor...\n")
            f.write("echo.\n\n")
            
            f.write(":: Backend\n")
            f.write("cd backend\n")
            f.write('start "Backend" cmd /k "venv\\Scripts\\python.exe server.py"\n')
            f.write("cd ..\n\n")
            
            f.write("timeout /t 5\n\n")
            
            f.write(":: Frontend\n")
            f.write("cd frontend\n")
            f.write('start "Frontend" cmd /k "npm start"\n')
            f.write("cd ..\n\n")
            
            f.write("timeout /t 5\n")
            f.write("start http://localhost:3000\n")
            f.write("echo Sistem baslatildi!\n")
            f.write("pause\n")
        
        self.log("BASLA.bat oluşturuldu", "SUCCESS")
        return True
    
    def print_summary(self):
        """Kurulum özeti"""
        print("\n" + "="*60)
        print(f"{Colors.BOLD}KURULUM ÖZETI{Colors.END}")
        print("="*60)
        
        if self.fixes_applied:
            print(f"\n{Colors.BLUE}Uygulanan Düzeltmeler:{Colors.END}")
            for fix in self.fixes_applied:
                print(f"  - {fix}")
        
        if self.warnings:
            print(f"\n{Colors.YELLOW}Uyarılar:{Colors.END}")
            for warning in self.warnings:
                print(f"  - {warning}")
        
        if self.errors:
            print(f"\n{Colors.RED}Hatalar:{Colors.END}")
            for error in self.errors:
                print(f"  - {error}")
            print(f"\n{Colors.RED}Kurulum tamamlanamadı! Lütfen hataları düzeltin.{Colors.END}")
        else:
            print(f"\n{Colors.GREEN}Kurulum başarıyla tamamlandı!{Colors.END}")
            print(f"\nSistemi başlatmak için: {Colors.BOLD}BASLA.bat{Colors.END}")
        
        print(f"\nDetaylı log: {self.log_file}")
        print("="*60)
    
    def run(self):
        """Ana kurulum işlemi"""
        print(f"{Colors.BOLD}")
        print("="*60)
        print("  PLAKA TANIMA SİSTEMİ - AKILLI KURULUM")
        print("  Evo Teknoloji")
        print("="*60)
        print(f"{Colors.END}\n")
        
        self.log("Kurulum başlatıldı", "INFO")
        
        # Gereksinimler kontrolü
        python_ok = self.check_python()
        nodejs_ok = self.check_nodejs()
        mongodb_ok = self.check_mongodb()
        tesseract_ok = self.check_tesseract()
        
        if not python_ok or not nodejs_ok:
            self.log("\nKritik bileşenler eksik! Kurulum durduruluyor.", "ERROR")
            self.print_summary()
            return False
        
        # MongoDB ve Tesseract opsiyonel uyarılar
        if not mongodb_ok:
            self.warnings.append("MongoDB kurulmamış - sistem çalışmayabilir")
        if not tesseract_ok:
            self.warnings.append("Tesseract kurulmamış - plaka okuma çalışmayacak")
        
        # Backend kurulum
        if not self.setup_backend():
            self.print_summary()
            return False
        
        # Frontend kurulum
        if not self.setup_frontend():
            self.print_summary()
            return False
        
        # Environment dosyaları
        self.setup_env_files()
        
        # Başlatma scripti
        self.create_start_script()
        
        self.log("\nKurulum tamamlandı!", "SUCCESS")
        self.print_summary()
        
        return True

if __name__ == "__main__":
    try:
        installer = SmartInstaller()
        success = installer.run()
        
        if success:
            input("\nDevam etmek için Enter'a basın...")
        else:
            input("\nHataları düzeltip tekrar deneyin. Enter'a basın...")
            sys.exit(1)
    
    except KeyboardInterrupt:
        print("\n\nKurulum iptal edildi.")
        sys.exit(1)
    except Exception as e:
        print(f"\n{Colors.RED}Beklenmeyen hata: {e}{Colors.END}")
        sys.exit(1)
