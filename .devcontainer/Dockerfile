FROM mcr.microsoft.com/devcontainers/miniconda:0-3 AS base

ARG UNAME=vscode
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG GITHUB_TOKEN

# This image already has a user vscode
USER root
# RUN groupmod -g $GROUP_ID $UNAME
# RUN usermod -u $USER_ID -g $GROUP_ID $UNAME

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends poppler-utils ffmpeg libsm6 libxext6 cron

# Install Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt install ./google-chrome-stable_current_amd64.deb -y

ENV PATH=/home/$UNAME/.local/bin:$PATH

RUN mkdir -p /tmp/pip-tmp && chown -R $USER_ID:$GROUP_ID /tmp/pip-tmp
RUN mkdir -p /tmp/conda-tmp/web && chown -R $USER_ID:$GROUP_ID /tmp/conda-tmp

USER $UNAME
# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
COPY conda.yaml* .devcontainer/noop.txt /tmp/conda-tmp/
RUN /opt/conda/bin/conda update -n base -c defaults conda
RUN if [ -f "/tmp/conda-tmp/conda.yaml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/conda.yaml; fi

COPY web/conda.yaml* .devcontainer/noop.txt /tmp/conda-tmp/web/
RUN ls -la /tmp/conda-tmp/web
RUN ls -la /tmp/conda-tmp
RUN if [ -f "/tmp/conda-tmp/conda.yaml" ]; then umask 0002 && /opt/conda/bin/conda env create -f /tmp/conda-tmp/web/conda.yaml; fi \
    && rm -rf /tmp/conda-tmp

# Change timezone
ENV TZ='/usr/share/zoneinfo/Europe/Madrid'
RUN sudo ln -snf $TZ /etc/localtime && echo "Europe/Madrid" > /etc/timezone

# Run cron service after container is started. sudo service cron start
# RUN sudo service cron start


FROM base AS prod 

USER root

ENV DBUS_SESSION_BUS_ADDRESS="autolaunch:" \
    VNC_RESOLUTION="1440x768x16" \
    VNC_DPI="96" \
    VNC_PORT="5901" \
    NOVNC_PORT="6080" \
    DISPLAY=":1" \
    LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8"

# Install cloudflared
RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && dpkg -i cloudflared-linux-amd64.deb
RUN chmod -R 777 /opt/conda

# Copy CicloZero files
COPY . /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero
WORKDIR /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero

# This is needed to avoid permissions errors when clonning with actions
RUN chown -R $UNAME:$UNAME /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero

COPY conda-prod.yaml /tmp/pip-tmp/conda-prod.yaml
COPY .devcontainer/resolve_conda_secret.py /tmp/pip-tmp/resolve_conda_secret.py

WORKDIR /tmp/pip-tmp
RUN python resolve_conda_secret.py --token $GITHUB_TOKEN
RUN conda env update -n base -f conda_pass.yaml
RUN chmod -R a+rw /opt/conda/lib/python3.10/site-packages/Browser
RUN rm conda_pass.yaml

WORKDIR /workspaces/ai-butlerhat/data-butlerhat/robotframework-butlerhat/TestSuites/CicloZero

USER $UNAME
CMD ["bash", "./.devcontainer/postCreateCommand.sh"]