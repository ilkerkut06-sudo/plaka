╔════════════════════════════════════════════════════════════════════════╗
║                    PLAKA OKUMA SİSTEMİ v1.0                            ║
║                  License Plate Recognition System                      ║
╚════════════════════════════════════════════════════════════════════════╝

                        📖 DOSYA REHBERİ 📖


═══════════════════════════════════════════════════════════════════════
🚀 BAŞLATMA DOSYALARI
═══════════════════════════════════════════════════════════════════════

📄 HIZLI_BASLAT.bat (ÖNERİLEN - İLK BAŞLAYIN!)
   └─ Menülü başlatma aracı
   └─ Backend, Frontend veya her ikisini başlatın
   └─ Test ve sorun giderme araçlarına erişim

📄 START_ALL.bat
   └─ Her şeyi tek seferde başlatır
   └─ MongoDB + Backend + Frontend
   └─ İlk kurulum için kullanın

📄 SETUP_AND_START.bat
   └─ Tam kurulum ve başlatma
   └─ İlk kez çalıştırıyorsanız bunu kullanın
   └─ Tüm gereksinimleri yükler ve sistemi başlatır


═══════════════════════════════════════════════════════════════════════
🧪 TEST ARAÇLARI
═══════════════════════════════════════════════════════════════════════

📄 TEST_BACKEND.bat
   └─ Backend'i test eder
   └─ Python, MongoDB, dependencies kontrolü
   └─ Backend'i manuel başlatır

📄 TEST_FRONTEND.bat
   └─ Frontend'i test eder
   └─ Node.js, NPM, node_modules kontrolü

📄 SORUN_GIDER.bat
   └─ Tüm sistemi kontrol eder
   └─ Eksik bileşenleri tespit eder
   └─ Sorunları otomatik olarak raporlar


═══════════════════════════════════════════════════════════════════════
📚 DOKÜMANTASYON
═══════════════════════════════════════════════════════════════════════

📄 BASLANGIC_REHBERI.txt (YENİ BAŞLAYANLAR İÇİN!)
   └─ Adım adım kurulum rehberi
   └─ İlk çalıştırma talimatları
   └─ Yaygın sorunlar ve çözümleri

📄 NASIL_KULLANILIR.txt
   └─ Detaylı kullanım kılavuzu
   └─ Tüm özellikler
   └─ Sorun giderme bölümü

📄 PORT_DEGISTIRME_REHBERI.txt
   └─ Backend/Frontend port ayarları
   └─ Adım adım port değiştirme

📄 HIZLI_AYARLAR.txt
   └─ Hızlı başvuru rehberi
   └─ Tüm ayarlar bir arada
   └─ Komutlar ve kısayollar


═══════════════════════════════════════════════════════════════════════
📁 KLASÖR YAPISI
═══════════════════════════════════════════════════════════════════════

plaka-main/
│
├─ backend/                    # Backend (Python/FastAPI)
│  ├─ venv/                   # Python virtual environment
│  ├─ server.py               # Ana backend dosyası
│  ├─ requirements.txt        # Python bağımlılıkları
│  ├─ .env                    # Backend ayarları (PORT, MONGO_URL)
│  └─ START_BACKEND.bat       # Backend başlatma scripti
│
├─ frontend/                   # Frontend (React)
│  ├─ src/                    # React kaynak kodları
│  ├─ public/                 # Statik dosyalar
│  ├─ node_modules/           # Node.js bağımlılıkları
│  ├─ package.json            # Node.js bağımlılık listesi
│  ├─ .env                    # Frontend ayarları (BACKEND_URL)
│  └─ START_FRONTEND.bat      # Frontend başlatma scripti
│
└─ [Yukarıdaki .bat ve .txt dosyaları]


═══════════════════════════════════════════════════════════════════════
🎯 HIZLI BAŞLANGIÇ
═══════════════════════════════════════════════════════════════════════

