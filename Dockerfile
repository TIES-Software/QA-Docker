FROM debian:jessie

ARG CHROME_VERSION=current
ARG CHROME_INSTALL_CMD=google-chrome-stable
ARG CHROME_RELEASE=stable
ARG CHROME_REPO=main
ARG CHROME_DRIVER_VER
# ARG DRIVER_URL
ARG DRIVER_VER
ENV DISPLAY=:99

RUN apt-get update && apt-get install -y \
        python \
        python-pip \
        curl \
        unzip \
        wget \
        apt-transport-https \
    	ca-certificates \
        libgconf-2-4

RUN pip install pytest \
        selenium \
        behave

# Chrome BROWSER version parameters to setup
RUN echo $CHROME_VERSION
RUN if [ $CHROME_VERSION='previous' ]; then CHROME_RELEASE='bionic'; fi
RUN if [ $CHROME_VERSION='previous' ]; then CHROME_REPO='universe'; fi
RUN if [ $CHROME_VERSION='previous' ]; then CHROME_INSTALL_CMD='chromium-browser'; fi
RUN if [ $CHROME_VERSION='beta' ]; then CHROME_INSTALL_CMD='google-chrome-beta'; fi
RUN if [ $CHROME_VERSION='unstable' ]; then CHROME_INSTALL_CMD='google-chrome-unstable'; fi

# Selenium chromedriver version parameters to setup
# RUN if [ $CHROME_DRIVER_VER='latest']; then DRIVER_URL=http://chromedriver.storage.googleapis.com/LATEST_RELEASE; fi
# RUN if [ ! $CHROME_DRIVER_VER='latest']; then CHROME_DRIVER_VER=DRIVER_VER; fi
# RUN if [ ! $CHROME_DRIVER_VER='latest' ]; then DRIVER_URL='https://chromedriver.storage.googleapis.com/index.html?path=${CHROME_DRIVER_VER}/'; fi

# display in log file for trouble shooting
RUN echo $CHROME_INSTALL_CMD
RUN echo $CHROME_RELEASE
RUN echo $CHROME_REPO
RUN echo $CHROME_DRIVER_VER

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/${CHROME_INSTALL_CMD}.list'
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/google.list'
RUN apt-get -y update
RUN apt-get install -y ${CHROME_INSTALL_CMD}

RUN system_type=$(uname -m) \
    && echo $system_type \
    && if [ $CHROME_DRIVER_VER='latest' ]; then chrome_ver="wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
    && if [ ! CHROME_DRIVER_VER='latest' ]; then chrome_ver='index.html?path=${DRIVER_VER}'; fi \
    && echo $chrome_ver
    && if [ $system_type = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo $bit \
    && mkdir -p /tmp/chromedriver \
    && curl http://chromedriver.storage.googleapis.com/$chrome_ver/chromedriver_linux$bit.zip > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && rm -rf /tmp/chromedriver \
    && chmod +x /usr/local/bin/chromedriver

RUN echo google-chrome --version
RUN echo /usr/local/bin/chromium-browser --version

FROM tiessoftware/feepay_tests:updates

# Define default command.
CMD ["bash"]
