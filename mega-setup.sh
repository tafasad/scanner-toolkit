#!/bin/bash
# ============================================
# 🛠️ TERMUX MEGA SETUP - Cybersecurity Edition
# Baixa TUDO separado com dependencias
# Nmap + SQLMap + Dirb + WAF + WhatWeb
# Subfinder + HTTPX + Nuclei + ProxyChains
# Burpsuite + Metasploit + Hydra + John
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'

TOTAL=0
SUCCESS=0
FAIL=0

# =============================================
# REGISTRO DE INSTALACAO
# =============================================
install_log() {
    local name=$1
    local status=$2
    TOTAL=$((TOTAL + 1))
    if [ "$status" = "ok" ]; then
        echo -e "  ${GREEN}[✓]${NC} $name"
        SUCCESS=$((SUCCESS + 1))
    else
        echo -e "  ${RED}[✗]${NC} $name"
        FAIL=$((FAIL + 1))
    fi
}

# =============================================
# INSTALAR PACOTE
# =============================================
pkg_install() {
    local pkg=$1
    if pkg list-installed 2>/dev/null | grep -q "^$pkg"; then
        return 0
    fi
    pkg install "$pkg" -y 2>/dev/null
    return $?
}

# =============================================
# INSTALAR PYTHON PACKAGE
# =============================================
pip_install() {
    local pkg=$1
    pip show "$pkg" 2>/dev/null && return 0
    pip install "$pkg" 2>/dev/null
    return $?
}

# =============================================
# INSTALAR GO TOOL
# =============================================
go_install() {
    local repo=$1
    local name=$(basename "$repo")
    if [ -f "$PREFIX/bin/$name" ]; then
        return 0
    fi
    go install -v "$repo@latest" 2>/dev/null
    [ -f ~/go/bin/$name ] && cp ~/go/bin/$name $PREFIX/bin/
    return $?
}

# =============================================
# SECAO 1: DEPENDENCIAS BASE
# =============================================
install_base() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  DEPENDENCIAS BASE${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install git && install_log "Git" ok || install_log "Git" fail
    pkg_install curl && install_log "Curl" ok || install_log "Curl" fail
    pkg_install wget && install_log "Wget" ok || install_log "Wget" fail
    pkg_install python && install_log "Python" ok || install_log "Python" fail
    pkg_install python3 && install_log "Python3" ok || install_log "Python3" fail
    pkg_install golang && install_log "Go" ok || install_log "Go" fail
    pkg_install ruby && install_log "Ruby" ok || install_log "Ruby" fail
    pkg_install perl && install_log "Perl" ok || install_log "Perl" fail
    pkg_install make && install_log "Make" ok || install_log "Make" fail
    pkg_install clang && install_log "Clang" ok || install_log "Clang" fail
    pkg_install nano && install_log "Nano" ok || install_log "Nano" fail
    pkg_install vim && install_log "Vim" ok || install_log "Vim" fail
    pkg_install openssh && install_log "OpenSSH" ok || install_log "OpenSSH" fail
    pkg_install openssl && install_log "OpenSSL" ok || install_log "OpenSSL" fail
    pkg_install libffi && install_log "LibFFI" ok || install_log "LibFFI" fail
    pkg_install libxml2 && install_log "LibXML2" ok || install_log "LibXML2" fail
    pkg_install libxslt && install_log "LibXSLT" ok || install_log "LibXSLT" fail
    pkg_install zlib && install_log "Zlib" ok || install_log "Zlib" fail
    pkg_install bzip2 && install_log "Bzip2" ok || install_log "Bzip2" fail
    pkg_install ncurses && install_log "Ncurses" ok || install_log "Ncurses" fail
    pkg_install libsqlite && install_log "SQLite" ok || install_log "SQLite" fail
    pkg_install readline && install_log "Readline" ok || install_log "Readline" fail
    pkg_install jq && install_log "JQ" ok || install_log "JQ" fail
    pkg_install tree && install_log "Tree" ok || install_log "Tree" fail
    pkg_install htop && install_log "Htop" ok || install_log "Htop" fail
    pkg_install zip && install_log "Zip" ok || install_log "Zip" fail
    pkg_install unzip && install_log "Unzip" ok || install_log "Unzip" fail
    pkg_install tar && install_log "Tar" ok || install_log "Tar" fail
    pkg_install net-tools && install_log "Net-tools" ok || install_log "Net-tools" fail
    pkg_install dnsutils && install_log "DNS Utils" ok || install_log "DNS Utils" fail
    pkg_install traceroute && install_log "Traceroute" ok || install_log "Traceroute" fail
    pkg_install nmap && install_log "Nmap" ok || install_log "Nmap" fail
}

