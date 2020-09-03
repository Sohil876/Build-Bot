#!/bin/bash
#
#-# Build-Bot
#-# By @Sohil876
#-# https://github.com/Sohil876/Build-Bot
#

### Color Codes ###
red='\e[0;31m'             # Red
green='\e[0;32m'        # Green
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

check_rom_dir() {
  # Checking if this is a rom directory and repo is initialised
  if [ ! -d ".repo" ]; then
    echo "Not a rom directory!"
    echo "Please make sure you're in the rom directory."
    exit 1
  fi
}

clean_build() {
  check_rom_dir
  free_up_ram
  source conf.rom
  source build/envsetup.sh
  # Start Cleaning
  echo "Cleaning build ... "
  echo "This can take 5 to 10 mins! Do not Cancel!"
  make clobber -j$( nproc --all ) && make clean -j$( nproc --all )
}

free_up_ram() {
  # Cleaning RAM
  sudo sh -c "sync"
  sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
}

export_config() {
  check_rom_dir
  # Checking if rom config file is present to prevent overwrite
  if [ ! -f "conf.rom" ]; then
    # Export conf file to rom dir
    cat >conf.rom <<-'_EOL_'
	# Build-Bot Configuration file
	# Adapt it for your rom
	ROM_NAME=BlissROM
	ROM=bliss
	DEVICE=tissot
	TARGET=user
	BUILD_TYPE=OFFICIAL
	PRECOMPILE_METALAVA=false # Enable if less than 16GB RAM
	MAKE_COMMAND="blissify tissot" # Enter your full build command inside quotes, ex. mka bacon, blissify tissot, ./rom-build.sh, etc
	ROM_FOLDER="${PWD}" # Use for getting location of your rom directory root
	OUT="${ROM_FOLDER}"/out/target/product/"${DEVICE}"
	# Enter your full upload command here inside quotes to enable it, make sure you enter part of filename as well
	# Ex "mega-put ${ROM_FOLDER}/out/target/product/tissot/Bliss*.zip Tst_Folder/"
	AUTO_UPLOAD=false
	# Exports
	export JAVA_OPTIONS=-Xmx4g
	export LC_ALL=C # For Ubuntu18
	export BUILD_TYPE="${BUILD_TYPE}"
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
    echo "Config file already exists!"
    exit 1
  fi
}

help() {
  cat <<-_EOL_
$(echo -e "${green}Usage:${nocol}")
-h,  --help             Shows brief help
-i,  --install          Install Build-Bot in /usr/bin
-ec, --export-config    Exports a sample config file to your current rom directory
-cb, --clean-build      Do make clobber and clean on build
-sc, --shallow-clean    Do installclean and deviceclean for faster build
-sr, --sync-rom         Sync rom
_EOL_
}

shallow_clean() {
  check_rom_dir
  free_up_ram
  # Import config/scripts from rom directory
  source conf.rom
  source build/envsetup.sh
  # Start cleaning
  echo "Cleaning build ... "
  make installclean -j$( nproc --all ) && make deviceclean -j$( nproc --all )
}

sync_rom() {
  check_rom_dir
  free_up_ram
  source conf.rom
  SYNC_START=$(date +"%s")
  # Report to tg group/channel
  read -r -d '' MESSAGE <<_EOL_
  *Sync Started! @* $(date "+%I:%M%p") ($(date +"%Z%:z"))
  *Syncing:* ${ROM_NAME}
_EOL_
  curl -s -X POST -d chat_id="${CHAT_ID}" -d parse_mode=markdown -d text="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendMessage
  # Start syncing
  repo sync -c -j$(nproc --all) --no-tags --no-clone-bundle --force-sync 2>&1 | tee sync.log
  SYNC_END=$(date +"%s")
  DIFF=$(("${SYNC_END}" - "${SYNC_START}"))
  # Sync succeded! report to tg group/channel
  read -r -d '' MESSAGE <<_EOL_
  *Sync Finished!*
   
  *Time:* $((DIFF / 60)) minutes and $((DIFF % 60)) seconds
_EOL_
  curl -F chat_id="${CHAT_ID}" -F document=@"${ROM_FOLDER}"/sync.log -F parse_mode=markdown -F caption="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendDocument
}

### Main program ###
case ${@} in
  -cb|--clean-build)
    echo ""
    clean_build
    echo ""
    exit 0
  ;;
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
    cp -f "${PWD}"/build-bot.sh /usr/bin/build-bot
    if [ $? -ne 0 ]; then
      echo "Permission denied, re-run command with sudo!"
    else
      chmod +x /usr/bin/build-bot
    fi
    echo "Installed Build-Bot!"
    echo "Make use of conf files to use build-bot with multiple roms!"
    echo ""
    exit 0
  ;;
  -sc|--shallow-clean)
    echo ""
    shallow_clean
    echo ""
    exit 0
  ;;
  -sr|--sync-rom)
    echo ""
    sync_rom
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