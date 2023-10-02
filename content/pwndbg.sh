#!/usr/bin/env bash
set -ex

# If we are a root in a container and `sudo` doesn't exist
# lets overwrite it with a function that just executes things passed to sudo
# (yeah it won't work for sudo executed with flags)
if ! hash sudo 2> /dev/null && whoami | grep root; then
    sudo() {
        ${*}
    }
fi

if ! hash gdb; then
    echo "Could not find gdb in $PATH"
    exit
fi

# Update all submodules
git submodule update --init --recursive

# Find the Python version used by GDB.
PYVER=$(gdb -batch -q --nx -ex 'pi import platform; print(".".join(platform.python_version_tuple()[:2]))')
PYTHON+=$(gdb -batch -q --nx -ex 'pi import sys; print(sys.executable)')

if ! osx; then
    PYTHON+="${PYVER}"
fi

# Create Python virtualenv
if [[ -z "${PWNDBG_VENV_PATH}" ]]; then
    PWNDBG_VENV_PATH="./.venv"
fi
echo "Creating virtualenv in path: ${PWNDBG_VENV_PATH}"

${PYTHON} -m venv -- ${PWNDBG_VENV_PATH}
PYTHON=${PWNDBG_VENV_PATH}/bin/python

# Upgrade pip itself
${PYTHON} -m pip install --upgrade pip

# Create Python virtual environment and install dependencies in it
${PWNDBG_VENV_PATH}/bin/pip install -e .

# pyproject.toml install itself "pwndbg"/"gdb-pt-dump" into site-packages, for "caching" dockerfile we need remove it
PYTHON_VERSION=$(ls "${PWNDBG_VENV_PATH}/lib/")
CHECK_PATH="${PWNDBG_VENV_PATH}/lib/${PYTHON_VERSION}/site-packages/pwndbg/empty.py"
if [ -f "$CHECK_PATH" ]; then
    rm -rf "$(dirname "$CHECK_PATH")"
fi
CHECK_PATH="${PWNDBG_VENV_PATH}/lib/${PYTHON_VERSION}/site-packages/gdb-pt-dump/empty.py"
if [ -f "$CHECK_PATH" ]; then
    rm -rf "$(dirname "$CHECK_PATH")"
fi

if [ -z "$UPDATE_MODE" ]; then
    # Comment old configs out
    if grep -q '^[^#]*source.*pwndbg/gdbinit.py' ~/.gdbinit; then
        if ! osx; then
            sed -i '/^[^#]*source.*pwndbg\/gdbinit.py/ s/^/# /' ~/.gdbinit
        else
            # In BSD sed we need to pass ' ' to indicate that no backup file should be created
            sed -i ' ' '/^[^#]*source.*pwndbg\/gdbinit.py/ s/^/# /' ~/.gdbinit
        fi
    fi

    # Load Pwndbg into GDB on every launch.
    echo "source $PWD/gdbinit.py" >> ~/.gdbinit
fi