MAIN_DIR=$(pwd)

sudo apt update
sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libsqlite3-dev libreadline-dev libffi-dev wget libbz2-dev


PYTHON_VERSION="3.9.10"

# read -p "Select the python version: " VALUE

V_JUNIOR=$(echo "${PYTHON_VERSION}" | cut -d . -f 1)
V_SENIOR=$(echo "${PYTHON_VERSION}" | cut -d . -f 1,2)

echo ${V_JUNIOR}

# echo https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz

PYTHON_DIR=Python-${PYTHON_VERSION}

tar -xf ${PYTHON_DIR}.tgz

cd ${PYTHON_DIR}
./configure --enable-optimizations

make -j$(($(nproc) - 1))
sudo make altinstall

#----------------------------------------------------------------

# add_path(path1, path2)
add_path () {

    if [ ! -f "/usr/bin/${1}" ]; then

        echo "Add ${1} to /usr/bin"

        # Add pythonx.x to /usr/bin
        sudo update-alternatives --install /usr/bin/${1} ${1} ${2} 5
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

sudo rm -rf ${PYTHON_DIR}.tgz
sudo rm -rf ${PYTHON_DIR}