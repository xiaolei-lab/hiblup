#!/bin/bash
# Author: Haohao Zhang <haohaozhang@whut.edu.cn>
# Date: Jul 10, 2019

# Define
VERSION="1.3.1"
R_VERSION="3.5.1"
MIRROR_DEFAULT="tuna"
REPO_ROOT="https://raw.githubusercontent.com/xiaolei-lab/hiblup/master/version/${VERSION}"

# getopts
MIRROR=$MIRROR_DEFAULT
while getopts "d:m:k" opt; do
    case $opt in
        d)
            if [[ -z ${CONDA_PREFIX} ]]; then
                mkdir -p $OPTARG
                INSTALL_PATH=$(cd "$OPTARG" && pwd)
            else
                echo "Warning: CONDA_PREFIX found, -d is ignored."
                echo "CONDA_PREFIX: ${CONDA_PREFIX}"
            fi
            ;;
        r)
            R_VERSION=$OPTARG
            ;;
        v)
            VERSION=$OPTARG
            ;;
        m)
            MIRROR=$OPTARG
            ;;
        k)
            CURL_OPT="-k"
            ;;
        \?)
            echo ""
            echo "./hiblupInstaller.sh [-d <install_path>] [-m 'tuna'|'official'] [-k]"
            echo "Usage:"
            echo "    -d : Specify the conda installation path. If a conda is detected, this option"
            echo "         will be ignored. (default: ~/miniconda3)"
            echo "    -m : Specify the mirror source, which can be 'tuna' or 'official'. Users in"
            echo "         mainland China recommend 'tuna'. Users in other regions can use"
            echo "         'official'. (default: tuna)"
            echo "    -k : turn off curl's verification of the certificate."
            echo ""
            ;;
    esac
done

# Define
if [[ ${MIRROR} == "tuna" ]]; then
    CONDA_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
    CRAN_MIRROR=https://mirrors.tuna.tsinghua.edu.cn/CRAN/
elif [[ ${MIRROR} == "official" ]]; then
    CONDA_MIRROR=https://repo.continuum.io/miniconda
    CRAN_MIRROR=http://cran.rstudio.com
else
    echo "Error: Unknow MIRROR."
    exit 1
fi


# OS
if [[ "$(uname)" == "Darwin" ]]; then
    CONDA_INSTALLER="Miniconda3-latest-MacOSX-x86_64.sh"
    HIBLUP_PACKAGE="hiblup_${VERSION}_R_${R_VERSION}_community_x86_64_macOS.tar.gz"
    R_ENV="r-base=${R_VERSION}"
    PROFILE="${HOME}/.bash_profile"
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    CONDA_INSTALLER="Miniconda3-latest-Linux-x86_64.sh"
    HIBLUP_PACKAGE="hiblup_${VERSION}_R_${R_VERSION}_community_x86_64_Linux.tar.gz"
    R_ENV="mro-base=${R_VERSION}"
    PROFILE="${HOME}/.bashrc"
else
    echo "Error: Unknow OS."
    exit 1
fi

# Workdir
DIR=$(pwd)
TMP_DIR=$(mktemp -d -t hiblup-XXXXXXXX)
cd $TMP_DIR

# Install Miniconda3
if [[ ! $(command -v conda) ]]; then
    if [[ -z "${INSTALL_PATH}" ]]; then
        INSTALL_PATH=~/miniconda3
    fi
    echo "Warning: conda is not installed." >&2
    echo "Installing miniconda3 into ${INSTALL_PATH}..."
    curl ${CURL_OPT} -O ${CONDA_MIRROR}/${CONDA_INSTALLER}
    bash ${CONDA_INSTALLER} -f -u -b -p ${INSTALL_PATH}

    export PATH="${INSTALL_PATH}/bin:$PATH"
    
    conda init bash
    conda config --set auto_activate_base false

    if [[ ${MIRROR} == "tuna" ]]; then
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
        conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r/
        conda config --set show_channel_urls yes
    fi
fi

# hiblup command
HIBLUP_COMMAND="
hiblup () {
    source ${PROFILE}
    if [[ ! \$(command -v conda) ]]; then
        exit 1
    fi

    conda activate hiblup
    if [[ "\$\#" -lt 1 ]]; then
        R
    else
        Rscript \$@
    fi
    conda deactivate
}"

if [[ ! -z $(grep -Fxq "hiblup () {" ${PROFILE}) ]]; then
    # code if found
    echo "Warning: old hiblup function found."
else
    # code if not found
    echo "${HIBLUP_COMMAND}" >> ${PROFILE}
fi

conda init bash
source ${PROFILE}

# check conda
if [[ ! $(command -v conda) ]]; then
    echo "Error: command 'conda' not found"
    exit 1
fi

# Create or update conda env
conda create -n hiblup ${R_ENV} r-essentials r-rcpp r-rcpparmadillo -y
conda activate hiblup

# Install hiblup
echo ""
echo "Downloading HIBLUP from $REPO_ROOT/${HIBLUP_PACKAGE} ..."
curl ${CURL_OPT} -O $REPO_ROOT/${HIBLUP_PACKAGE}

echo ""
echo "Installing HIBLUP ..."
Rscript -e "install.packages('bigmemory', repos='${CRAN_MIRROR}', lib='${CONDA_PREFIX}/lib/R/library')"
Rscript -e "install.packages('${HIBLUP_PACKAGE}', repos=NULL, lib='${CONDA_PREFIX}/lib/R/library')"

# R startup script
STARTUP=""
if [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
STARTUP="
  suppressMessages(library(RevoUtils))
  suppressMessages(library(RevoUtilsMath))
"
fi
echo ".First <- function(){
  ${STARTUP}
  suppressMessages(library(hiblup))
  if('hiblup' %in% (.packages())) {
    # cat('hiblup has been loaded.')
    # cat('\\nWelcome at', date(), '\\n')
  } else {
    cat('Warning: library(hiblup) failed.\\n')
  }
}" > ${CONDA_PREFIX}/lib/R/etc/Rprofile.site


echo ""
echo "hiblup shortcut command has been installed to ${PROFILE}"
echo "Load it with the following command:"
echo "    source ${PROFILE}"
echo ""
echo "Usage:"
echo "$ hiblup"
echo "$ hiblup my_script.R"
echo ""

conda deactivate
cd ${DIR}
rm -rf ${TMP_DIR}