# =============================================
# SECAO 2: SCANNERS DE REDE
# =============================================
install_network_scanners() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  SCANNERS DE REDE${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install nmap && install_log "Nmap" ok || install_log "Nmap" fail
    pkg_install ncat && install_log "Ncat" ok || install_log "Ncat" fail
    pkg_install netcat-openbsd && install_log "Netcat" ok || install_log "Netcat" fail
    pkg_install arp-scan && install_log "ARP Scan" ok || install_log "ARP Scan" fail
    pkg_install arping && install_log "Arping" ok || install_log "Arping" fail
    pkg_install fping && install_log "Fping" ok || install_log "Fping" fail
    pkg_install hping3 && install_log "Hping3" ok || install_log "Hping3" fail
    pkg_install masscan && install_log "Masscan" ok || install_log "Masscan" fail
    pkg_install proxychains-ng && install_log "ProxyChains" ok || install_log "ProxyChains" fail
    pkg_install tcpdump && install_log "TCPDump" ok || install_log "TCPDump" fail
    pkg_install tshark && install_log "Tshark" ok || install_log "Tshark" fail
    pkg_install bettercap && install_log "Bettercap" ok || install_log "Bettercap" fail
    pkg_install ettercap && install_log "Ettercap" ok || install_log "Ettercap" fail
    pkg_install whois && install_log "Whois" ok || install_log "Whois" fail
    pkg_install dnsutils && install_log "DNSUtils" ok || install_log "DNSUtils" fail
    pkg_install bind-utils && install_log "Bind Utils" ok || install_log "Bind Utils" fail
}

# =============================================
# SECAO 3: WEB / HTTP
# =============================================
install_web_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  FERRAMENTAS WEB / HTTP${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install dirb && install_log "Dirb" ok || install_log "Dirb" fail
    pkg_install whatweb && install_log "WhatWeb" ok || install_log "WhatWeb" fail
    pkg_install wafw00f && install_log "WAFW00F" ok || install_log "WAFW00F" fail
    pkg_install nikto && install_log "Nikto" ok || install_log "Nikto" fail
    pkg_install skipfish && install_log "Skipfish" ok || install_log "Skipfish" fail
    pkg_install sqlmap && install_log "SQLMap (pkg)" ok || install_log "SQLMap (pkg)" fail
    pkg_install dirbuster && install_log "DirBuster" ok || install_log "DirBuster" fail
    pkg_install gobuster && install_log "Gobuster" ok || install_log "Gobuster" fail
    pkg_install ffuf && install_log "FFuF" ok || install_log "FFuF" fail
    pkg_install wfuzz && install_log "WFuzz" ok || install_log "WFuzz" fail
    pkg_install commix && install_log "Commix" ok || install_log "Commix" fail
    pkg_install curl && install_log "Curl" ok || install_log "Curl" fail
    pkg_install httpie && install_log "HTTPie" ok || install_log "HTTPie" fail
    pkg_install aria2 && install_log "Aria2" ok || install_log "Aria2" fail
}

