# 🤖 Robot Controller App - Scratch Style

Aplikasi Android untuk mengontrol robot ESP32 melalui Bluetooth dengan tampilan bergaya Scratch yang fun dan intuitif!

## ✨ Fitur Utama

### 🎮 Dual Robot Support
- **Robot SUMO** - Fokus: Dorong & Torque
- **Robot SOCCER** - Fokus: Manuver & Tendang

### 📱 Responsive Design
- Landscape mode untuk kontrol optimal
- Mendukung semua ukuran device Android
- Eyes-free operation dengan tombol besar

### 📡 Bluetooth Features
- Auto-connect ke device terakhir
- Filter device berdasarkan nama (SUMO-* atau SOCCER-*)
- Failsafe: Robot otomatis berhenti jika koneksi terputus
- Real-time control data streaming

## 🚀 Instalasi & Setup

### Prerequisites
- Flutter SDK 3.10.4 atau lebih tinggi
- Android SDK
- Device Android dengan Bluetooth

### Install Dependencies
```bash
flutter pub get
```

### Build APK
```bash
flutter build apk --release
```

### Install ke Device
```bash
flutter install
```

## 🎮 Cara Penggunaan

### 1. The Garage (Pilih Robot)
- Buka aplikasi
- Pilih tipe robot: SUMO atau SOCCER
- Klik kartu robot untuk lanjut ke koneksi

### 2. Koneksi Bluetooth
- Aplikasi akan otomatis mencoba koneksi ke device terakhir
- Jika gagal, pilih device dari daftar
- Hanya device dengan nama "SUMO-*" atau "SOCCER-*" yang ditampilkan

### 3. Kontrol Robot
**Sisi Kiri - Joystick:**
- Floating joystick untuk pergerakan
- Muncul di mana saja jari menyentuh
- Koordinat X,Y ditampilkan untuk feedback

**Sisi Kanan - Tombol Aksi:**

*Robot SUMO:*
- **BOOST** - Toggle boost mode
- **SERUDUK** - Aksi seruduk kuat
- **STOP** - Emergency stop

*Robot SOCCER:*
- **TENDANG** - Kick bola
- **DRIBBLE** - Kontrol bola
- **STOP** - Emergency stop

## 📋 Protokol Data

### Control Data (Real-time)
```
C:<x>,<y>\n
Contoh: C:0.75,-0.50\n
```

### Action Data
```
A:<action>\n
Contoh: A:KICK\n
```

### Settings Data (Pro Mode)
```
S:{"pwmMax":255,"frequency":1000,"sensitivity":50}\n
```

## 🔧 Konfigurasi ESP32

### Pin Configuration (Contoh)
```cpp
// Motor pins
#define MOTOR_LEFT_PWM 25
#define MOTOR_LEFT_DIR 26
#define MOTOR_RIGHT_PWM 27
#define MOTOR_RIGHT_DIR 14

// Action pins
#define KICK_PIN 12
#define DRIBBLE_PIN 13
```

### Bluetooth Setup
```cpp
#include <BluetoothSerial.h>

BluetoothSerial SerialBT;

void setup() {
  // Untuk SUMO
  SerialBT.begin("SUMO-01");
  
  // Atau untuk SOCCER
  // SerialBT.begin("SOCCER-01");
}
```

### Data Parsing
```cpp
void loop() {
  if (SerialBT.available()) {
    String data = SerialBT.readStringUntil('\n');
    
    if (data.startsWith("C:")) {
      // Parse control data
      parseControlData(data);
    } 
    else if (data.startsWith("A:")) {
      // Parse action data
      parseActionData(data);
    }
    else if (data.startsWith("S:")) {
      // Parse settings data
      parseSettingsData(data);
    }
  }
}
```

## 📁 Struktur Project

```
lib/
├── main.dart                 # Entry point
├── models/
│   ├── robot_type.dart       # Enum tipe robot
│   ├── control_mode.dart     # Enum mode kontrol
│   └── robot_settings.dart   # Model pengaturan
├── services/
│   └── bluetooth_service.dart # Service bluetooth
├── providers/
│   └── app_provider.dart     # State management
├── theme/
│   └── scratch_theme.dart    # Theme & styling
├── widgets/
│   ├── puzzle_button.dart    # Custom button widget
│   └── robot_card.dart       # Card pemilihan robot
└── pages/
    ├── the_garage_page.dart      # Halaman pilih robot
    ├── bluetooth_connection_page.dart # Halaman koneksi
    ├── control_page.dart         # Halaman kontrol
    └── pro_tuning_page.dart      # Halaman Pro mode
```

## 🎨 Customization

### Mengubah Warna
Edit [lib/theme/scratch_theme.dart](lib/theme/scratch_theme.dart):
```dart
static const Color motionBlue = Color(0xFF4C97FF);
static const Color eventsYellow = Color(0xFFFFAB19);
// ... dst
```

### Menambah Action Button
Edit [lib/pages/control_page.dart](lib/pages/control_page.dart) di method `_buildActionButtons()`.

### Mengubah Protocol
Edit [lib/services/bluetooth_service.dart](lib/services/bluetooth_service.dart) di methods:
- `sendControlData()`
- `sendAction()`
- `sendSettings()`

## 🐛 Troubleshooting

### Bluetooth tidak terdeteksi
- Pastikan Bluetooth aktif di device
- Cek permission di Settings > Apps > Robot Controller
- Pastikan lokasi (GPS) aktif (diperlukan untuk Bluetooth scan)

### Koneksi terputus terus
- Cek jarak antara HP dan ESP32
- Pastikan ESP32 tidak di-reset
- Cek baterai ESP32

### Joystick tidak responsif
- Coba atur sensitivitas di Mode Pro
- Cek koneksi Bluetooth
- Restart aplikasi

## 🛠️ Development

### Hot Reload
```bash
flutter run
```

### Debug Mode
```bash
flutter run --debug
```

### Release Build
```bash
flutter build apk --release --split-per-abi
```
