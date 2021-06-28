#!/bin/bash

#additional rofi arguments to use for graphical input mode
#(-dmenu and -p are implied)
#ROFI_COMMAND="-theme dmenu"

#By default, youtube-handler will transform youtube-compatible urls to youtube ones.
#example: https://invidious.snopyta.org/watch?v=dQw4w9WgXcQ ---> https://www.youtube.com/watch?v=dQw4w9WgXcQ
#This behavior can be permanently disabled with the variable below, or temporatily altered at runtime, with '-n' and '-t' flags, which always take precedence, if specified.
TRANSFORM_YT=1

OPTIND=1

#mpv ipc control sockets
primaryIpcAddr=/tmp/mpq
secondaryIpcAddr=/tmp/mpqS

mflag=0
aflag=0
pflag=0
sflag=0

print_help() {

    echo "Usage: $0 [-a -d -h -p] (url)"
    echo "Arguments:"
    echo "-h or --help          print this help message"
    echo "-a or --append        append mode (add videos to existing queue)"
    echo "-m or --menu          graphical menu mode (requires rofi)"
    echo "-p or --print         just output the url to stdout without launching mpv"
    echo "-s or --secondary     use the secondary ipc queue"
    echo "-n or --no-transform  don't transform any urls"
    echo "-t or --transform     always transform applicable urls"

    echo ""
    
    echo "There are 2 ways to pass the url: graphical and command line"
    echo "url specified directly in the script invokation command is the command line way"
    echo "Use -m flag to call a rofi menu that will prompt you for a url"

    echo ""

    echo "Primary ipc queue is used by default"
    echo "In cli mode "-s" flag will switch to the secondary one"
    echo "In graphical mode you can append "S" after the video url to use the secondary queue"
    echo "(-s passed along with -m also works)"
    echo "(example) Video URL: https://youtube.com/watch?v=dQw4w9WgXcQ S"
    echo "Don't forget the spacebar as a delimiter!"
    echo "(passing S along with the url in cli mode is not supported)"

}

transform_yturl() {

    if [[ -n $(grep "watch?v" <<< $1) ]]
    then
        addr=$(sed 's/.*\/watch/https:\/\/youtube.com\/watch/g' <<< $1)
    elif [[ -n $(grep "?list=" <<< $1) ]]
    then
        addr=$(sed 's/.*\/playlist/https:\/\/youtube.com\/playlist/g' <<< $1)
    else
        addr=$1
    fi

    echo $addr
}

mpv_pass() {

    if [[ $sflag -eq 0 ]]
    then
        ipcAddr=$primaryIpcAddr
    else
        ipcAddr=$secondaryIpcAddr
    fi

    if [[ $aflag -eq 0 ]]
    then
        mpv --no-terminal --input-ipc-server=$ipcAddr $1 &
    else
        echo "loadfile $1 append-play" | socat - $ipcAddr
    fi

}

###Argument parsing stage

while [[ "$#" -gt 0 ]] 
do
    case $1 in
        -h|--help)
            print_help
            exit 0
            ;;
        -m|--menu)
            mflag=1
            ;;
        -a|--append)
            aflag=1
            ;;
        -p|--print)
            pflag=1
            ;;
        -s|--secondary)
            sflag=1
            ;;
        -n|--no-transform)
            TRANSFORM_YT=0
            ;;
        -t|--tranform)
            TRASFORM_YT=1
            ;;
        *)
            urlArg=$1
    esac
    shift
done

###Url fetching and parsing stage

if [[ $mflag -eq 1 ]]
then
    if [[ $aflag -eq 1 ]]
    then
        if [[ $sflag -eq 0 ]]
        then
            input=$(rofi -dmenu -p "Video URL (append mode): " $ROFI_COMMAND)
        else
            input=$(rofi -dmenu -p "[S] Video URL (append mode): " $ROFI_COMMAND)
        fi
    else
        if [[ $slfag -eq 0 ]]
        then
            input=$(rofi -dmenu -p "Video URL: " $ROFI_COMMAND)
        else
            input=$(rofi -dmenu -p "[S] Video URL: " $ROFI_COMMAND)
        fi
    fi
else
    input=$urlArg
fi

###Input processing stage

if [[ -z $input ]]
then
    if [[ $mflag -eq 0 ]]
    then
        echo "No URL specified. Quitting"
        print_help
    fi
    exit 1
else

    url=`cut -d " " -f 1 <<< $input`
    afterUrl=`cut -d " " -f 2 <<< $input`

    if [[ "$afterUrl" = "S" ]]
    then
        sflag=1
    fi

###Url transformation

    if [[ $TRANSFORM_YT -eq 0 ]]
    then
        outputUrl=$url
    else
        outputUrl=`transform_yturl $url`
    fi

###Output stage

    if [[ $pflag -eq 1 ]]
    then
        echo $outputUrl
    else
        mpv_pass $outputUrl
    fi
fi
