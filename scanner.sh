#!/bin/bash
# ============================================
# 🔍 SCANNER TOOLKIT v2 - COMPLETO
# Instalacao + Configuracao + Menu
# Nmap + SQLMap + Dirb + WAF + WhatWeb
# Subfinder + HTTPX + Nuclei + ProxyChains
# ============================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; WHITE='\033[1;37m'; NC='\033[0m'

# =============================================
# INSTALACAO COMPLETA (so roda uma vez)
# =============================================
install_all() {
    echo ""
    echo -e "${CYAN}==========================================${NC}"
    echo -e "${CYAN}  INSTALANDO TODAS AS FERRAMENTAS${NC}"
    echo -e "${CYAN}==========================================${NC}"
    echo ""

    echo -e "[1/5] Pacotes basicos..."
    pkg update -y 2>/dev/null
    pkg install -y nmap dirb whatweb ruby python git curl wget libidn libffi libyaml 2>/dev/null

    echo -e "[2/5] Ferramentas Python..."
    pip install --upgrade pip 2>/dev/null
    pip install sqlmap wafw00f python-owasp-zap-v2.4 2>/dev/null

    echo -e "[3/5] Go (se necessario)..."
    if ! command -v go &>/dev/null; then
        pkg install -y golang 2>/dev/null
    fi

    echo -e "[4/5] Ferramentas Go..."
    if command -v go &>/dev/null; then
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null &
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest 2>/dev/null &
        go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest 2>/dev/null &
        wait
        # Mover pro PATH
        ls ~/go/bin/ 2>/dev/null | while read f; do
            cp ~/go/bin/$f $PREFIX/bin/ 2>/dev/null
        done
    fi

    echo -e "[5/5] ProxyChains..."
    pkg install -y proxychains-ng 2>/dev/null

    # Configurar proxychains
    cat > $PREFIX/etc/proxychains.conf << 'EOF'
# ProxyChains Configuration
strict_chain
proxy_dns
tcp_read_time_out 30000
tcp_connect_time_out 8000

[ProxyList]
# Adicione seus proxies aqui:
# socks5  127.0.0.1 1080
# http    127.0.0.1 8080
# socks4  127.0.0.1 9050
EOF

    # Atualizar templates do nuclei
    if command -v nuclei &>/dev/null; then
        nuclei -update-templates 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  INSTALACAO COMPLETA!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo -e "${YELLOW}Ferramentas instaladas:${NC}"
    echo ""
    check_tool nmap && echo -e "  ${GREEN}✓${NC} Nmap" || echo -e "  ${RED}✗${NC} Nmap"
    check_tool dirb && echo -e "  ${GREEN}✓${NC} Dirb" || echo -e "  ${RED}✗${NC} Dirb"
    check_tool whatweb && echo -e "  ${GREEN}✓${NC} WhatWeb" || echo -e "  ${RED}✗${NC} WhatWeb"
    check_tool sqlmap && echo -e "  ${GREEN}✓${NC} SQLMap" || echo -e "  ${RED}✗${NC} SQLMap"
    check_tool subfinder && echo -e "  ${GREEN}✓${NC} Subfinder" || echo -e "  ${RED}✗${NC} Subfinder"
    check_tool httpx && echo -e "  ${GREEN}✓${NC} HTTPX" || echo -e "  ${RED}✗${NC} HTTPX"
    check_tool nuclei && echo -e "  ${GREEN}✓${NC} Nuclei" || echo -e "  ${RED}✗${NC} Nuclei"
    check_tool wafw00f && echo -e "  ${GREEN}✓${NC} WAFW00F" || echo -e "  ${RED}✗${NC} WAFW00F"
    check_tool proxychains4 && echo -e "  ${GREEN}✓${NC} ProxyChains" || echo -e "  ${RED}✗${NC} ProxyChains"
    check_tool go && echo -e "  ${GREEN}✓${NC} Go" || echo -e "  ${RED}✗${NC} Go"
    check_tool pip3 && echo -e "  ${GREEN}✓${NC} Python PIP" || echo -e "  ${RED}✗${NC} Python PIP"
    echo ""
}

