# Overview

LazyStrafe is a tap-strafe script for Titanfall 2 players on linux/proton. Once configured, hold down A or D to airstrafe much faster than the game engine allows with regular strafing. Keyboard input is read directly from /dev/input/ and xdotool/xte is used to send keystrokes. 

# Installation
### Requirements
- Nim ([www.nim-lang.org](http://www.nim-lang.org "www.nim-lang.org"))
- xdotool
- xte from xautomation
- root priviledges

### Procedure
clone this repo and enter the directory with`git clone https://github.com/lay-by/lazystrafe.git && cd lazystrafe`

compile the script with`nim c -d:release lazystrafe.nim`

execute as superuser with`sudo ./lazystrafe`

Once compiled, you will likely want to move the compiled binary to a bin folder or add it to your $PATH variable. 
