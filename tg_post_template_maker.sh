#!/bin/bash
# Telegram bot & group/channel info
TOKEN="Enter Bot Token" # Bot
CHAT_ID="Enter Chat ID" # Group/Channel
# Template variables
DOWN_LINK='<a href = "https://yourlink.com">Download</a>'
ROM_CL='<a href = "https://yourlink.com">ROM</a>'
DEVICE_CL='<a href = "https://yourlink.com">DEVICE</a>'
CHANNEL='<a href = "https://yourlink.com">Official Channel</a>'
GRP='<a href = "https://yourlink.com">Official Support Group</a>'
DEVICE_GRP='<a href = "https://yourlink.com">Device Specific Support</a>'
MAINTAINER="Unknown"
IMG="image.jpg"

# Message, html parsing enabled
read -r -d '' MESSAGE <<-_EOL_
#WhatEver #Tags #YouWannaAdd
  
<strong>Some ROM 10.x | Q</strong>
By <strong>${MAINTAINER}</strong>
  
Download: ${DOWN_LINK}
  
Changelog: ${ROM_CL} | ${DEVICE_CL}
  
Follow 👉🏻 ${CHANNEL}
Join 👉🏻 ${GRP}
Join 👉🏻 ${DEVICE_GRP}
_EOL_
# Send template message to telegram
curl -s -X POST -F chat_id="${CHAT_ID}" -F photo=@"${IMG}" -F parse_mode=html -F caption="${MESSAGE}" https://api.telegram.org/bot"${TOKEN}"/sendphoto
