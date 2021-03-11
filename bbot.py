#!/usr/bin/env python3
#
#-# Build-Bot
#-# By @Sohil876
#-# https://github.com/Sohil876/Build-Bot
#

from configparser import ConfigParser
from os import getcwd, path
from pyfiglet import figlet_format
from sys import argv as arg, exit as sys_exit

# Vars
rom_folder = getcwd() # For getting location of rom directory root
config = ConfigParser(allow_no_value=True)
configfile_name = rom_folder + '/bbot.conf'
if path.isfile(configfile_name):
    config.read(configfile_name)
    rom_name = config['rom']['rom_name']
    rom_code_name = config['rom']['rom_code_name']
    rom_device = config['rom']['device']
    rom_target = config['rom']['target']
    build_command = config['build']['build_command']
    sync_arguments = config['sync']['sync_arguments']
    out = rom_folder + '/out/target/product/' + rom_device


#Functions
def check_conf_file():
    if path.isfile(configfile_name):
        return True
    else:
        return False

def check_rom_dir():
    if path.isdir('.repo'):
        return True
    else:
        return False

def bbot_conf_export():
    if check_conf_file() == True:
        print('Config file already exists!')
        sys_exit(1)
    else:
        config.add_section('rom')
        config.set('rom', 'rom_name', 'BlissROMs')
        config.set('rom', 'rom_code_name', 'bliss')
        config.set('rom', 'device', 'tissot')
        config.set('rom', 'target', 'user')
        config.set('rom', 'build_type', 'OFFICIAL')
        config.add_section('sync')
        config.set('sync', 'sync_arguments', 'sync -c -j$(nproc --all) --no-tags --no-clone-bundle --optimized-fetch --prune')
        config.set('sync','shutdown_after_sync', 'false')
        config.add_section('build')
        config.set('build', 'build_command', 'blissify tissot')
        config.set('build', 'shutdown_after_build', 'false')
        config.add_section('other')
        config.set('other', 'shutdown_time', '7')
        config.set('other', 'token', 'UR_TOKEN')
        config.set('other', 'chat_id', 'UR TELEGRAM CHANNEL/GROUP ID')
        with open(configfile_name, 'w') as configfile:
            config.write(configfile)
        configfile.close()
        print('Exported configfile!')

def bbot_help():
    print(f'''
{figlet_format("Build-Bot", font="letters")}
{figlet_format("By :- Sohil876", font="digital")}
  -ec   Exports a sample config file to your current rom directory
  -h    Shows brief help
  ''')

# Switch case implementation
#arg = argv
switcher = {
    '-ec' : bbot_conf_export,
    '-h'  : bbot_help,
    }

if len(arg) == 2 and arg[1] in switcher:
    switcher[arg[1]]()
else:
    print(f'{figlet_format("Build-Bot", font="letters")}\n{figlet_format("By :- Sohil876", font="digital")}')
    print('Invalid argument!')
    print('See -h for list of arguments')
    sys_exit(1)

