#!/bin/bash

# RenLocalizer Setup Script
# Automates project setup: moves docs, removes venv dependency

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== RenLocalizer Setup Script ==="
echo "Directorio de trabajo: $SCRIPT_DIR"
echo ""

# Create folder for documentation files
DOCS_DIR="$SCRIPT_DIR/documentacion"
mkdir -p "$DOCS_DIR"

echo "[1/4] Moviendo archivos de documentacion..."

# Move MD files (including AGENTS.md)
for file in *.md; do
    if [ -f "$file" ]; then
        mv -v "$file" "$DOCS_DIR/" 2>/dev/null || true
    fi
done

# Move TXT files
for file in requirements.txt requirements-dev.txt constraints-release.txt tox.ini; do
    if [ -f "$file" ]; then
        mv -v "$file" "$DOCS_DIR/" 2>/dev/null || true
    fi
done

# Move LICENSE and gitignore
for file in LICENSE .gitignore; do
    if [ -f "$file" ]; then
        mv -v "$file" "$DOCS_DIR/" 2>/dev/null || true
    fi
done

# Move extra files to documentation
for file in RenLocalizer.spec run.bat index.html; do
    if [ -f "$file" ]; then
        mv -v "$file" "$DOCS_DIR/" 2>/dev/null || true
    fi
done

# Move folders to documentation
for dir in .github build docs examples tests; do
    if [ -d "$dir" ]; then
        mv -v "$dir" "$DOCS_DIR/" 2>/dev/null || true
    fi
done

echo ""
echo "[2/4] Modificando RenLocalizer.sh..."

# Modify RenLocalizer.sh to use system Python without venv
if [ -f "RenLocalizer.sh" ]; then
    sed -i 's|python3 -m venv "$VENV_DIR"|# venv disabled|g' RenLocalizer.sh
    sed -i 's|source "$VENV_DIR/bin/activate"|# venv disabled|g' RenLocalizer.sh
    sed -i 's|pip install|pip install|g' RenLocalizer.sh
    echo "  - Modificado para usar Python del sistema"
fi

echo ""
echo "[3/4] Modificando run.py..."

# Modify run.py to remove venv dependency
if grep -q "venv\|virtualenv\|\.venv" run.py 2>/dev/null; then
    sed -i '/venv/d; /virtualenv/d; /\.venv/d; /VIRTUAL_ENV/d; /pyvenv/d' run.py
    echo "  - Modificado para usar Python del sistema"
fi

echo ""
echo "[4/4] Modificando run_cli.py..."

# Modify run_cli.py to remove venv dependency
if grep -q "venv\|virtualenv\|\.venv" run_cli.py 2>/dev/null; then
    sed -i '/venv/d; /virtualenv/d; /\.venv/d; /VIRTUAL_ENV/d; /pyvenv/d' run_cli.py
    echo "  - Modificado para usar Python del sistema"
fi

echo ""
echo "[5/5] Descargando icon.png..."

# Download icon.png from GitHub
ICON_URL="https://raw.githubusercontent.com/Iskander-mlander/OrdenRLLOT/main/icon.png"
if command -v curl >/dev/null 2>&1; then
    curl -fsSL -o icon.png "$ICON_URL" && echo "  - Icono descargado" || echo "  - Error al descargar icono"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O icon.png "$ICON_URL" && echo "  - Icono descargado" || echo "  - Error al descargar icono"
fi

echo ""
echo "[6/6] Verificando instalacion de Python del sistema..."

# Verify system Python has required packages
echo "  - Version de Python: $(python3 --version)"
echo "  - Verificando PyQt6..."
if python3 -c "import PyQt6" 2>/dev/null; then
    echo "  - PyQt6 instalado"
else
    echo "  - ADVERTENCIA: PyQt6 no esta instalado"
    echo "    Instala con: pip install PyQt6"
fi

echo ""
echo "=== Configuracion completada ==="
echo ""
echo "Archivos movidos a: $DOCS_DIR"
echo ""
echo "Ejecuta el proyecto con: ./RenLocalizer.sh"
echo "Ejecuta CLI con: python3 run_cli.py"