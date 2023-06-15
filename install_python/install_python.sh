MAIN_DIR=$(pwd)

USE_SUDO=true

if [ $(dpkg -l | grep sudo | wc -l) -eq 0 ]; then
    USE_SUDO=false
    echo "??"
fi

echo "USE_SUDO ${USE_SUDO}"

exit 1

PYTHON_VERSION="3.9.10"

if [ ${1} ]; then
    PYTHON_VERSION=${1}
fi

V_JUNIOR=$(echo "${PYTHON_VERSION}" | cut -d . -f 1)
V_SENIOR=$(echo "${PYTHON_VERSION}" | cut -d . -f 1,2)

if [ ${USE_SUDO} ]; then
    sudo apt update
    sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev
else
    apt-get update
    apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev
fi

wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

PYTHON_DIR=Python-${PYTHON_VERSION}

tar -xf ${PYTHON_DIR}.tgz

cd ${PYTHON_DIR}
./configure --enable-optimizations

make -j$(($(nproc) - 1))

if [ ${USE_SUDO} ]; then
    sudo make altinstall
else
    make altinstall
fi

#----------------------------------------------------------------

# add_path(path1, path2)
add_path () {

    if [ ! -f "/usr/bin/${1}" ]; then

        echo "Add ${1} to /usr/bin"

        # Add pythonx.x to /usr/bin
        if [ ${USE_SUDO} ]; then
            sudo update-alternatives --install /usr/bin/${1} ${1} ${2} 5
        else
            update-alternatives --install /usr/bin/${1} ${1} ${2} 5
        fi

    fi
}

#----------------------------------------------------------------

PYTHON3x_NAME=python${V_SENIOR}

add_path ${PYTHON3x_NAME} /usr/local/bin/${PYTHON3x_NAME}

#----------------------------------------------------------------

PYTHONx_NAME=python${V_JUNIOR}

add_path ${PYTHONx_NAME} /usr/bin/${PYTHON3x_NAME}

#----------------------------------------------------------------

PIP3x_NAME=pip${V_SENIOR}

add_path ${PIP3x_NAME} /usr/local/bin/${PIP3x_NAME}

#----------------------------------------------------------------

PIPx_NAME=pip${V_JUNIOR}

add_path ${PIPx_NAME} /usr/bin/${PIP3x_NAME}

#----------------------------------------------------------------

cd ${MAIN_DIR}

if [ ${USE_SUDO} ]; then
    sudo rm -rf ${PYTHON_DIR}.tgz
    sudo rm -rf ${PYTHON_DIR}
else
    rm -rf ${PYTHON_DIR}.tgz
    rm -rf ${PYTHON_DIR}
fi