# =============================================
# SECAO 4: PYTHON TOOLS
# =============================================
install_python_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  FERRAMENTAS PYTHON${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pip_install sqlmap && install_log "SQLMap" ok || install_log "SQLMap" fail
    pip_install wafw00f && install_log "WAFW00F" ok || install_log "WAFW00F" fail
    pip_install requests && install_log "Requests" ok || install_log "Requests" fail
    pip_install beautifulsoup4 && install_log "BeautifulSoup4" ok || install_log "BeautifulSoup4" fail
    pip_install scapy && install_log "Scapy" ok || install_log "Scapy" fail
    pip_install impacket && install_log "Impacket" ok || install_log "Impacket" fail
    pip_install pwntools && install_log "Pwntools" ok || install_log "Pwntools" fail
    pip_install python-nmap && install_log "Python-Nmap" ok || install_log "Python-Nmap" fail
    pip_install python-masscan && install_log "Python-Masscan" ok || install_log "Python-Masscan" fail
    pip_install dnspython && install_log "DNSPython" ok || install_log "DNSPython" fail
    pip_install paramiko && install_log "Paramiko (SSH)" ok || install_log "Paramiko" fail
    pip_install selenium && install_log "Selenium" ok || install_log "Selenium" fail
    pip_install mechanize && install_log "Mechanize" ok || install_log "Mechanize" fail
    pip_install netaddr && install_log "NetAddr" ok || install_log "NetAddr" fail
    pip_install python-whois && install_log "Python-Whois" ok || install_log "Python-Whois" fail
    pip_install shodan && install_log "Shodan" ok || install_log "Shodan" fail
    pip_install censys && install_log "Censys" ok || install_log "Censys" fail
    pip_install python-dotenv && install_log "Python-Dotenv" ok || install_log "Python-Dotenv" fail
    pip_install colorama && install_log "Colorama" ok || install_log "Colorama" fail
    pip_install pycryptodome && install_log "PyCryptodome" ok || install_log "PyCryptodome" fail
    pip_install hashcat && install_log "Hashcat (py)" ok || install_log "Hashcat (py)" fail
    pip_install pyjwt && install_log "PyJWT" ok || install_log "PyJWT" fail
    pip_install python-ldap && install_log "Python-LDAP" ok || install_log "Python-LDAP" fail
    pip_install pysmb && install_log "PySMB" ok || install_log "PySMB" fail
    pip_install pycurl && install_log "PyCurl" ok || install_log "PyCurl" fail
    pip_install aiohttp && install_log "AioHTTP" ok || install_log "AioHTTP" fail
    pip_install tornado && install_log "Tornado" ok || install_log "Tornado" fail
    pip_install flask && install_log "Flask" ok || install_log "Flask" fail
    pip_install django && install_log "Django" ok || install_log "Django" fail
}

# =============================================
# SECAO 5: GO TOOLS
# =============================================
install_go_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  FERRAMENTAS GO (ProjectDiscovery)${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    go_install github.com/projectdiscovery/subfinder/v2/cmd/subfinder && install_log "Subfinder" ok || install_log "Subfinder" fail
    go_install github.com/projectdiscovery/httpx/cmd/httpx && install_log "HTTPX" ok || install_log "HTTPX" fail
    go_install github.com/projectdiscovery/nuclei/v3/cmd/nuclei && install_log "Nuclei" ok || install_log "Nuclei" fail
    go_install github.com/projectdiscovery/naabu/v2/cmd/naabu && install_log "Naabu" ok || install_log "Naabu" fail
    go_install github.com/projectdiscovery/tlsx/cmd/tlsx && install_log "TLSX" ok || install_log "TLSX" fail
    go_install github.com/projectdiscovery/dnsx/cmd/dnsx && install_log "DNSX" ok || install_log "DNSX" fail
    go_install github.com/projectdiscovery/shuffledns/cmd/shuffledns && install_log "ShuffleDNS" ok || install_log "ShuffleDNS" fail
    go_install github.com/projectdiscovery/asnmap/cmd/asnmap && install_log "ASNMap" ok || install_log "ASNMap" fail
    go_install github.com/projectdiscovery/cdncheck/cmd/cdncheck && install_log "CDNCheck" ok || install_log "CDNCheck" fail
    go_install github.com/projectdiscovery/clistats/cmd/clistats && install_log "CLIStats" ok || install_log "CLIStats" fail
    go_install github.com/projectdiscovery/proxify/cmd/proxify && install_log "Proxify" ok || install_log "Proxify" fail
    go_install github.com/projectdiscovery/rpc/cmd/rpc && install_log "RPC" ok || install_log "RPC" fail
    go_install github.com/projectdiscovery/interactsh/cmd/interactsh-client && install_log "Interactsh" ok || install_log "Interactsh" fail
    go_install github.com/projectdiscovery/katana/cmd/katana && install_log "Katana" ok || install_log "Katana" fail
    go_install github.com/projectdiscovery/pdtm/cmd/pdtm && install_log "PDTM" ok || install_log "PDTM" fail

    # Atualizar templates do nuclei
    if command -v nuclei &>/dev/null; then
        echo ""
        echo -e "${YELLOW}[...] Atualizando Nuclei templates...${NC}"
        nuclei -update-templates 2>/dev/null
    fi
}