İlk Kez Kullanıyorsanız:
─────────────────────────
  1. BASLANGIC_REHBERI.txt dosyasını okuyun
  2. SORUN_GIDER.bat dosyasını çalıştırarak sistemi kontrol edin
  3. SETUP_AND_START.bat dosyasını çalıştırın
  4. Tarayıcıda http://localhost:3000 açın

İkinci Kez ve Sonrası:
─────────────────────────
  1. HIZLI_BASLAT.bat dosyasını çalıştırın
  2. Menüden "1" seçin (Her şeyi başlat)
  3. Tarayıcıda http://localhost:3000 açın


═══════════════════════════════════════════════════════════════════════
⚙️ AYARLAR
═══════════════════════════════════════════════════════════════════════

Backend Ayarları (backend\.env):
────────────────────────────────
  PORT=8001                              # Backend portu
  MONGO_URL="mongodb://localhost:27017"  # MongoDB bağlantısı
  DB_NAME="test_database"                # Veritabanı adı
  CORS_ORIGINS="*"                       # CORS ayarı

Frontend Ayarları (frontend\.env):
─────────────────────────────────
  REACT_APP_BACKEND_URL=http://localhost:8001  # Backend adresi
  WDS_SOCKET_PORT=0                            # Dev server portu


═══════════════════════════════════════════════════════════════════════
🔧 SORUN GİDERME
═══════════════════════════════════════════════════════════════════════

Backend çalışmıyor:
  → TEST_BACKEND.bat çalıştırın
  → Hata mesajlarını okuyun
  → MongoDB'nin çalıştığından emin olun

Frontend çalışmıyor:
  → TEST_FRONTEND.bat çalıştırın
  → Node.js'in kurulu olduğunu kontrol edin
  → node_modules klasörünün var olduğunu kontrol edin

Port değiştirmek istiyorsanız:
  → PORT_DEGISTIRME_REHBERI.txt dosyasına bakın

Genel sorunlar:
  → SORUN_GIDER.bat çalıştırın
  → NASIL_KULLANILIR.txt dosyasını okuyun
  → BASLANGIC_REHBERI.txt dosyasındaki sorun giderme bölümüne bakın


═══════════════════════════════════════════════════════════════════════
📞 SİSTEM GEREKSİNİMLERİ
═══════════════════════════════════════════════════════════════════════

Yazılım:
  ✓ Python 3.8+
  ✓ Node.js 14+
  ✓ MongoDB 4.4+

Donanım (Önerilen):
  ✓ CPU: 4 çekirdek veya üzeri
  ✓ RAM: 8 GB veya üzeri
  ✓ Disk: 5 GB boş alan
  ✓ Webcam (plaka tanıma için)


═══════════════════════════════════════════════════════════════════════
🌟 ÖZELLİKLER
═══════════════════════════════════════════════════════════════════════

  ✓ Gerçek zamanlı plaka tanıma (YOLOv8 + Tesseract OCR)
  ✓ 4 kameraya kadar destek (2x2 grid)
  ✓ Site ve blok yönetimi
  ✓ Araç plakası kayıt sistemi
  ✓ İzinli/Yasaklı plaka kontrolü
  ✓ Renkli uyarı sistemi (Yeşil/Sarı/Kırmızı)
  ✓ NodeMCU kapı kontrolü (gelecekte)
  ✓ Raporlama ve log sistemi
  ✓ Sistem durumu izleme (CPU, RAM)


═══════════════════════════════════════════════════════════════════════
📝 SÜRÜM BİLGİLERİ
═══════════════════════════════════════════════════════════════════════

Versiyon: 1.0
Tarih: Kasım 2024
Backend: Python 3.10, FastAPI, Motor, OpenCV, YOLOv8, Tesseract
Frontend: React 18, TailwindCSS, Axios
Veritabanı: MongoDB


═══════════════════════════════════════════════════════════════════════

İyi kullanımlar! 🚀

Herhangi bir sorun yaşarsanız, BASLANGIC_REHBERI.txt veya 
NASIL_KULLANILIR.txt dosyalarına başvurabilirsiniz.

═══════════════════════════════════════════════════════════════════════
