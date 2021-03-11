#!/usr/bin/env python3
#
#-# Build-Bot
#-# By @Sohil876
#-# https://github.com/Sohil876/Build-Bot
#

from sys import argv as arg, exit as sys_exit

# Vars


#Functions
def bbot_help():
    print('''
  -h    Shows brief help
  ''')

# Switch case implementation
#arg = argv
switcher = {
    '-h' : bbot_help,
    }

if len(arg) == 2 and arg[1] in switcher:
    switcher[arg[1]]()
else:
    print('Invalid argument!')
    print('See -h for list of arguments')
    sys_exit(1)