# =============================================
# SECAO 6: BRUTEFORCE / EXPLOIT
# =============================================
install_exploit_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  BRUTEFORCE / EXPLOIT${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install hydra && install_log "Hydra" ok || install_log "Hydra" fail
    pkg_install john && install_log "John the Ripper" ok || install_log "John the Ripper" fail
    pkg_install hashcat && install_log "Hashcat" ok || install_log "Hashcat" fail
    pkg_install medusa && install_log "Medusa" ok || install_log "Medusa" fail
    pkg_install ncrack && install_log "Ncrack" ok || install_log "Ncrack" fail
    pkg_install ophcrack && install_log "Ophcrack" ok || install_log "Ophcrack" fail
    pkg_install aircrack-ng && install_log "Aircrack-NG" ok || install_log "Aircrack-NG" fail
    pkg_install reaver && install_log "Reaver" ok || install_log "Reaver" fail
    pkg_install pixiewps && install_log "PixieWPS" ok || install_log "PixieWPS" fail
    pkg_install mdk4 && install_log "MDK4" ok || install_log "MDK4" fail
    pkg_install metasploit-framework && install_log "Metasploit" ok || install_log "Metasploit" fail
    pkg_install exploitdb && install_log "ExploitDB (searchsploit)" ok || install_log "ExploitDB" fail
    pkg_install beef-xss && install_log "BeEF XSS" ok || install_log "BeEF XSS" fail
    pkg_install bettercap && install_log "Bettercap" ok || install_log "Bettercap" fail
    pkg_install ettercap-text-only && install_log "Ettercap" ok || install_log "Ettercap" fail
    pkg_install yersinia && install_log "Yersinia" ok || install_log "Yersinia" fail
    pkg_install responder && install_log "Responder" ok || install_log "Responder" fail
    pkg_install netdiscover && install_log "NetDiscover" ok || install_log "NetDiscover" fail
    pkg_install onesixtyone && install_log "OneSixtyOne" ok || install_log "OneSixtyOne" fail
    pkg_install snmpwalk && install_log "SNMPWalk" ok || install_log "SNMPWalk" fail
}

