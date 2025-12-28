#!/data/data/com.termux/files/usr/bin/bash

set -e

clear
echo "======================================"
echo "   Kali Linux Installer for Termux"
echo "======================================"
echo ""
echo "Do you want Kali to start automatically when Termux opens?"
echo "1) Yes (Auto login)"
echo "2) No  (Manual login)"
read -p "Select [1-2]: " AUTO_CHOICE

if [ "$AUTO_CHOICE" = "1" ]; then
  echo "[+] Enabling auto-login..."

  grep -q "Auto start Kali" ~/.bashrc || cat << 'AUTO' >> ~/.bashrc

# Auto start Kali (added by install-kali-termux)
if [ -z "$PROOT_DISTRIBUTION" ]; then
  proot-distro login debian
fi
AUTO

elif [ "$AUTO_CHOICE" = "2" ]; then
  echo "[+] Manual login selected."
else
  echo "[!] Invalid choice, continuing without auto-login."
fi

echo ""
echo "[+] Updating Termux..."
pkg update -y && pkg upgrade -y
pkg install -y proot-distro wget gnupg curl dialog

echo "[+] Installing Debian rootfs..."
proot-distro install debian

echo "[+] Entering Debian..."
proot-distro login debian -- bash << 'EOF'

set -e

echo "[+] Base system setup..."
apt update -y
apt install -y wget gnupg zsh curl ca-certificates dialog

echo "[+] Adding Kali archive key..."
wget -qO - https://archive.kali.org/archive-key.asc | gpg --dearmor > /usr/share/keyrings/kali-archive-keyring.gpg

echo "[+] Adding Kali rolling repository..."
echo "deb [signed-by=/usr/share/keyrings/kali-archive-keyring.gpg] http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware" > /etc/apt/sources.list.d/kali.list

apt update -y
apt upgrade -y

# -------- TOOL MENU --------
CHOICE=$(dialog --checklist "Select Kali toolsets to install:" 20 60 10 \
1 "Web tools (kali-tools-web)" off \
2 "Top 10 tools (kali-tools-top10)" off \
3 "Password tools (kali-tools-passwords)" off \
4 "Wireless tools (limited in proot)" off \
5 "Forensics tools" off \
6 "All tools (kali-linux-large)" off \
3>&1 1>&2 2>&3)

clear

for ITEM in $CHOICE; do
  case $ITEM in
    1) apt install -y kali-tools-web ;;
    2) apt install -y kali-tools-top10 ;;
    3) apt install -y kali-tools-passwords ;;
    4) apt install -y kali-tools-wireless ;;
    5) apt install -y kali-tools-forensics ;;
    6) apt install -y kali-linux-large ;;
  esac
done

echo "[+] Installing system info tool..."
apt install -y fastfetch || apt install -y neofetch

echo "[+] Setting zsh as default shell..."
chsh -s /bin/zsh

echo "[+] Configuring Kali-like terminal..."
cat << 'ZSH' >> /root/.zshrc

PROMPT="%F{red}┌──(%F{blue}kali㉿termux%F{red})-[%~]
└─%F{blue}$ %f"

alias ll='ls -lah'
alias update='apt update && apt upgrade -y'

fastfetch 2>/dev/null || neofetch

ZSH

echo "[✓] Kali environment ready!"
EOF

echo ""
echo "======================================"
echo "[✓] INSTALLATION COMPLETE"
echo "======================================"
echo ""
echo "Login command:"
echo "proot-distro login debian"
echo ""
echo "Exit Kali with: exit"
