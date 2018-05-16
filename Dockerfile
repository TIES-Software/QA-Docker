ARG PLATFORM="ubuntu:14.04"
ARG CHROME_VERSION='current'
ARG CHROME_INSTALL_CMD='google-chrome-unstable'
ARG CHROME_RELEASE='stable'
ARG CHROME_REPO='repo'
ARG CHROME_DRIVER_VER='2.37'
ARG DRIVER_VER='2.37'
# ENV CHROME_RELEASE='bionic'
# ENV CHROME_REPO='universe'
# ENV CHROME_VERSION='previous'
# ENV CHROME_DRIVER_VER
# ENV DRIVER_VER

# FROM ubuntu:14.04
FROM ${PLATFORM}

# ENV if [ $PLATFORM =- 'ubuntu' ]; then PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"; fi
ENV DISPLAY=:99

RUN echo "-----------BEGINNING SYSTEM SETUP------------" \
    && echo "Building image for platform type of ${PLATFORM}" \
    && echo "---------------------------------------" \
    && echo "Image will be build with Chrome browser verion type of ${CHROME_VERSION}" \
    && echo "---------------------------------------" \
    && echo "The command to install chrome is ${CHROME_INSTALL_CMD}" \
    && echo "---------------------------------------" \
    && echo "The chrome release is ${CHROME_RELEASE}" \
    && echo "---------------------------------------" \
    && echo "The chrome repository is $CHROME_REPO" \
    && echo "---------------------------------------" \
    && echo "The selenium chrome driver version is $CHROME_DRIVER_VER" \
    && echo "---------------------------------------" \
    && echo "(THIS ONE MAYBE REDUNTANT The selenium chrome driver version is $DRIVER_VER" \
    && echo "---------------------------------------" \
    && apt-get update && apt-get install -y \
        python \
        python-pip \
        curl \
        unzip \
        wget \
        apt-transport-https \
    	ca-certificates \
        libgconf-2-4 \
        libnss3 \
        libnspr4 \
        libasound2 \
        libatk-bridge2.0-0 \
        libnspr4 \
        xdg-utils \
        libatk1.0-0 \
        libxss1 \
        libx11-xcb1 \
        libc6 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libgdk-pixbuf2.0-0 \
        libgtk-3-0 \
        chromium-codecs-ffmpeg-extra \
    && pip install pytest \
    && pip install selenium \
    && pip install behave \
    && echo $CHROME_VERSION \
    # && if [ $CHROME_VERSION = "previous" ]; then CHROME_RELEASE='bionic'; fi \
    # && if [ $CHROME_VERSION = "previous" ]; then CHROME_REPO='universe'; fi \
    # && if [ $CHROME_VERSION = "previous" ]; then CHROME_INSTALL_CMD='chromium-browser'; fi \
    && if [ $CHROME_VERSION = "beta" ]; then CHROME_INSTALL_CMD='google-chrome-beta'; fi \
    && if [ $CHROME_VERSION = "unstable" ]; then CHROME_INSTALL_CMD='google-chrome-unstable'; fi \
    && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && if [ $CHROME_VERSION = 'current' ]; then sh -c echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list ; fi \
    && if [ $CHROME_VERSION = 'previous' ]; then cd /tmp \
    && mkdir chrome-deb \
    && cd chrome-deb \
#    && sh -c echo http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list \
    && curl http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb --output /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb \
    && dpkg -i /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb; fi \
    && if [ $CHROME_VERSION = 'current' ]; then apt-get -y update apt-get install -y ${CHROME_INSTALL_CMD}; fi \
    && system_type=$(uname -m) \
    && echo $system_type \
    && echo $CHROME_DRIVER_VER \
    && if [ $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
    && if [ ! $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="${DRIVER_VER}"; fi \
    && if [ $system_type = "i686" ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && mkdir -p /tmp/chromedriver \
    && echo $chrome_ver \
    && curl "https://chromedriver.storage.googleapis.com/${chrome_ver}/chromedriver_linux${bit}.zip" > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && rm -rf /tmp/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && echo "-----------ENDING SYSTEM SETUP------------"

# Define default command.
CMD ["bash"]