# =============================================
# SECAO 7: SNIFFING / MITM
# =============================================
install_sniffing_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  SNIFFING / MITM${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install tcpdump && install_log "TCPDump" ok || install_log "TCPDump" fail
    pkg_install tshark && install_log "Tshark" ok || install_log "Tshark" fail
    pkg_install bettercap && install_log "Bettercap" ok || install_log "Bettercap" fail
    pkg_install ettercap && install_log "Ettercap" ok || install_log "Ettercap" fail
    pkg_install mitmproxy && install_log "MITMProxy" ok || install_log "MITMProxy" fail
    pkg_install driftnet && install_log "Driftnet" ok || install_log "Driftnet" fail
    pkg_install dsniff && install_log "DSniff" ok || install_log "DSniff" fail
    pkg_install urlsnarf && install_log "URLSnarf" ok || install_log "URLSnarf" fail
    pkg_install mailsnarf && install_log "MailSnarf" ok || install_log "MailSnarf" fail

    pip_install mitmproxy && install_log "MITMProxy (pip)" ok || install_log "MITMProxy (pip)" fail
    pip_install scapy && install_log "Scapy" ok || install_log "Scapy" fail
}

# =============================================
# SECAO 8: UTILITARIOS
# =============================================
install_utilities() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  UTILITARIOS${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install nano && install_log "Nano" ok || install_log "Nano" fail
    pkg_install vim && install_log "Vim" ok || install_log "Vim" fail
    pkg_install htop && install_log "Htop" ok || install_log "Htop" fail
    pkg_install tree && install_log "Tree" ok || install_log "Tree" fail
    pkg_install jq && install_log "JQ" ok || install_log "JQ" fail
    pkg_install httpie && install_log "HTTPie" ok || install_log "HTTPie" fail
    pkg_install bat && install_log "Bat" ok || install_log "Bat" fail
    pkg_install exa && install_log "Exa" ok || install_log "Exa" fail
    pkg_install fd && install_log "FD" ok || install_log "FD" fail
    pkg_install ripgrep && install_log "Ripgrep" ok || install_log "Ripgrep" fail
    pkg_install fzf && install_log "FZF" ok || install_log "FZF" fail
    pkg_install tmux && install_log "Tmux" ok || install_log "Tmux" fail
    pkg_install screen && install_log "Screen" ok || install_log "Screen" fail
    pkg_install neofetch && install_log "Neofetch" ok || install_log "Neofetch" fail
    pkg_install cowsay && install_log "Cowsay" ok || install_log "Cowsay" fail
    pkg_install figlet && install_log "Figlet" ok || install_log "Figlet" fail
    pkg_install toilet && install_log "Toilet" ok || install_log "Toilet" fail
    pkg_install lolcat && install_log "Lolcat" ok || install_log "Lolcat" fail
    pkg_install cmatrix && install_log "CMatrix" ok || install_log "CMatrix" fail
    pkg_install sl && install_log "SL (train)" ok || install_log "SL" fail
}

# =============================================
# SECAO 9: PROXY / VPN / ANONIMATO
# =============================================
install_proxy_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  PROXY / VPN / ANONIMATO${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install proxychains-ng && install_log "ProxyChains" ok || install_log "ProxyChains" fail
    pkg_install tor && install_log "Tor" ok || install_log "Tor" fail
    pkg_install torsocks && install_log "Torsocks" ok || install_log "Torsocks" fail
    pkg_install openvpn && install_log "OpenVPN" ok || install_log "OpenVPN" fail
    pkg_install wireguard-tools && install_log "WireGuard" ok || install_log "WireGuard" fail
    pkg_install sshuttle && install_log "SSHuttle" ok || install_log "SSHuttle" fail
    pkg_install socat && install_log "Socat" ok || install_log "Socat" fail
    pkg_install redsocks && install_log "Redsocks" ok || install_log "Redsocks" fail
    pkg_install privoxy && install_log "Privoxy" ok || install_log "Privoxy" fail
    pkg_install polipo && install_log "Polipo" ok || install_log "Polipo" fail
}

