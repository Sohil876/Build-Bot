#!/usr/bin/env python3
#
#-# Build-Bot
#-# By @Sohil876
#-# https://github.com/Sohil876/Build-Bot
#

from configparser import ConfigParser
from datetime import datetime
from glob import glob
from os import getcwd, listdir, path, remove
from psutil import cpu_count, virtual_memory
from pyfiglet import figlet_format
from subprocess import call
from sys import argv as arg, exit as sys_exit
from time import gmtime, strftime, time
from telegram import Bot, ParseMode


# Vars
today = datetime.now().strftime('%I:%M %p | %d/%m/%Y')
rom_folder = getcwd()
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
    bot = Bot(token=config['other']['token'])
    chat_id = config['other']['chat_id']

# Functions
def build_rom():
    if check_rom_dir() == False:
        print('You need to be in the root of rom directory!')
        sys_exit(1)
    if check_conf_file() == False:
        print('You need to export and configure the config file first!')
        sys_exit(1)
    if path.isdir(out):
        for file in listdir(out):
            if file.endswith('.zip') or file.endswith('.md5'):
                remove(out + '/' + file)
    # Start Build
    start_time = time()
    message = (
    f'<b>Build Started!</b>\n'
    f'<b>@</b> {today}\n'
    f'<b>CPUs :</b> {cpu_count(logical=True)} <b>|</b> <b>RAM :</b> {get_size(virtual_memory().total)}\n'
    f'<b>Building :</b> {rom_name}\n'
    f'<b>Build Type :</b> {config["rom"]["build_type"]}\n'
    f'<b>Device :</b> {rom_device}\n'
    f'<b>Target :</b> {rom_target}'
    )
    bot.send_message(chat_id=chat_id, text=message, parse_mode=ParseMode.HTML)
    call(f'unbuffer bash -c "source build/envsetup.sh && lunch {rom_code_name}_{rom_device}-{rom_target} 2>&1 | tee {rom_folder}/{rom_code_name}-build.log && {build_command} 2>&1 | tee -a {rom_folder}/{rom_code_name}-build.log"', universal_newlines=True, shell=True)
    # Build failed
    if len(glob(out + '/' + '*.zip')) == 0:
        total_time = strftime("%H:%M:%S", gmtime(round(time() - start_time)))
        print('Build Failed!')
        message = (
        f'<b>BUILD FAILED!</b>\n'
        f'<b>Time :</b> {total_time}'
        )
        bot.send_document(chat_id=chat_id, caption=message, parse_mode=ParseMode.HTML, document=open(f'{rom_folder}/{rom_code_name}-build.log', 'rb'))
        sys_exit(1)
    # Build Sucessfull
    total_time = strftime('%H:%M:%S', gmtime(round(time() - start_time)))
    message = (
    f'<b>BUILD SUCCESSFULL!</b>\n'
    f'<b>Time :</b> {total_time} minutes'
    )
    bot.send_document(chat_id=chat_id, caption=message, parse_mode=ParseMode.HTML, document=open(f'{rom_folder}/{rom_code_name}-build.log', 'rb'))

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

def clear_ram():
    call('sudo sh -c "sync"', shell=True)
    call('sudo sh -c "echo 3 > /proc/sys/vm/drop_caches"', shell=True)
    print('RAM CLEARED!')
    call('free -h', shell=True)

def bbot_conf_export():
    if check_conf_file() == True:
        print('Config file already exists!')
        sys_exit(0)
    elif check_rom_dir() == False:
        print('You need to be in rom root dir to export config!')
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
        config.set('other', 'token', 'UR_BOT_TOKEN')
        config.set('other', 'chat_id', 'UR TELEGRAM CHANNEL/GROUP ID')
        with open(configfile_name, 'w') as configfile:
            config.write(configfile)
        configfile.close()
        print('Exported configfile!')

def device_clean():
    if check_rom_dir() == True:
        call('bash -c "source build/envsetup.sh && make installclean -j$(nproc --all)"', shell=True)
        print('Running DeviceClean on build...')
        print('This can take from 5-15 mins! Do not Cancel!')
    else:
        print('Make sure you are in rom directory!')
        sys_exit(1)

def get_size(inbytes, suffix='B'):
    factor = 1024
    for unit in ['', 'K', 'M', 'G', 'T', 'P']:
        if inbytes < factor:
            return f'{inbytes:.2f}{unit}{suffix}'
        inbytes /= factor

def bbot_help():
    print(f'''
{figlet_format("Build-Bot", font="letters")}
{figlet_format("By :- Sohil876", font="digital")}
  -h    Shows brief help
  -ec   Exports a sample config file to your current rom directory
  -sr   Sync rom
  -br   Build rom
  -dc   Do device clean, removes whole out dir for clean building
  -ic   Do installclean for faster build
  -cr   Clears RAM, if you need to free up ram for some reason
  ''')

def install_clean():
    if check_rom_dir() == True:
        call('bash -c "source build/envsetup.sh && make deviceclean -j$(nproc --all)"', shell=True)
        print('Running DeviceClean on build...')
        print('This can take from 5-15 mins! Do not Cancel!')
    else:
        print('Make sure you are in rom directory!')
        sys_exit(1)

def bbot_sync_rom():
    if check_rom_dir() == False:
        print('You need to be in the root of rom directory!')
        sys_exit(1)
    if check_conf_file() == False:
        print('You need to export and configure the config file first!')
        sys_exit(1)
    # Start sync
    start_time = time()
    message = (
    f'<b>Sync Started!</b>\n'
    f'<b>@</b> {today}\n'
    f'<b>Syncing :</b> {rom_name}'
    )
    bot.send_message(chat_id=chat_id, text=message, parse_mode=ParseMode.HTML)
    call(f'bash -c "unbuffer repo {sync_arguments} 2>&1 | tee {rom_folder}/{rom_code_name}-sync.log"', universal_newlines=True, shell=True)
    # Sync Finished
    total_time = strftime("%H:%M:%S", gmtime(round(time() - start_time)))
    message = (
    f'<b>Sync Finished!</b>\n'
    f'<b>Time :</b> {total_time}'
    )
    bot.send_document(chat_id=chat_id, caption=message, parse_mode=ParseMode.HTML, document=open(f'{rom_folder}/{rom_code_name}-sync.log', 'rb'))
    

# Switch case implementation
switcher = {
    '-br' : build_rom,
    '-cr' : clear_ram,
    '-dc' : device_clean,
    '-ec' : bbot_conf_export,
    '-h'  : bbot_help,
    '-ic' : install_clean,
    '-sr' : bbot_sync_rom,
    }

if len(arg) == 2 and arg[1] in switcher:
    switcher[arg[1]]()
else:
    print(f'{figlet_format("Build-Bot", font="letters")}\n{figlet_format("By :- Sohil876", font="digital")}')
    print('Invalid argument!')
    print('See -h for list of arguments')
    sys_exit(1)

