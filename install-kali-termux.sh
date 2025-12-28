#!/data/data/com.termux/files/usr/bin/bash

clear
echo "========================================"
echo "   Kali Linux Style Installer (Rootless)"
echo "========================================"
echo
echo "Do you want Kali to start automatically when Termux opens?"
echo "1) Yes (Auto login)"
echo "2) No  (Manual login)"
read -p "Select [1-2]: " AUTO_LOGIN

echo
echo "Select Zsh setup:"
echo "1) Basic Zsh"
echo "2) Zsh + Oh My Zsh"
echo "3) Zsh + Oh My Zsh + Plugins (Recommended)"
read -p "Select [1-3]: " ZSH_MODE

echo
echo "[*] Updating system..."
apt update && apt upgrade -y

echo "[*] Installing base packages..."
apt install -y git zsh curl neofetch fastfetch

# ---------------- ZSH ----------------
if [[ "$ZSH_MODE" != "1" ]]; then
  echo "[*] Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ "$ZSH_MODE" == "3" ]]; then
  echo "[*] Installing Zsh plugins..."
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# ---------------- THEME ----------------
echo "[*] Installing Kali-like Zsh theme..."
mkdir -p ~/.oh-my-zsh/custom/themes

cat << 'EOF' > ~/.oh-my-zsh/custom/themes/kali.zsh-theme
PROMPT='%F{blue}┌──(kali㉿termux)-[%F{cyan}%~%F{blue}]
└─$ %f'
EOF

# ---------------- ZSHRC ----------------
echo "[*] Configuring Zsh..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="kali"/' ~/.zshrc 2>/dev/null || echo 'ZSH_THEME="kali"' >> ~/.zshrc

if [[ "$ZSH_MODE" == "3" ]]; then
  sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
else
  sed -i 's/^plugins=.*/plugins=(git)/' ~/.zshrc
fi

# ---------------- AUTO LOGIN ----------------
if [[ "$AUTO_LOGIN" == "1" ]]; then
  echo "[*] Enabling auto start..."
  grep -q "exec zsh" ~/.bashrc || echo "exec zsh" >> ~/.bashrc
fi

echo
echo "========================================"
echo " Installation completed successfully ✔"
echo " Restart Termux to enjoy Kali-style Zsh"
echo "========================================"