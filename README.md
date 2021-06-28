# youtube-handler.sh

_youtube-handler.sh_ is a simple bash script that was created to simplify watching youtube videos (actually, any kind of videos, supported by youtube-dl) with mpv.

It handles 2 separate video queues, has a rofi graphical input method, as well as a cli. It can also transform youtube-compatible urls (e.g invidious) to actual youtube ones.

mpv ipc queues act like video playlists. You can append videos to one of the 2 available queues with this script.
To rearrange the videos in a queue inside mpv itself, you can use https://github.com/jonniek/mpv-playlistmanager

There are a few configuration variables at the beginning of the script.

*Dependencies:*
* mpv
* bash
* youtube-dl
* rofi _for graphical input mode_
* socat _for ipc queue handling_

*Usage:*

`./youtube-handler.sh [arguments] (url)`

*Arguments:*

```
    -h or --help          print the help message
    -a or --append        append mode (add videos to a queue)
    -m or --menu          graphical menu mode (requires rofi)
    -p or --print         just output the url to stdout without launching mpv
    -s or --secondary     use the secondary ipc queue (primary is used by default)
    -n or --no-transform  don't transform any urls
    -t or --transform     always transform applicable urls

    
    There are 2 ways to pass the url: graphical and command line
    Specifiying the url directly in the script invokation command is the command line way
    Use -m flag to call a rofi menu that will prompt you for a url


    Primary ipc queue is used by default
    In cli mode -s flag will switch to the secondary one
    In graphical mode you can append S after the video url to use the secondary queue
    (-s passed along with -m also works)
    (graphical mode example) Video URL: https://youtube.com/watch?v=dQw4w9WgXcQ S
    Don't forget the spacebar as a delimiter!
    (passing S along with the url in cli mode is not supported)
```
