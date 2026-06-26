#!/bin/bash
# ============================================
# 🔍 SCANNER TOOLKIT v1 - Termux Edition
# Nmap + SQLMap + Nikto + Dirb + WhatWeb
# Menu unico para vasculhar alvos
# ============================================

# Cores
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'

# Verificar ferramentas
check_tool() {
    if command -v "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Instalar工具 se necessario
install_tool() {
    local tool=$1
    local pkg=$2
    if ! check_tool "$tool"; then
        echo -e "${YELLOW}[...] Instalando $tool...${NC}"
        pkg install "$pkg" -y 2>/dev/null
    fi
}

# =============================================
# MENU PRINCIPAL
# =============================================
clear
echo -e "${PURPLE}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║        🔍 SCANNER TOOLKIT v1 - Termux            ║"
echo "║        Nmap + SQLMap + Nikto + Dirb + WhatWeb    ║"
echo "╚═══════════════════════════════════════════════════╝"
echo -e "${NC}"

echo ""
echo -e "${WHITE}ESCOLHA O SCANNER:${NC}"
echo ""
echo -e "  ${GREEN}1)${NC} ${CYAN}Nmap${NC} - Portas, servicos, SO"
echo -e "  ${GREEN}2)${NC} ${CYAN}SQLMap${NC} - Injecao SQL"
echo -e "  ${GREEN}3)${NC} ${CYAN}Dirb${NC} - Diretorios e arquivos"
echo -e "  ${GREEN}4)${NC} ${CYAN}WafW00f${NC} - Detectar WAF"
echo -e "  ${GREEN}5)${NC} ${CYAN}WhatWeb${NC} - Tecnologias do site"
echo -e "  ${GREEN}6)${NC} ${CYAN}Subfinder${NC} - Subdominios"
echo -e "  ${GREEN}7)${NC} ${CYAN}OWASP ZAP (CLI)${NC} - Scanner de vulnerabilidades"
echo -e "  ${GREEN}8)${NC} ${CYAN}HTTPX${NC} - Enumeracao HTTP"
echo -e "  ${GREEN}9)${NC} ${CYAN}Nuclei${NC} - Templates de vulnerabilidades"
echo -e "  ${GREEN}0)${NC} ${CYAN}Instalar TODAS as ferramentas${NC}"
echo ""
echo -e "  ${RED}q)${NC} Sair"
echo ""
echo -e "Escolha: ${NC}"
read ESCOLHA

case $ESCOLHA in
    1) nmap_scan ;;
    2) sqlmap_scan ;;
    3) dirb_scan ;;
    4) waf_scan ;;
    5) whatweb_scan ;;
    6) subfinder_scan ;;
    7) zap_scan ;;
    8) httpx_scan ;;
    9) nuclei_scan ;;
    0) install_all ;;
    q) exit 0 ;;
    *) echo "Invalida!"; exit 1 ;;
esac

# =============================================
# NMAP
# =============================================
nmap_scan() {
    install_tool nmap nmap
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           🔍 NMAP SCANNER            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Alvo (IP ou dominio):${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}Tipo de scan:${NC}"
    echo "  1) Scan rapido (top 1000 portas)"
    echo "  2) Scan completo (todas portas)"
    echo "  3) Scan de servicos e SO"
    echo "  4) Scan de vulnerabilidades"
    echo "  5) Scan UDP"
    echo "  6) Scan stealth (SYN)"
    echo "  7) Scan agressivo"
    echo ""
    echo -n "Escolha: "
    read TIPO_NMAP

    OUTPUT="nmap_${ALVO}.txt"

    case $TIPO_NMAP in
        1) nmap -T4 -F "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        2) nmap -p- -T4 "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        3) nmap -sV -sC -O "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        4) nmap --script vuln "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        5) nmap -sU -T4 "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        6) nmap -sS -T4 "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        7) nmap -A -T4 "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
        *) nmap -sV "$ALVO" -oN "$OUTPUT" 2>/dev/null ;;
    esac

    echo ""
    echo -e "${GREEN}[OK] Resultado salvo em: $OUTPUT${NC}"
    echo ""
    cat "$OUTPUT" 2>/dev/null | head -50
    echo ""
    echo -e "${YELLOW}Pressione Enter para continuar...${NC}"
    read
    nmap_scan
}

