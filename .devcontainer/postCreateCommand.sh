#!/bin/bash

# Init Anaconda
conda init bash
# Init Cron
sudo service cron start
# Init VNC
xrandr -s 1920x1080
# Install robot libraries
pip install --user -e /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat[browser]
rfbrowser init 