# =============================================
# SECAO 10: CRIPTOGRAFIA / HASH
# =============================================
install_crypto_tools() {
    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  CRIPTOGRAFIA / HASH${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    pkg_install openssl && install_log "OpenSSL" ok || install_log "OpenSSL" fail
    pkg_install hashcat && install_log "Hashcat" ok || install_log "Hashcat" fail
    pkg_install john && install_log "John the Ripper" ok || install_log "John the Ripper" fail
    pkg_install ophcrack && install_log "Ophcrack" ok || install_log "Ophcrack" fail
    pkg_install cryptsetup && install_log "Cryptsetup" ok || install_log "Cryptsetup" fail
    pkg_install veracrypt && install_log "VeraCrypt" ok || install_log "VeraCrypt" fail
    pkg_install gnupg && install_log "GnuPG" ok || install_log "GnuPG" fail
    pkg_install ccrypt && install_log "CCrypt" ok || install_log "CCrypt" fail
    pkg_install encfs && install_log "EncFS" ok || install_log "EncFS" fail
    pkg_install steghide && install_log "Steghide" ok || install_log "Steghide" fail
    pkg_install binwalk && install_log "Binwalk" ok || install_log "Binwalk" fail
    pkg_install foremost && install_log "Foremost" ok || install_log "Foremost" fail
    pkg_install testdisk && install_log "TestDisk" ok || install_log "TestDisk" fail
    pkg_install exiftool && install_log "ExifTool" ok || install_log "ExifTool" fail
    pkg_install zsteg && install_log "Zsteg" ok || install_log "Zsteg" fail
    pkg_install stegsolve && install_log "StegSolve" ok || install_log "StegSolve" fail
}

# =============================================
# MENU PRINCIPAL
# =============================================
while true; do
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║     🛠️ TERMUX MEGA SETUP - CYBERSECURITY        ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}O QUE QUER INSTALAR?${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} 📦 Dependencias Base (git, python, go, etc)"
    echo -e "  ${GREEN}2)${NC} 🔍 Scanners de Rede (nmap, masscan, etc)"
    echo -e "  ${GREEN}3)${NC} 🌐 Ferramentas Web (dirb, whatweb, sqlmap, etc)"
    echo -e "  ${GREEN}4)${NC} 🐍 Ferramentas Python (scapy, impacket, pwntools, etc)"
    echo -e "  ${GREEN}5)${NC} 🔧 Ferramentas Go (subfinder, httpx, nuclei, etc)"
    echo -e "  ${GREEN}6)${NC} 💥 Bruteforce / Exploit (hydra, john, metasploit, etc)"
    echo -e "  ${GREEN}7)${NC} 📡 Sniffing / MITM (tcpdump, bettercap, etc)"
    echo -e "  ${GREEN}8)${NC} 🛠️ Utilitarios (htop, vim, jq, etc)"
    echo -e "  ${GREEN}9)${NC} 🔒 Proxy / VPN / Anonimato (tor, proxychains, etc)"
    echo -e "  ${GREEN}10)${NC} 🔐 Criptografia / Hash (hashcat, john, steghide, etc)"
    echo ""
    echo -e "  ${YELLOW}0)${NC} 🚀 INSTALAR TUDO (todas as secoes)"
    echo ""
    echo -e "  ${RED}q)${NC} Sair"
    echo ""
    echo -n "Escolha: "
    read SECAO

    case $SECAO in
        1) install_base ;;
        2) install_network_scanners ;;
        3) install_web_tools ;;
        4) install_python_tools ;;
        5) install_go_tools ;;
        6) install_exploit_tools ;;
        7) install_sniffing_tools ;;
        8) install_utilities ;;
        9) install_proxy_tools ;;
        10) install_crypto_tools ;;
        0)
            install_base
            install_network_scanners
            install_web_tools
            install_python_tools
            install_go_tools
            install_exploit_tools
            install_sniffing_tools
            install_utilities
            install_proxy_tools
            install_crypto_tools
            ;;
        q) echo "Saindo..."; exit 0 ;;
        *) echo "Invalida!" ;;
    esac

    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  INSTALADO: $SUCCESS/$TOTAL${NC}"
    [ $FAIL -gt 0 ] && echo -e "${RED}  FALHAS: $FAIL${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo -e "${YELLOW}Enter para continuar...${NC}"
    read
done
