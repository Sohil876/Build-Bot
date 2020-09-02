#!/bin/bash
### Build-Bot By @Sohil876 ###

# Color Code Script
red='\e[0;31m'             # Red
green='\e[0;32m'        # Green
#yellow='\e[0;33m'       # Yellow
#purple='\e[0;35m'       # Purple
cyan='\e[0;36m'          # Cyan
white='\e[0;37m'        # White
nocol='\033[0m'         # Default

# Functions
banner() {
  echo -e "${green}--------------------------------------"
  echo "              BUILD-BOT"
  echo -e "          ${green}(${cyan}By ${green}-:- ${white}Sohil876${green})${nocol}"
  echo -e "${green}--------------------------------------${nocol}"
}

help() {
  cat <<_EOL_
  $(echo "")
  $(echo -e "${green}Usage:${nocol}")
  -h,  --help        Show brief help
  $(echo "")
_EOL_
}

# Main program
case ${@} in
  -h|--help)
    banner
    help
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