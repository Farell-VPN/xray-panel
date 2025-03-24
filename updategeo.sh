#!/bin/bash

# Fungsi untuk meminta konfirmasi dari pengguna
ask_confirmation() {
    while true; do
        read -p "Apakah Anda ingin update geo? (y/n): " confirm
        case "$confirm" in
            [yY])
                return 0
                ;;
            [nN])
                return 1
                ;;
            *)
                echo "Input tidak valid. Harap masukkan y atau n."
                ;;
        esac
    done
}

# Meminta konfirmasi dari pengguna
if ! ask_confirmation; then
    echo "Update geo dibatalkan."
    exit 0
fi

# Mengambil tag rilis terbaru dari repositori
latest=$(curl -s https://api.github.com/repos/Loyalsoldier/v2ray-rules-dat/releases/latest | grep tag_name | cut -d '"' -f 4)

# Mengecek apakah tag rilis terbaru berhasil diambil
if [ -z "$latest" ]; then
    echo "Gagal mengambil tag rilis terbaru"
    exit 1
fi

# Mengunduh file dan menyimpannya dengan nama yang ditentukan

cd /var/lib/marzban/assets
wget -O geoip.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${latest}/GeoIP.dat
wget -O geosite.dat https://github.com/Loyalsoldier/v2ray-rules-dat/releases/download/${latest}/GeoSite.dat
chmod +x /var/lib/marzban/assets/*
cd

# Mengecek apakah unduhan berhasil
if [ $? -eq 0 ]; then
    profile
    echo "Berhasil Update Geo"
else
    echo "Gagal Update Geo"
fi
