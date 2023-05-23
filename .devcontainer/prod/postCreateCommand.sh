#!/bin/bash

# Init Anaconda
conda init bash 
rfbrowser init 
# Init Cron
sudo service cron start
# Init VNC
xrandr -s 1920x1080


# Assert ~/.cloudflared directory exists
if [ ! -d ~/.cloudflared ]; then
    echo No ~/.cloudflared directory found. The tunnel will not work.
    exit 1
fi
# Assert ~/.cloudflared/cert.pem exists
if [ ! -f ~/.cloudflared/cert.pem ]; then
    echo No ~/.cloudflared/cert.pem file found. The tunnel will not work.
    exit 1
fi

# Start the tunnel
cloudflared tunnel run ciclozero_bridge &

# Start streamlit application
/opt/conda/envs/web_env/bin/python /opt/conda/envs/web_env/bin/streamlit run web/app.py
