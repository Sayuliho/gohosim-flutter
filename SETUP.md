# GohoSIM Flutter — Setup Pertama Kali

## ✅ Android Studio sudah terpasang!

---

## Langkah 1 — Cek Flutter doctor

Buka **Terminal** (bisa dari VS Code atau Windows PowerShell), ketik:

```
flutter doctor
```

Yang harus hijau semua:
- ✅ Flutter
- ✅ Android toolchain
- ✅ Android Studio

---

## Langkah 2 — Accept Android licenses

```
flutter doctor --android-licenses
```

Ketik `y` dan Enter untuk semua pertanyaan.

---

## Langkah 3 — Buka project di VS Code

1. Buka VS Code
2. File → Open Folder → pilih folder `gohosim_flutter`
3. VS Code akan detect Flutter project otomatis

---

## Langkah 4 — Install dependencies

Di terminal (di dalam folder `gohosim_flutter`):

```
flutter pub get
```

---

## Langkah 5 — Update Midtrans Client Key

Edit file:
`lib/features/checkout/screens/checkout_screen.dart`

Cari baris:
```
data-client-key="SB-Mid-client-YOUR_CLIENT_KEY"
```

Ganti dengan client key Midtrans SY (sandbox atau production).

---

## Langkah 6 — Jalankan di HP / emulator

### Pakai HP fisik:
1. HP: Pengaturan → Tentang ponsel → ketuk "Nomor build" 7x
2. Aktifkan Developer Options → USB Debugging ON
3. Sambungkan HP ke laptop via USB
4. Di terminal: `flutter devices` (pastikan HP muncul)
5. `flutter run`

### Pakai emulator Android Studio:
1. Buka Android Studio → Device Manager
2. Buat Virtual Device (misalnya Pixel 7, API 33)
3. Start emulator
4. `flutter run`

---

## Struktur aplikasi

```
lib/
├── main.dart                    ← Entry point + router
├── core/
│   ├── api/api_client.dart      ← HTTP ke Worker
│   ├── models/                  ← Data models
│   └── providers/               ← State (Auth, Packages)
├── features/
│   ├── auth/                    ← Login, Register
│   ├── home/                    ← Beranda
│   ├── packages/                ← Pilih negara + paket
│   ├── checkout/                ← Konfirmasi + Midtrans
│   ├── my_esims/                ← Histori eSIM
│   └── profile/                 ← Profil user
└── shared/theme/                ← Warna & tema GohoSIM
```

---

## API Backend

Worker: `https://gohosim.gohotravel.workers.dev`

| Endpoint | Keterangan |
|---|---|
| POST /auth/register | Daftar akun |
| POST /auth/login | Login |
| GET /auth/me | Cek token |
| GET /packages?country=JP | Daftar paket |
| POST /midtrans/snap-token | Buat order + Snap token |
| GET /my-esims | Histori eSIM user |
