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

# Modify RenLocalizer.sh to use system Python directly
if [ -f "RenLocalizer.sh" ]; then
    cat > RenLocalizer.sh.tmp << 'EOF'
#!/usr/bin/env bash
# RenLocalizer launcher for Linux/macOS
# Uses system Python directly (no venv)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_BINARY="$SCRIPT_DIR/RenLocalizer"
RUN_PY="$SCRIPT_DIR/run.py"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    printf '%b\n' "${GREEN}[RenLocalizer]${NC} $1"
}

print_warn() {
    printf '%b\n' "${YELLOW}[RenLocalizer]${NC} $1"
}

print_error() {
    printf '%b\n' "${RED}[RenLocalizer]${NC} $1" >&2
}

run_portable_build() {
    cd "$SCRIPT_DIR"

    if [[ ! -x "$APP_BINARY" ]]; then
        chmod +x "$APP_BINARY"
    fi

    if [[ -n "${RENLOCALIZER_GL_RETRY:-}" ]]; then
        print_info "Launching portable build (software rendering)..."
        exec "$APP_BINARY" "$@"
    fi

    print_info "Launching portable build..."
    set +e
    "$APP_BINARY" "$@"
    local exit_code=$?
    set -e

    if [[ "$exit_code" -eq 0 ]]; then
        exit 0
    fi

    if [[ "$exit_code" -le 128 ]]; then
        exit "$exit_code"
    fi

    print_warn "Application crashed with signal $((exit_code - 128)) (exit code $exit_code)."
    print_warn "Retrying with software rendering (QT_QUICK_BACKEND=software)..."

    export QT_QUICK_BACKEND="software"
    export RENLOCALIZER_GL_RETRY="1"
    exec "$APP_BINARY" "$@"
}

ensure_python3() {
    if ! command -v python3 >/dev/null 2>&1; then
        print_error "Python 3 is not installed."
        printf '%s\n' "Please install Python 3.10 or higher."
        printf '%s\n' "  Ubuntu/Debian: sudo apt install python3 python3-pip"
        printf '%s\n' "  Fedora: sudo dnf install python3 python3-pip"
        printf '%s\n' "  macOS: brew install python3"
        exit 1
    fi

    local python_version
    python_version="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    local python_major="${python_version%%.*}"
    local python_minor="${python_version##*.}"

    if [[ "$python_major" -lt 3 || ( "$python_major" -eq 3 && "$python_minor" -lt 10 ) ]]; then
        print_error "Python 3.10 or higher is required. Current version: Python ${python_version}"
        exit 1
    fi

    print_info "Python ${python_version} detected"
}

run_source_checkout() {
    ensure_python3

    if [[ ! -f "$RUN_PY" ]]; then
        print_error "run.py not found."
        exit 1
    fi

    cd "$SCRIPT_DIR"

    print_info "Launching with system Python..."
    exec python3 "$RUN_PY" "$@"
}

if [[ -f "$APP_BINARY" && -d "$SCRIPT_DIR/_internal" ]]; then
    run_portable_build "$@"
else
    run_source_checkout "$@"
fi
EOF
    mv RenLocalizer.sh.tmp RenLocalizer.sh
    chmod +x RenLocalizer.sh
    echo "  - Modificado para usar Python del sistema"
fi

    if [[ -n "${RENLOCALIZER_GL_RETRY:-}" ]]; then
        print_info "Launching portable build (software rendering)..."
        exec "$APP_BINARY" "$@"
    fi

    print_info "Launching portable build..."
    set +e
    "$APP_BINARY" "$@"
    local exit_code=$?
    set -e

    if [[ "$exit_code" -eq 0 ]]; then
        exit 0
    fi

    if [[ "$exit_code" -le 128 ]]; then
        exit "$exit_code"
    fi

    print_warn "Application crashed with signal $((exit_code - 128)) (exit code $exit_code)."
    print_warn "Retrying with software rendering (QT_QUICK_BACKEND=software)..."

    export QT_QUICK_BACKEND="software"
    export RENLOCALIZER_GL_RETRY="1"
    exec "$APP_BINARY" "$@"
}

ensure_python3() {
    if ! command -v python3 >/dev/null 2>&1; then
        print_error "Python 3 is not installed."
        printf '%s\n' "Please install Python 3.10 or higher."
        printf '%s\n' "  Ubuntu/Debian: sudo apt install python3 python3-pip"
        printf '%s\n' "  Fedora: sudo dnf install python3 python3-pip"
        printf '%s\n' "  macOS: brew install python3"
        exit 1
    fi

    local python_version
    python_version="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
    local python_major="${python_version%%.*}"
    local python_minor="${python_version##*.}"

    if [[ "$python_major" -lt 3 || ( "$python_major" -eq 3 && "$python_minor" -lt 10 ) ]]; then
        print_error "Python 3.10 or higher is required. Current version: Python ${python_version}"
        exit 1
    fi

    print_info "Python ${python_version} detected"
}

run_source_checkout() {
    ensure_python3

    if [[ ! -f "$RUN_PY" ]]; then
        print_error "run.py not found."
        exit 1
    fi

    cd "$SCRIPT_DIR"

    print_info "Launching with system Python..."
    exec python3 "$RUN_PY" "$@"
}

if [[ -f "$APP_BINARY" && -d "$SCRIPT_DIR/_internal" ]]; then
    run_portable_build "$@"
else
    run_source_checkout "$@"
fi
EOF
    mv RenLocalizer.sh.tmp RenLocalizer.sh
    chmod +x RenLocalizer.sh
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
echo "[4/4] Modificando RenLocalizerCLI.sh..."

# Modify RenLocalizerCLI.sh to use system Python directly
if [ -f "RenLocalizerCLI.sh" ]; then
    cat > RenLocalizerCLI.sh.tmp << 'EOF'
#!/bin/bash
# RenLocalizer CLI Launcher for Linux/Mac
# Uses system Python directly (no venv)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed.${NC}"
    echo "Please install Python 3.10 or higher."
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
PYTHON_MAJOR=$(echo "$PYTHON_VERSION" | cut -d. -f1)
PYTHON_MINOR=$(echo "$PYTHON_VERSION" | cut -d. -f2)

if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
    echo -e "${RED}Error: Python 3.10 or higher is required (found: $PYTHON_VERSION)${NC}"
    exit 1
fi

echo -e "${GREEN}[RenLocalizer]${NC} Launching CLI with system Python..."
python3 run_cli.py "$@"
EOF
    mv RenLocalizerCLI.sh.tmp RenLocalizerCLI.sh
    chmod +x RenLocalizerCLI.sh
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
echo "[5/5] Dando permisos de ejecucion a los scripts..."

# Set execute permissions on shell scripts in the root directory
for sh in *.sh; do
    if [ -f "$sh" ]; then
        chmod +x "$sh" && echo "  - $sh ejecutado"
    fi
done

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