# =============================================
# VERIFICAR FERRAMENTA
# =============================================
check_tool() {
    command -v "$1" &>/dev/null
}

# =============================================
# SCAN UNICO - TUDO JUNTO
# =============================================
full_scan() {
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     🚀 SCAN COMPLETO (TUDO)         ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio/IP do alvo:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    DOMINIO=$(echo "$ALVO" | sed 's|https\?://||;s|/||')
    PASTA="scan_${DOMINIO}_$(date +%Y%m%d_%H%M)"
    mkdir -p "$PASTA"

    echo ""
    echo -e "${PURPLE}==========================================${NC}"
    echo -e "${PURPLE}  ESCANEANDO: $ALVO${NC}"
    echo -e "${PURPLE}==========================================${NC}"
    echo ""

    # 1. SUBDOMINIOS
    echo -e "${CYAN}[1/7] Subfinder - Subdominios...${NC}"
    if check_tool subfinder; then
        subfinder -d "$ALVO" -o "$PASTA/subdominios.txt" -silent 2>/dev/null
        echo -e "${GREEN}  → $(wc -l < "$PASTA/subdominios.txt" 2>/dev/null || echo 0) subdominios${NC}"
    else
        echo -e "${RED}  → Subfinder nao instalado${NC}"
    fi

    # 2. NMAP
    echo -e "${CYAN}[2/7] Nmap - Portas e servicos...${NC}"
    if check_tool nmap; then
        if check_tool proxychains4; then
            proxychains4 nmap -sV -sC -T4 "$ALVO" -oN "$PASTA/nmap.txt" 2>/dev/null
        else
            nmap -sV -sC -T4 "$ALVO" -oN "$PASTA/nmap.txt" 2>/dev/null
        fi
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → Nmap nao instalado${NC}"
    fi

    # 3. HTTPX
    echo -e "${CYAN}[3/7] HTTPX - Enumeracao HTTP...${NC}"
    if check_tool httpx; then
        httpx -u "$ALVO" -o "$PASTA/httpx.txt" -silent -status-code -title -tech-detect 2>/dev/null
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → HTTPX nao instalado${NC}"
    fi

    # 4. WAF
    echo -e "${CYAN}[4/7] WAFW00F - Detectar WAF...${NC}"
    if check_tool wafw00f; then
        wafw00f "$ALVO" -o "$PASTA/waf.txt" 2>/dev/null
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → WAFW00F nao instalado${NC}"
    fi

    # 5. WHATWEB
    echo -e "${CYAN}[5/7] WhatWeb - Tecnologias...${NC}"
    if check_tool whatweb; then
        whatweb "$ALVO" --color=never -a 3 > "$PASTA/whatweb.txt" 2>/dev/null
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → WhatWeb nao instalado${NC}"
    fi

    # 6. DIRB
    echo -e "${CYAN}[6/7] Dirb - Diretorios...${NC}"
    if check_tool dirb; then
        dirb "https://$ALVO" /usr/share/dirb/wordlists/common.txt -o "$PASTA/dirb.txt" -S -r 2>/dev/null
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → Dirb nao instalado${NC}"
    fi

    # 7. NUCLEI
    echo -e "${CYAN}[7/7] Nuclei - Vulnerabilidades...${NC}"
    if check_tool nuclei; then
        nuclei -u "$ALVO" -o "$PASTA/nuclei.txt" -silent -severity low,medium,high,critical 2>/dev/null
        echo -e "${GREEN}  → Resultado salvo${NC}"
    else
        echo -e "${RED}  → Nuclei nao instalado${NC}"
    fi

    # RESUMO
    echo ""
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}  SCAN COMPLETO!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo ""
    echo -e "${YELLOW}Resultados em: $PASTA/${NC}"
    echo ""
    ls -la "$PASTA/" 2>/dev/null
    echo ""
    echo -e "${YELLOW}Ver detalhes? (s/n)${NC}"
    echo -n "> "
    read VER
    if [ "$VER" = "s" ] || [ "$VER" = "S" ]; then
        for f in "$PASTA"/*.txt; do
            [ -f "$f" ] || continue
            echo ""
            echo -e "${CYAN}=== $(basename $f) ===${NC}"
            head -30 "$f"
        done
    fi
}

# =============================================
# MENU INDIVIDUAL
# =============================================
nmap_scan() {
    if ! check_tool nmap; then
        echo -e "${RED}Nmap nao instalado. Rode: pkg install nmap -y${NC}"
        return
    fi
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
    echo -e "${YELLOW}Tipo:${NC}"
    echo "  1) Rapido (top portas)"
    echo "  2) Completo (todas portas)"
    echo "  3) Servicos + SO"
    echo "  4) Vulnerabilidades"
    echo "  5) Stealth SYN"
    echo "  6) Agressivo (-A)"
    echo ""
    echo -n "Escolha: "
    read TIPO

    OUTPUT="nmap_$(echo $ALVO | tr '/' '_').txt"
    [ -z "$TIPO" ] && TIPO=3

    case $TIPO in
        1) CMD="nmap -T4 -F \"$ALVO\" -oN \"$OUTPUT\"" ;;
        2) CMD="nmap -p- -T4 \"$ALVO\" -oN \"$OUTPUT\"" ;;
        3) CMD="nmap -sV -sC -O \"$ALVO\" -oN \"$OUTPUT\"" ;;
        4) CMD="nmap --script vuln \"$ALVO\" -oN \"$OUTPUT\"" ;;
        5) CMD="nmap -sS -T4 \"$ALVO\" -oN \"$OUTPUT\"" ;;
        6) CMD="nmap -A -T4 \"$ALVO\" -oN \"$OUTPUT\"" ;;
        *) CMD="nmap -sV \"$ALVO\" -oN \"$OUTPUT\"" ;;
    esac

    echo ""
    echo -e "${YELLOW}[...] Escaneando...${NC}"

    if check_tool proxychains4; then
        echo -e "${GREEN}[ProxyChains ativo]${NC}"
        proxychains4 bash -c "$CMD" 2>/dev/null
    else
        bash -c "$CMD" 2>/dev/null
    fi

    echo ""
    echo -e "${GREEN}[OK] $OUTPUT${NC}"
    cat "$OUTPUT" 2>/dev/null | head -40
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

sqlmap_scan() {
    if ! check_tool sqlmap; then
        echo -e "${RED}SQLMap nao instalado. Rode: pip install sqlmap${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        💉 SQLMAP SCANNER            ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}URL com parametro:${NC}"
    echo -e "${WHITE}Ex: http://site.com/page?id=1${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}Nivel: 1) Rapido  2) Medio  3) Avancado${NC}"
    echo -n "> "
    read NIVEL
    [ -z "$NIVEL" ] && NIVEL=1

    OUTPUT="sqlmap_$(echo $ALVO | tr '/:' '__').txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando SQLMap...${NC}"

    sqlmap -u "$ALVO" \
        --level="$NIVEL" --risk="$NIVEL" \
        --batch --threads=5 \
        --random-agent \
        --output-dir="./sqlmap_output" 2>/dev/null | tee "$OUTPUT"

    echo ""
    echo -e "${GREEN}[OK] $OUTPUT${NC}"
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

dirb_scan() {
    if ! check_tool dirb; then
        echo -e "${RED}Dirb nao instalado. Rode: pkg install dirb -y${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         📁 DIRB SCANNER              ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}URL (com / no final):${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    OUTPUT="dirb_$(echo $ALVO | tr '/' '_').txt"

    echo ""
    echo -e "${YELLOW}[...] Rodando Dirb...${NC}"

    dirb "$ALVO" /usr/share/dirb/wordlists/common.txt -o "$OUTPUT" -S -r 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] $OUTPUT${NC}"
    cat "$OUTPUT" | tail -30
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

waf_scan() {
    if ! check_tool wafw00f; then
        echo -e "${RED}WAFW00F nao instalado. Rode: pip install wafw00f${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        🛡️ WAF SCANNER               ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}[...] Detectando WAF...${NC}"
    wafw00f "$ALVO" 2>/dev/null
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

whatweb_scan() {
    if ! check_tool whatweb; then
        echo -e "${RED}WhatWeb nao instalado. Rode: pkg install whatweb -y${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║      🌐 WHATWEB SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}[...] Detectando tecnologias...${NC}"
    whatweb "$ALVO" -a 3 2>/dev/null
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

subfinder_scan() {
    if ! check_tool subfinder; then
        echo -e "${RED}Subfinder nao instalado.${NC}"
        return
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
    subfinder -d "$ALVO" -o "$OUTPUT" -silent 2>/dev/null

    echo ""
    echo -e "${GREEN}[OK] $(wc -l < "$OUTPUT" 2>/dev/null || echo 0) subdominios${NC}"
    cat "$OUTPUT" 2>/dev/null | head -20
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

httpx_scan() {
    if ! check_tool httpx; then
        echo -e "${RED}HTTPX nao instalado.${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║        🌍 HTTPX SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}[...] Escaneando...${NC}"
    httpx -u "$ALVO" -status-code -title -tech-detect -content-length -silent 2>/dev/null
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

nuclei_scan() {
    if ! check_tool nuclei; then
        echo -e "${RED}Nuclei nao instalado.${NC}"
        return
    fi
    clear
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       💀 NUCLEI SCANNER             ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Dominio:${NC}"
    echo -n "> "
    read ALVO
    [ -z "$ALVO" ] && return

    echo ""
    echo -e "${YELLOW}Nivel: 1) Baixo  2) Medio  3) Alto  4) Critico  5) Todos${NC}"
    echo -n "> "
    read SEV
    [ -z "$SEV" ] && SEV=5

    case $SEV in
        1) SEVERITY="low" ;;
        2) SEVERITY="medium" ;;
        3) SEVERITY="high" ;;
        4) SEVERITY="critical" ;;
        *) SEVERITY="low,medium,high,critical" ;;
    esac

    echo ""
    echo -e "${YELLOW}[...] Rodando Nuclei...${NC}"
    nuclei -u "$ALVO" -s "$SEVERITY" -silent -severity "$SEVERITY" 2>/dev/null
    echo ""
    echo -e "${YELLOW}Enter para voltar...${NC}"
    read
}

# =============================================
# MENU PRINCIPAL
# =============================================
while true; do
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║        🔍 SCANNER TOOLKIT v2 - COMPLETO          ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    echo -e "${WHITE}ESCOLHA:${NC}"
    echo ""
    echo -e "  ${GREEN}0)${NC} 🚀 SCAN COMPLETO (tudo junto)"
    echo -e "  ${GREEN}1)${NC} 🔍 Nmap        - Portas, servicos, SO"
    echo -e "  ${GREEN}2)${NC} 💉 SQLMap       - Injecao SQL"
    echo -e "  ${GREEN}3)${NC} 📁 Dirb         - Diretorios"
    echo -e "  ${GREEN}4)${NC} 🛡️ WAFW00F      - Detectar WAF"
    echo -e "  ${GREEN}5)${NC} 🌐 WhatWeb      - Tecnologias"
    echo -e "  ${GREEN}6)${NC} 🔎 Subfinder    - Subdominios"
    echo -e "  ${GREEN}7)${NC} 🌍 HTTPX        - Enumeracao HTTP"
    echo -e "  ${GREEN}8)${NC} 💀 Nuclei       - Vulnerabilidades"
    echo ""
    echo -e "  ${YELLOW}9)${NC} 📦 Instalar TUDO (primeira vez)"
    echo -e "  ${RED}q)${NC} Sair"
    echo ""
    echo -n "Escolha: "
    read ESCOLHA

    case $ESCOLHA in
        0) full_scan ;;
        1) nmap_scan ;;
        2) sqlmap_scan ;;
        3) dirb_scan ;;
        4) waf_scan ;;
        5) whatweb_scan ;;
        6) subfinder_scan ;;
        7) httpx_scan ;;
        8) nuclei_scan ;;
        9) install_all ;;
        q) echo "Saindo..."; exit 0 ;;
        *) echo "Invalida!" ;;
    esac
done
