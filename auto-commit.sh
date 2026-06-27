#!/bin/bash
# ============================================
# 🚀 AUTO COMMIT + PUSH (token, sem editor)
# Uso: bash auto-commit.sh "mensagem do commit"
# ============================================

REPO_DIR="/c/Users/rafae/scanner-toolkit"
# Cole seu token aqui (ghp_...)
TOKEN="COLE_SEU_TOKEN_AQUI"

# Nao abrir editor
export GIT_EDITOR="true"
export GIT_SEQUENCE_EDITOR="true"

cd "$REPO_DIR" || exit 1

# Se nao passou mensagem, gerar automaticamente
if [ -z "$1" ]; then
    CHANGES=$(git diff --name-only HEAD 2>/dev/null)
    if [ -z "$CHANGES" ]; then
        COMMIT_MSG="chore: sync $(date +%Y%m%d_%H%M)"
    else
        COMMIT_MSG="update: $(echo "$CHANGES" | head -3 | tr '\n' ' ')"
    fi
else
    COMMIT_MSG="$1"
fi

# Adicionar tudo
git add -A

# Verificar se tem algo pra commit
if git diff --cached --quiet; then
    echo "[OK] Nada pra commit, ja esta tudo atualizado."
    exit 0
fi

# Commit sem abrir editor
git commit -m "$COMMIT_MSG" --no-edit 2>/dev/null

# Push com token (sem abrir navegador)
git remote set-url origin "https://${TOKEN}@github.com/tafasad/scanner-toolkit.git"
git push origin main --quiet 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[OK] Push enviado: $COMMIT_MSG"
else
    echo "[ERRO] Falha no push"
    exit 1
fi
