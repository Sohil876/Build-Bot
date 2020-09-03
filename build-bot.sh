#!/bin/bash
### Build-Bot By @Sohil876 ###

### Color Codes ###
red='\e[0;31m'             # Red
green='\e[0;32m'        # Green
#yellow='\e[0;33m'       # Yellow
#purple='\e[0;35m'       # Purple
cyan='\e[0;36m'          # Cyan
white='\e[0;37m'        # White
nocol='\033[0m'         # Default

### Functions ###
banner() {
  echo -e "${green}--------------------------------------"
  echo "              BUILD-BOT"
  echo -e "          ${green}(${cyan}By ${green}-:- ${white}Sohil876${green})${nocol}"
  echo -e "${green}--------------------------------------${nocol}"
}

export_config() {
  # Checking if this is a rom directory and repo is initialised
  if [ ! -d ".repo" ]; then
      echo "Not a rom directory!"
      echo "Please make sure you're in the rom directory to export config file"
      exit 1
  fi
  # Checking if rom config file is present to prevent overwrite
  if [ ! -f "conf.rom" ]; then
    # Export conf file to rom dir
    cat >conf.rom <<-'_EOL_'
	# Configuration file
	# Adapt it for your rom
	ROM_NAME=BlissROM
	ROM=bliss
	DEVICE=tissot
	TARGET=user
	BUILD_TYPE=OFFICIAL
	PRECOMPILE_METALAVA=false # Enable if less than 16GB RAM
	MAKE_COMMAND="blissify tissot" # Enter your full build command inside quotes, ex. mka bacon, blissify tissot, ./rom-build.sh, etc
	ROM_FOLDER=${PWD} # Use for getting location of your rom directory root
	OUT=${ROM_FOLDER}/out/target/product/${DEVICE}
	BUILD_START=$(date +"%s")
	# Enter your full upload command here inside quotes to enable it, make sure you enter part of filename as well
	# Ex "mega-put ${ROM_FOLDER}/out/target/product/tissot/Bliss*.zip Tst_Folder/"
	AUTO_UPLOAD=false
	# Exports
	export JAVA_OPTIONS=-Xmx4g
	export LC_ALL=C # For Ubuntu18
	export BUILD_TYPE=${BUILD_TYPE}
	export USE_CCACHE=1
	export CCACHE_EXEC=$(command -v ccache)
	export CCACHE_DIR=~/.ccache
#            export CCACHE_MAX_SIZE=50G
#            ccache -M $CCACHE_MAX_SIZE
	# Telegram bot token
	TOKEN="YOUR BOT TOKEN"
	# Telegram group/channel id
	CHAT_ID="YOUR CHAT ID"
_EOL_
  else
    echo "Config file already exist!"
    exit 1
  fi
}

help() {
  cat <<_EOL_
$(echo -e "${green}Usage:${nocol}")
-ec, --export-config    Exports a sample config file to your current rom directory
-h,  --help             Shows brief help
-i,  --install          Install Build-Bot in /usr/bin
_EOL_
}

install() {
  cp -f ${PWD}/build-bot.sh /usr/bin/build-bot
  if [ $? -ne 0 ]; then
    echo "Permission denied, rerun command with sudo!"
  else
    chmod +x /usr/bin/build-bot
  fi
}

### Main program ###
case ${@} in
  -ec|--export-config)
    echo ""
    export_config
    echo "Config file exported!"
    echo "Adapt conf.rom file according to your needs!"
    echo ""
    exit 0
  ;;
  -h|--help)
    banner
    echo ""
    help
    echo ""
    exit 0
  ;;
  -i|--install)
    echo ""
    install
    echo "Installed Build-Bot!"
    echo "Make use of conf files to use build-bot with multiple roms!"
    echo ""
    exit 0
  ;;
esac

# Error msg for no arguments specified
banner
echo ""
echo -e "${red}No arguments specified!${nocol}"
echo "See -h or --help for usage"
echo ""
exit 1