# =============================================
# SQLMAP
# =============================================
sqlmap_scan() {
    if ! check_tool sqlmap; then
        echo -e "${YELLOW}SQLMap nao instalado. Instalando...${NC}"
        pip install sqlmap 2>/dev/null || {
            echo -e "${RED}[ERRO] Falha ao instalar sqlmap. Instale manualmente:${NC}"
            echo "  pkg install python"
            echo "  pip install sqlmap"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        💉 SQLMAP SCANNER            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}URL do alvo (com parametro):${NC}"
    echo -e "${WHITE}Ex: http://site.com/page?id=1${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}Nivel de teste:${NC}"
    echo "  1) Basico (rapido)"
    echo "  2) Medio"
    echo "  3) Avancado (lento)"
    echo ""
    echo -n "Escolha: "
    read NIVEL

    case $NIVEL in
        1) LEVEL=1; RISK=1 ;;
        2) LEVEL=3; RISK=2 ;;
        3) LEVEL=5; RISK=3 ;;
        *) LEVEL=1; RISK=1 ;;
    esac

    OUTPUT="sqlmap_${ALVO//\//_}.txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando SQLMap (pode demorar)...${NC}"
    echo ""

    sqlmap -u "$ALVO" \
        --level="$LEVEL" --risk="$RISK" \
        --batch --threads=5 \
        --random-agent \
        --output-dir="./sqlmap_output" \
        --tamper=space2comment 2>/dev/null | tee "$OUTPUT"

    echo ""
    echo -e "${GREEN}[OK] Resultado salvo em: $OUTPUT${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Enter para continuar...${NC}"
    read
    sqlmap_scan
}

# =============================================
# DIRB
# =============================================
dirb_scan() {
    if ! check_tool dirb; then
        echo -e "${YELLOW}Dirb nao instalado. Instalando...${NC}"
        pkg install dirb -y 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale manualmente: pkg install dirb${NC}"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         📁 DIRB SCANNER              ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}URL do alvo (com / no final):${NC}"
    echo -e "${WHITE}Ex: http://site.com/${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="dirb_${ALVO//\//_}.txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando Dirb...${NC}"
    echo ""

    dirb "$ALVO" /usr/share/dirb/wordlists/common.txt -o "$OUTPUT" -S -r 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] Resultado salvo em: $OUTPUT${NC}"
    echo ""
    cat "$OUTPUT" | tail -40
    echo ""
    echo -e "${YELLOW}Pressione Enter para continuar...${NC}"
    read
    dirb_scan
}

# =============================================
# WAFW00F
# =============================================
waf_scan() {
    if ! check_tool wafw00f; then
        echo -e "${YELLOW}WAFW00F nao instalado. Instalando...${NC}"
        pip install wafw00f 2>/dev/null || {
            pkg install wafw00f -y 2>/dev/null || {
                echo -e "${RED}[ERRO] Instale manualmente: pip install wafw00f${NC}"
                return
            }
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        🛡️ WAF SCANNER               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio do alvo:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="waf_${ALVO}.txt"

    echo ""
    echo -e "${YELLOW}[...] Detectando WAF...${NC}"
    echo ""

    wafw00f "$ALVO" -o "$OUTPUT" 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] Resultado:${NC}"
    cat "$OUTPUT" 2>/dev/null
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    waf_scan
}

# =============================================
# WHATWEB
# =============================================
whatweb_scan() {
    if ! check_tool whatweb; then
        echo -e "${YELLOW}WhatWeb nao instalado. Instalando...${NC}"
        pkg install whatweb ruby -y 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale manualmente: pkg install whatweb${NC}"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      🌐 WHATWEB SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio do alvo:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="whatweb_${ALVO}.txt"

    echo ""
    echo -e "${YELLOW}[...] Detectando tecnologias...${NC}"
    echo ""

    whatweb "$ALVO" --color=never -a 3 > "$OUTPUT" 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] Tecnologias detectadas:${NC}"
    cat "$OUTPUT" 2>/dev/null
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    whatweb_scan
}

# =============================================
# SUBFINDER
# =============================================
subfinder_scan() {
    if ! check_tool subfinder; then
        echo -e "${YELLOW}Subfinder nao instalado. Instalando...${NC}"
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale manualmente: go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest${NC}"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🔎 SUBFINDER SCANNER            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="subfinder_${ALVO}.txt"

    echo ""
    echo -e "${YELLOW}[...] Encontrando subdominios...${NC}"
    echo ""

    subfinder -d "$ALVO" -o "$OUTPUT" -silent 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] Subdominios encontrados:${NC}"
    cat "$OUTPUT" 2>/dev/null
    echo ""
    echo -e "${CYAN}Total: $(wc -l < "$OUTPUT" 2>/dev/null || echo 0) subdominios${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    subfinder_scan
}

# =============================================
# OWASP ZAP
# =============================================
zap_scan() {
    if ! check_tool zapcli; then
        echo -e "${YELLOW}ZAP nao instalado. Instalando...${NC}"
        pip install python-owasp-zap-v2.4 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale Owasp Zap via apt:${NC}"
            echo "  pkg install owasp-zap"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      ⚡ OWASP ZAP SCANNER           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}URL do alvo:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="zap_${ALVO//\//_}.txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando OWASP ZAP (pode demorar)...${NC}"
    echo ""

    zap-cli quick-scan --self-contained \
        --start-options '-config api.disablekey=true' \
        "$ALVO" 2>/dev/null | tee "$OUTPUT"

    echo ""
    echo -e "${GREEN}[OK] Resultado salvo em: $OUTPUT${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    zap_scan
}

