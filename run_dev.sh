#!/bin/bash
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )"
docker run -it -e "HOMEBREW_NO_AUTO_UPDATE=1" -v ${SCRIPT_DIR}:/home/linuxbrew/.linuxbrew/Homebrew/Library/Taps/djocker/homebrew-common digitalspacestudio/linuxbrew:3.2.8 bash
