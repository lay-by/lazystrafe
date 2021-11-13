#LazyStrafe, a Titanfall2 tap strafe script for Counter Strike vets who don't want to learn how to tap strafe, but also use linux (so basically just me lol).
import std/bitops, std/streams, std/strutils, std/os, std/sequtils, osproc
const 
    banner = "\e[1;34m\n\n\n@@@        @@@@@@   @@@@@@@@  @@@ @@@   @@@@@@   @@@@@@@  @@@@@@@    @@@@@@   @@@@@@@@  @@@@@@@@\n@@@       @@@@@@@@  @@@@@@@@  @@@ @@@  @@@@@@@   @@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@  @@@@@@@@\n@@!       @@!  @@@       @@!  @@! !@@  !@@         @@!    @@!  @@@  @@!  @@@  @@!       @@!     \n!@!       !@!  @!@      !@!   !@! @!!  !@!         !@!    !@!  @!@  !@!  @!@  !@!       !@!     \n@!!       @!@!@!@!     @!!     !@!@!   !!@@!!      @!!    @!@!!@!   @!@!@!@!  @!!!:!    @!!!:!  \n!!!       !!!@!!!!    !!!       @!!!    !!@!!!     !!!    !!@!@!    !!!@!!!!  !!!!!:    !!!!!:  \n!!:       !!:  !!!   !!:        !!:         !:!    !!:    !!: :!!   !!:  !!!  !!:       !!:     \n :!:      :!:  !:!  :!:         :!:        !:!     :!:    :!:  !:!  :!:  !:!  :!:       :!:     \n :: ::::  ::   :::   :: ::::     ::    :::: ::      ::    ::   :::  ::   :::   ::        :: ::::\n: :: : :   :   : :  : :: : :     :     :: : :       :      :   : :   :   : :   :        : :: :: \n\n\n\e[1;0m"
    keydown = 4096
    keyup = 0
echo banner

#check root privs
try:
    discard readLines("/root/.bash_logout")
except Exception:
    echo "You do not have root permissions. Try executing as sudo. Exiting..."
    quit(1)


var
    keys = newSeq[uint16](4)
    keylabels = @['w', 'a', 's', 'd']
    KBDPATH:string
    fs:Stream
    keystates = newSeq[bool](4)
#[
    data structure
    timeval : 16 bytes
    type : 2 bytes
    code : 2 bytes
    value : 4 bytes

    total buffer length: 24 bytes
]#
type
    input_event = object
    #ignore timeval and type, not needed
        code: uint16 #2 bytes
        value: uint32 #4 bytes

proc decode(a:array[24, uint8]):input_event=
    result.code = rotateLeftBits(a[18], 4) + a[19]    
    for i in 20..23:
        result.value += a[i]
        if i != 23:
            result.value = rotateLeftBits(result.value, 4)

var createConfig = true
if fileExists(".lazystrafeconfig"):
    #read config file
    let config:seq[string] = splitLines(readFile(".lazystrafeconfig"))
    #verify config
    var tempkeyflag = true
    for i, key in keylabels:
        if config[i+1].parseInt == 0:
            tempkeyflag = false
    if (config[0].contains("event-kbd") and tempkeyflag):
        echo "Config Loaded"
        createConfig = false
        KBDPATH = config[0]
        for i in 0..<keylabels.len:
            keys[i] = uint16(config[i+1].parseInt())
        fs = newFileStream(KBDPATH, fmRead)

if createConfig or paramCount() > 0 and paramStr(1).toLower == "config":
    echo "No config found. Creating new one"
    echo "If you input a wrong key, you can rerun this config setup with 'sudo ./lazystrafe config'"
    let keyboards:seq[string] = toSeq(walkPattern("/dev/input/by-id/*-event-kbd"))
    if keyboards.len == 0: echo "No keyboard detected. Something isn't right here."
    if keyboards.len == 1: KBDPATH = keyboards[0]
    if keyboards.len > 1:
        for i, str in keyboards:
            echo $i & " : " & str
        echo "Select your keyboard (0-" & $(keyboards.len-1) & ")"
        while true:
            var input = readLine(stdin).parseInt
            if input >= 0 and input < keyboards.len:
                KBDPATH = keyboards[input]
                fs = newFileStream(KBDPATH, fmRead)
                break
            echo "Invalid input"
    
    #map keys 
    echo "Do not press any keys until prompted to"
    for i, keylabel in keylabels:        
        sleep(1000)
        echo "Press your " & $keylabel & " key."
        while true:
            var buf: array[24, uint8]    
            fs.read(buf)
            if buf.len == 24:
                var event = decode(buf)
                if event.value == keyDown:
                    keys[i] = event.code
                    echo $keylabel & " key registered."
                    break
        echo "Release all keys."
        sleep(1000)
        
    
    #save config
    var fwrite = KBDPATH
    for key in keys: 
        fwrite &= "\n" & $key
    writeFile(".lazystrafeconfig", fwrite)
    echo "config setup finished."
    sleep(3000)
    discard execCmd "clear"
    echo banner

echo "LazyStrafe is Active. Run 'sudo ./lazystrafe config' to change config. Hit CTRL+C to exit"

while true:
    var buf: array[24, uint8]    
    fs.read(buf)
    if buf.len == 24:
        var event = decode(buf)
        for i, key in keys:
            if event.code == key and event.value == keydown: keystates[i] = true
            if event.code == key and event.value == keyup: keystates[i] = false

    #if a or d are held down
    if (keystates[1] or keystates[3]) and not ( keystates[0] or keystates[2] ):
        discard execCmd "xdotool key w"
    #if a or d and w are held down
    if (keystates[1] or keystates[3]) and keystates[0]:
        discard execCmd "xte 'keydown w'"