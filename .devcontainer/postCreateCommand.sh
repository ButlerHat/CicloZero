#!/bin/bash

# Init Anaconda
conda init bash 
rfbrowser init 
# Init Cron
sudo service cron start
# Init VNC
xrandr -s 1920x1080
