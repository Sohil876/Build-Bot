# Build-Bot
**Requirements**
-  Python3
-  Dependencies:
   -  Python packages in `requirements.txt` file
   -  unbuffer from expect package (for ubuntu  `sudo apt install expect`)

**Instructions:**
-  Give `-h` argument to script for help and see available commands.
-  You have to export sample config file to your rom dir with `-ec` option first to sync/build roms, edit that `bbot.conf` file with some text editor, set your settings there correctly, done.
-   You can enable autoshutdown for after sync sucess and build sucess&fail with custom time in the `bbot.conf` file by setting the shutdown variable in sync (`shutdown_after_sync`) or build section (`shutdown_after_build`) to true.
-   Shutdown time is set in minute with `shutdown_time` value in `bbot.conf` file.
