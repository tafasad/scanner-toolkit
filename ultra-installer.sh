#!/bin/bash
# ============================================
# 🚀 TERMUX ULTRA INSTALLER - 5 minutos
# Instala TUDO em paralelo, sem perguntar
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'

SUCCESS=0
FAIL=0
TOTAL=0

ok() { echo -e "${GREEN}[✓]${NC} $1"; SUCCESS=$((SUCCESS+1)); TOTAL=$((TOTAL+1)); }
no() { echo -e "${RED}[✗]${NC} $1"; FAIL=$((FAIL+1)); TOTAL=$((TOTAL+1)); }

clear
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║     🚀 TERMUX ULTRA INSTALLER v1                 ║"
echo "║     Instala TUDO em ~5 minutos                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${YELLOW}[1/4] Atualizando pacotes...${NC}"
pkg update -y 2>/dev/null && ok "pkg update" || no "pkg update"

echo ""
echo -e "${YELLOW}[2/4] Instalando pacotes base...${NC}"

# Instalar TUDO em paralelo (muito mais rápido)
(
  pkg install -y git curl wget python python3 golang ruby perl make clang nano vim openssh openssl libffi libxml2 libxslt zlib bzip2 ncurses readline jq tree htop zip unzip tar net-tools dnsutils 2>/dev/null && ok "pacotes-base" || no "pacotes-base"
) &

(
  pkg install -y nmap ncat netcat-openbsd arp-scan fping hping3 masscan proxychains-ng tcpdump tshark bettercap ettercap 2>/dev/null && ok "pacotes-rede" || no "pacotes-rede"
) &

(
  pkg install -y dirb whatweb wafw00f nikto sqlmap gobuster ffuf wfuzz commix httpie 2>/dev/null && ok "pacotes-web" || no "pacotes-web"
) &

(
  pkg install -y hydra john hashcat medusa ncrack aircrack-ng reaver mdk4 metasploit-framework exploitdb beef-xss responder netdiscover onesixtyone snmpwalk 2>/dev/null && ok "pacotes-exploit" || no "pacotes-exploit"
) &

(
  pkg install -y tor torsocks openvpn wireguard-tools sshuttle socat privoxy 2>/dev/null && ok "pacotes-proxy" || no "pacotes-proxy"
) &

(
  pkg install -y openssl gnupg ccrypt encfs steghide binwalk foremost testdisk exiftool 2>/dev/null && ok "pacotes-cripto" || no "pacotes-cripto"
) &

(
  pkg install -y bat exa ripgrep fzf tmux screen neofetch figlet toilet lolcat cmatrix sl 2>/dev/null && ok "pacotes-util" || no "pacotes-util"
) &

# Esperar todos terminarem
wait

echo ""
echo -e "${YELLOW}[3/4] Instalando ferramentas Python...${NC}"

(
  pip install --upgrade pip 2>/dev/null
  pip install sqlmap wafw00f requests beautifulsoup4 scapy impacket pwntools python-nmap dnspython paramiko python-whois shodan colorama pycryptodome hashcat pyjwt aiohttp flask django 2>/dev/null && ok "pip-packages" || no "pip-packages"
) &

echo ""
echo -e "${YELLOW}[4/4] Instalando ferramentas Go...${NC}"

(
  if command -v go &>/dev/null; then
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/proxify/cmd/proxify@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest 2>/dev/null &
    go install -v github.com/projectdiscovery/katana/cmd/katana@latest 2>/dev/null &
    wait
    # Copiar pro PATH
    cp ~/go/bin/* $PREFIX/bin/ 2>/dev/null
    ok "go-tools" 
  else
    no "go-tools (go nao instalado)"
  fi
) &

wait

# Atualizar nuclei templates
if command -v nuclei &>/dev/null; then
  nuclei -update-templates 2>/dev/null &
fi

echo ""
echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}  INSTALACAO COMPLETA!${NC}"
echo -e "${GREEN}  Sucesso: $SUCCESS/$TOTAL${NC}"
[ $FAIL -gt 0 ] && echo -e "${RED}  Falhas: $FAIL${NC}"
echo -e "${GREEN}==========================================${NC}"
echo ""
echo -e "${YELLOW}Verificando ferramentas:${NC}"
echo ""

for tool in nmap sqlmap dirb whatweb wafw00f subfinder httpx nuclei proxychains4 hydra john hashcat metasploit-framework aircrack-ng tor go python3 pip3; do
  if command -v "$tool" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $tool"
  else
    echo -e "  ${RED}✗${NC} $tool"
  fi
done

echo ""
echo -e "${GREEN}Pronto! Tudo instalado!${NC}"
