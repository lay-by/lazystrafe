# Overview

LazyStrafe is a tap-strafe script for Titanfall 2 players on linux. Once configured, simply hold down A or D to airstrafe much faster than the game engine allows with regular strafing. Keyboard nput is read directly from /dev/input/ and xdotool is used to send keystrokes. 

# Installation
### Requirements
- Nim ([www.nim-lang.org](http://www.nim-lang.org "www.nim-lang.org"))
- xdotool
- root priviledges

### Procedure
clone this repo and enter the directory with`git clone LINKHERE && cs lazystrafe`

compile the script with`nim c -d:release lazystrafe.nim`

execute as superuser with`sudo ./lazystrafe`

Once compiled, you may want to move the binary to /usr/local/bin/ or a similar bin folder.
