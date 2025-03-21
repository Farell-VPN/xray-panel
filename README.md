# Autoscript Panel Marzban  

Proyek ini merupakan modifikasi dari [Marzban](https://github.com/Gozargah/Marzban) dengan tambahan konfigurasi **Nginx** untuk mendukung koneksi **WebSocket**, **HTTP Upgrade**, dan **gRPC single port**.  

> **Disclaimer**  
> Proyek ini hanya untuk pembelajaran dan komunikasi pribadi. Mohon jangan digunakan untuk tujuan ilegal.  
> Semua kredit tetap kepada [Gozargah Marzban](https://github.com/Gozargah), saya hanya menyederhanakan instalasi untuk pemula.  

---

## 📖 Table of Contents
- [📌 Fitur yang Didukung](#-fitur-yang-didukung)
- [🚀 Sistem yang Dapat Digunakan](#-sistem-yang-dapat-digunakan)
- [📌 Persiapan Sebelum Instalasi](#-persiapan-sebelum-instalasi)
- [🛠 Instalasi](#-instalasi)
- [🔄 Manajemen Service Marzban](#-manajemen-service-marzban)
- [🔧 Konfigurasi Cloudflare](#-konfigurasi-cloudflare)
- [💖 Donasi](#-donasi)
- [🎥 Youtube Channel](#-youtube-channel)
- [✉ Telegram Support](#-telegram-support)
- [👥 Contributors](#-contributors)

---

## 📌 **Fitur yang Didukung**
- **Protocol:** VLess, VMess, Trojan  
- **Network:** WebSocket, HTTP Upgrade, gRPC *(unverified)*  
- **Port:**  
  - WebSocket: `443 (TLS)`, `80 (HTTP)`, **Wildcard path** → `/enter-your-custom-path/trojan`  
  - gRPC: `443 (TLS)`

---

## 🚀 **Sistem yang Dapat Digunakan**
| OS           | Status |
|-------------|--------|
| Debian 11   | ✅ **Recommended** |
| Debian 12   | ✅ |
| Ubuntu 20.04 | ✅ |
| Ubuntu 22.04 | ✅ |
| Ubuntu 23.10 | ✅ |
| Ubuntu 24.04 | ✅ |

---

## 📌 **Persiapan Sebelum Instalasi**
- **VPS** dengan minimal **1 Core CPU & 1 GB RAM**  
- **Domain** yang sudah di-pointing ke **Cloudflare**  
- **Pemahaman dasar Linux**  

---

## 🛠 **Instalasi**
1. **Update dan install dependensi**  
   ```sh
   apt-get update && apt install -y curl wget tmux dnsutils
   ```
2. **Jalankan script instalasi**  
   > Pastikan Anda sudah login sebagai `root` sebelum menjalankan perintah berikut:  
   ```sh
   tmux new -s fn "wget https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/install.sh && chmod +x install.sh && ./install.sh"
   ```
3. **Akses panel Marzban**  
   - Buka browser dan kunjungi: `https://domainmu/dashboard`  

4. **Buat Admin Panel**  
   ```sh
   marzban cli admin create --sudo
   ```

5. **Konfigurasi tambahan** *(jika diperlukan)*  
   ```sh
   nano /opt/marzban/.env
   ```

---

## 🔄 **Manajemen Service Marzban**
| Perintah | Fungsi |
|----------|--------|
| `marzban restart` | Restart service Marzban |
| `marzban logs` | Cek log service |
| `marzban update` | Update service |

---

## 🔧 **Konfigurasi Cloudflare**
1. Pastikan **SSL/TLS** di **Cloudflare** diatur menjadi **Full**  
   ![Cloudflare SSL](https://github.com/GawrAme/MarLing/assets/97426017/3aeedf09-308e-41b0-9640-50e4abb77aa0)  
2. Aktifkan **WebSocket** dan **gRPC** di **Cloudflare**  
   ![Cloudflare Network](https://github.com/GawrAme/MarLing/assets/97426017/65d9b413-fda4-478a-99a5-b33d8e5fec3d)

---

## 💖 **Donasi**
- **[QRIS ID](https://t.me/fn_project/245)**

---

## 🎥 **Youtube Channel**
- [FarellVPN](https://youtube.com/@farellvpn)  
- [Rerechan02](https://youtube.com/@Rerechan02) *(Jika 404, kemungkinan suspend)*  

---

## ✉ **Telegram Support**
- [Farell Aditya](https://t.me/farell_aditya_ardian)  
- [Rerechan02](https://t.me/Rerechan02)  
- [Dinda Putri](https://t.me/DindaPutriFN)  
- [FN Project](https://t.me/fn_project)
---

## 👥 **Contributors**
- [Rerechan02](https://github.com/Rerechan02)  
- [DindaPutriFN](https://github.com/DindaPutriFN)  
- [Farell Aditya](https://github.com/farelvpn)  

### **Special Thanks To**
- [Gozargah](https://github.com/Gozargah/Marzban)  
- [hamid-gh98](https://github.com/hamid-gh98)  
- [x0sina](https://github.com/x0sina/marzban-sub)  
- [Marling](https://github.com/GawrAme/MarLing)  
- [MarLum](https://github.com/Farell-VPN/mar-lum)  
