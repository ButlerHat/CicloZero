#!/bin/bash

# Init Anaconda
# conda init bash
# # Remove conda activate from bashrc
# sed -i '/conda activate/d' ~/.bashrc
# echo "conda activate robotframework" >> ~/.bashrc
# . ~/.bashrc
# # Init RFBrowser
# rfbrowser init
# Init Cron
sudo service cron start
# Init VNC
xrandr -s 1920x1080
# Install robot libraries
pip install --user -e /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat[browser_stealth]