# =============================================
# HTTPX
# =============================================
httpx_scan() {
    if ! check_tool httpx; then
        echo -e "${YELLOW}HTTPX nao instalado. Instalando...${NC}"
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale manualmente:${NC}"
            echo "  go install github.com/projectdiscovery/httpx/cmd/httpx@latest"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        🌍 HTTPX SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio ou lista (arquivo):${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="httpx_resultados.txt"

    echo ""
    echo -e "${YELLOW}[...] Escaneando...${NC}"
    echo ""

    if [ -f "$ALVO" ]; then
        httpx -l "$ALVO" -o "$OUTPUT" -silent -threads 20 2>/dev/null
    else
        httpx -u "$ALVO" -o "$OUTPUT" -silent -threads 20 \
          -status-code -title -tech-detect -content-length 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}[OK] Resultados:${NC}"
    cat "$OUTPUT" 2>/dev/null | head -30
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    httpx_scan
}

# =============================================
# NUCLEI
# =============================================
nuclei_scan() {
    if ! check_tool nuclei; then
        echo -e "${YELLOW}Nuclei nao instalado. Instalando...${NC}"
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null || {
            echo -e "${RED}[ERRO] Instale manualmente:${NC}"
            echo "  go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
            return
        }
    fi

    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       💀 NUCLEI SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio do alvo:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}Nivel de severidade:${NC}"
    echo "  1) Baixo"
    echo "  2) Medio"
    echo "  3) Alto"
    echo "  4) Critico"
    echo "  5) Todos"
    echo ""
    echo -n "Escolha: "
    read SEV

    case $SEV in
        1) SEVERITY="low" ;;
        2) SEVERITY="medium" ;;
        3) SEVERITY="high" ;;
        4) SEVERITY="critical" ;;
        *) SEVERITY="low,medium,high,critical" ;;
    esac

    OUTPUT="nuclei_${ALVO}.txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando Nuclei (pode demorar)...${NC}"
    echo ""

    nuclei -u "$ALVO" -s "$SEVERITY" -o "$OUTPUT" -silent -threads 20 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] Vulnerabilidades encontradas:${NC}"
    cat "$OUTPUT" 2>/dev/null
    echo ""
    echo -e "${CYAN}Total: $(wc -l < "$OUTPUT" 2>/dev/null || echo 0) achados${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    nuclei_scan
}

# =============================================
# INSTALAR TODAS
# =============================================
install_all() {
    echo ""
    echo -e "${CYAN}Instalando todas as ferramentas...${NC}"
    echo ""
    pkg install nmap dirb whatweb wafw00f ruby -y 2>/dev/null
    pip install sqlmap wafw00f python-owasp-zap-v2.4 2>/dev/null
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null
    go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null
    go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null
    nuclei -update-templates 2>/dev/null
    echo ""
    echo -e "${GREEN}[OK] Todas as ferramentas instaladas!${NC}"
    echo ""
    echo -e "${YELLOW}Pressione Enter...${NC}"
    read
    clear
    bash "$0"
}

# =============================================
# MENU
# =============================================
until [ "$ESCOLHA" = "q" ]; do
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║        🔍 SCANNER TOOLKIT v1 - Termux            ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}ESCOLHA O SCANNER:${NC}"
    echo ""
    echo -e "  ${GREEN}1)${NC} Nmap        - Portas, servicos, SO"
    echo -e "  ${GREEN}2)${NC} SQLMap       - Injecao SQL"
    echo -e "  ${GREEN}3)${NC} Dirb         - Diretorios"
    echo -e "  ${GREEN}4)${NC} WAFW00F      - Detectar WAF"
    echo -e "  ${GREEN}5)${NC} WhatWeb      - Tecnologias"
    echo -e "  ${GREEN}6)${NC} Subfinder    - Subdominios"
    echo -e "  ${GREEN}7)${NC} OWASP ZAP    - Vulnerabilidades"
    echo -e "  ${GREEN}8)${NC} HTTPX        - Enumeracao HTTP"
    echo -e "  ${GREEN}9)${NC} Nuclei       - Vulns templates"
    echo -e "  ${GREEN}0)${NC} Instalar TUDO"
    echo ""
    echo -e "  ${RED}q)${NC} Sair"
    echo ""
    echo -n "Escolha: "
    read ESCOLHA

    case $ESCOLHA in
        1) nmap_scan ;;
        2) sqlmap_scan ;;
        3) dirb_scan ;;
        4) waf_scan ;;
        5) whatweb_scan ;;
        6) subfinder_scan ;;
        7) zap_scan ;;
        8) httpx_scan ;;
        9) nuclei_scan ;;
        0) install_all ;;
        q) echo "Saindo..."; exit 0 ;;
        *) echo "Invalida!" ;;
    esac
done
