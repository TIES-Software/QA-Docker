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

# Chrome BROWSER version parameters to setup & install
RUN echo $CHROME_VERSION \
    && if [ $CHROME_VERSION = "previous" ]; then CHROME_RELEASE='bionic'; fi \
    && if [ $CHROME_VERSION = "previous" ]; then CHROME_REPO='universe'; fi \
    && if [ $CHROME_VERSION = "previous" ]; then CHROME_INSTALL_CMD='chromium-browser'; fi \
    && if [ $CHROME_VERSION = "beta" ]; then CHROME_INSTALL_CMD='google-chrome-beta'; fi \
    && if [ $CHROME_VERSION = "unstable" ]; then CHROME_INSTALL_CMD='google-chrome-unstable'; fi \
    && echo $CHROME_INSTALL_CMD $CHROME_RELEASE $CHROME_REPO $CHROME_DRIVER_VER \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/google.list' \
    && apt-get -y update \
    && apt-get install -y ${CHROME_INSTALL_CMD}

RUN system_type=$(uname -m) \
    && RUN echo $system_type \
    && echo $CHROME_DRIVER_VER \
    && if [ $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
    && if [ ! $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="http://chromedriver.storage.googleapis.com/index.html?path=${DRIVER_VER}"; fi \
    && echo $chrome_ver \
    && if [ $system_type = "i686" ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo $bit \
    && mkdir -p /tmp/chromedriver \
    && echo $chrome_ver \
    && curl "${chrome_ver}/chromedriver_linux$bit.zip" > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && rm -rf /tmp/chromedriver \
    && chmod +x /usr/local/bin/chromedriver

RUN echo google-chrome --version
RUN echo /usr/local/bin/chromium-browser --version

FROM tiessoftware/feepay_tests:updates

# Define default command.
CMD ["bash"]
