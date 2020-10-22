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
  echo -e "              BUILD-BOT"
  echo -e "          ${green}(${cyan}By ${green}-:- ${white}Sohil876${green})${nocol}"
  echo -e "${green}--------------------------------------${nocol}"
}

build_rom() {
  check_rom_dir
  check_config_file
  source conf.rom
  # Removing old builds
  rm "${OUT}"/*.zip
  rm "${OUT}"/*.md5
  # Configuring build
  source build/envsetup.sh
  lunch "${ROM}"_"${DEVICE}"-"${TARGET}"
  free_up_ram
  # Start Build!
  BUILD_START=$(date +"%s")
  # Precompile Metalava if enabled in config
  if [ "${PRECOMPILE_METALAVA}" = true ]; then
    echo "PreCompiling Metalava!"
    make api-stubs-docs -j$( nproc --all ) && make hiddenapi-lists-docs -j$( nproc --all ) && make system-api-stubs-docs -j$( nproc --all ) && make test-api-stubs-docs -j$( nproc --all ) 2>&1 | tee "${ROM}"-build-metalava.log
  fi
  free_up_ram
  # Report to tg group/channel
  read -r -d '' MESSAGE <<-_EOL_
<strong>Build Started!</strong>
<strong>@</strong> $(date "+%I:%M%p") ($(date +"%Z%:z"))
<strong>CPUs :</strong> $(nproc --all) <strong>|</strong> <strong>RAM :</strong> $(awk '/MemTotal/ { printf "%.1f \n", $2/1024/1024 }' /proc/meminfo)GB
<strong>Building :</strong> ${ROM_NAME}
<strong>Build Type :</strong> ${BUILD_TYPE}
<strong>Target :</strong> ${TARGET}
<strong>CPUs :</strong> $(nproc --all) <strong> | </strong> <strong>RAM :</strong> $(awk '/MemTotal/ { printf "%.1f \n", $2/1024/1024 }' /proc/meminfo)GB
_EOL_
  curl -s -X POST -d chat_id="${CHAT_ID}" -d parse_mode=html -d text="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendMessage
  # Start the build
  ${MAKE_COMMAND} 2>&1 | tee "${ROM}"-build.log
  # Build failed!
  if [ ! -f "${OUT}"/*"${TYPE}"*.zip ]; then
    echo -e "${green}Build compilation failed, I will shutdown the instance in ${SHUTDOWN_TIME} minutes! ${nocol}"
    curl -F chat_id="${CHAT_ID}" -F document=@"${ROM_FOLDER}"/"${ROM}"-build.log -F caption="Build Failed!" https://api.telegram.org/bot"${TOKEN}"/sendDocument
    sleep "${SHUTDOWN_TIME}"m
    sudo shutdown -h now
  fi
  # Build Sucessfull!
  BUILD_END=$(date +"%s")
  DIFF=$((BUILD_END - BUILD_START))
  # Send msg to telegram
  read -r -d '' MESSAGE <<-_EOL_
<strong>BUILD SUCCESSFULL!</strong>
<strong>Time :</strong> $((DIFF / 60)) minutes and $((DIFF % 60)) seconds
<strong>Date :</strong> $(date +"%Y-%m-%d")
_EOL_
  curl -s -X POST -d chat_id=$CHAT_ID -d parse_mode=html -d text="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendMessage
  curl -F chat_id="${CHAT_ID}" -F document=@"${ROM_FOLDER}"/"${ROM}"-build.log -F caption="" https://api.telegram.org/bot"${TOKEN}"/sendDocument
  # Autoupload if set
  if [ "$AUTO_UPLOAD" = false ]; then
    :
  else
    echo "Uploading file..."
    ${AUTO_UPLOAD}
  fi
  # Shutdown instance to save credits :P
  sleep "${SHUTDOWN_TIME}"m
  sudo shutdown -h now
}

check_config_file() {
  # Checking if rom config file is present and import it
  if [ ! -f "conf.rom" ]; then
    echo "${green}Rom config not found!"
    echo "Export config file using buildbot -ec and configure it first! ${nocol}"
    exit 1
  fi
}

check_rom_dir() {
  # Checking if this is a rom directory and repo is initialised
  if [ ! -d ".repo" ]; then
    echo "${green}Not a rom directory!"
    echo "Please make sure you're in the rom directory.${nocol}"
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
  echo "${green}This can take 15 mins! Do not Cancel! ${nocol}"
  make clobber -j$( nproc --all ) && make clean -j$( nproc --all )
}

free_up_ram() {
  # Cleaning RAM
  sudo sh -c "sync"
  sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"
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
-br, --build-rom        Build rom
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
  echo "${green}This can take 5 to 10 mins! Do not Cancel! ${nocol}"
  make installclean -j$( nproc --all ) && make deviceclean -j$( nproc --all )
}

sync_rom() {
  check_rom_dir
  check_config_file
  free_up_ram
  source conf.rom
  SYNC_START=$(date +"%s")
  # Report to tg group/channel
  read -r -d '' MESSAGE <<-_EOL_
<strong>Sync Started! @</strong> $(date "+%I:%M%p") ($(date +"%Z%:z"))
<strong>Syncing:</strong> ${ROM_NAME}
_EOL_
  curl -s -X POST -d chat_id="${CHAT_ID}" -d parse_mode=html -d text="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendMessage
  # Start syncing
  # Insert with atguments if set in config sync variable
  if [ "${SYNC_ARGUMENTS}" = false ]; then
    repo sync
  else
    repo sync "${SYNC_ARGUMENTS}"
  fi
  SYNC_END=$(date +"%s")
  DIFF=$((SYNC_END - SYNC_START))
  # Sync succeded! report to tg group/channel
  read -r -d '' MESSAGE <<-_EOL_
<strong>Sync Finished!</strong>
<strong>Time :</strong> $((DIFF / 60)) minutes and $((DIFF % 60)) seconds
_EOL_
  curl -s -X POST -d chat_id="${CHAT_ID}" -d parse_mode=html -d text="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendMessage
}

### Main program ###
case ${@} in
  -br|--build-rom)
    echo ""
    build_rom
    echo ""
    exit 0
  ;;
  -cb|--clean-build)
    echo ""
    clean_build
    echo ""
    exit 0
  ;;
  -ec|--export-config)
    echo ""
    check_rom_dir
    # Checking if rom config file is present to prevent overwrite
    if [ ! -f "conf.rom" ]; then
      # Export conf file to rom dir
      cat >conf.rom <<-'_EOL_'
# Build-Bot Configuration file
# Adapt it for your rom
# Make sure that values are always inside quotes (single or double)
ROM_NAME="BlissROM"
ROM="bliss"
DEVICE="tissot"
TARGET="user"
BUILD_TYPE="OFFICIAL"
PRECOMPILE_METALAVA="false" # Enable if less than 16GB RAM
SYNC_ARGUMENTS="false" # Set arguments in here to use them with sync, ex "-c -j$(nproc --all) --no-tags --no-clone-bundle --force-sync"
MAKE_COMMAND="blissify tissot" # Enter your full build command inside quotes, ex. mka bacon, blissify tissot, ./rom-build.sh, etc
ROM_FOLDER="${PWD}" # Use for getting location of your rom directory root
SHUTDOWN_TIME="5" # Minutes after which the bot will trigger shutdown when specifed
OUT="${ROM_FOLDER}"/out/target/product/"${DEVICE}"
# Enter your full upload command here inside quotes to enable it, make sure you enter part of filename as well
# Ex "mega-put ${OUT}/Bliss*.zip Tst_Folder/"
AUTO_UPLOAD="false"
# Exports
#export JAVA_OPTIONS=-Xmx4g # Java heapsize
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
      exit 1
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
