#!/bin/sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

PYTHON=""

if [ "$(uname)" = "Darwin" ]; then
    # macOS: search python.org 3.x versions
    for DIR in $(ls -d /Library/Frameworks/Python.framework/Versions/3.* 2>/dev/null | sort -V -r); do
        PY="$DIR/bin/python3"
        [ -x "$PY" ] || continue
        if "$PY" -c "import tkinter" >/dev/null 2>&1; then
            PYTHON="$PY"
            break
        fi
    done
else
    # Linux/Ubuntu: look in PATH
    for PY in $(which -a python3 2>/dev/null); do
        [ -x "$PY" ] || continue
        if "$PY" -c "import tkinter" >/dev/null 2>&1; then
            PYTHON="$PY"
            break
        fi
    done
fi

if [ -z "$PYTHON" ]; then
    echo "No suitable Python 3.x with Tk found!"
    exit 1
fi

echo "Using Python: $PYTHON"

exec "$PYTHON" pre-build.py
