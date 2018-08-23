ARG PLATFORM="ubuntu"

# FROM ubuntu:14.04
FROM ${PLATFORM}

ARG BROWSER
ARG CHROME_VERSION
ARG CHROME_INSTALL_CMD
ARG CHROME_RELEASE
ARG CHROME_REPO
ARG CHROME_DRIVER_VER
ARG FIREFOX_REL
ARG FIREFOX_VER
ARG GECKODRIVER_VER
ARG PYTHON_VERSION="3"

ENV DISPLAY=:99

RUN echo "-----------BEGINNING SYSTEM SETUP------------" \
    && if [ "$BROWSER" = ""]; then BROWSER="chrome"; fi \
    && if [ "$BROWSER" = "chrome"]; then \
    && if [ "$CHROME_VERSION" = "" ]; then CHROME_VERSION="current"; fi \
    && if [ "$CHROME_RELEASE" = "" ]; then CHROME_RELEASE="stable"; fi \
    && if [ "$CHROME_REPO" = "" ]; then CHROME_REPO="main"; fi \
    && if [ "$CHROME_DRIVER_VER" = "``" ]; then CHROME_DRIVER_VER="main"; fi \
    && echo "Image will be built with Chrome browser verion type of $CHROME_VERSION" \
    && echo "---------------------------------------" \
    && echo "The command to install chrome is $CHROME_INSTALL_CMD" \
    && echo "---------------------------------------" \
    && echo "The chrome release is $CHROME_RELEASE" \
    && echo "---------------------------------------" \
    && echo "The chrome repository is $CHROME_REPO" \
    && echo "---------------------------------------" \
    && echo "The selenium chrome driver version is $CHROME_DRIVER_VER" \
    && fi \
    && if [ "$BROWSER" = "firefox" ]; then \
    && if [ "$FIREFOX_VERSION" = "" ]; then FIREFOX_VERSION="current"; fi \
    && if [ "$FIREFOX_RELEASE" = "" ]; then FIREFOX_RELEASE="stable"; fi \
    && if [ "$FIREFOX_REPO" = "" ]; then FIREFOX_REPO="main"; fi \
    && if [ "$GECKO_DRIVER_VER" = "" ]; then GECKO_DRIVER_VER="main"; fi \
    && echo "Image will be built with FireFox browser verion type of $FIREFOX_VERSION" \
    && echo "---------------------------------------" \
    && echo "The command to install firefox is $FIREFOX_INSTALL_CMD" \
    && echo "---------------------------------------" \
    && echo "The Firefox release is $FIREFOX_RELEASE" \
    && echo "---------------------------------------" \
    && echo "The Firefox repository is $FIREFOX_REPO" \
    && echo "---------------------------------------" \
    && echo "The selenium firefox driver version is $FIREFOX_DRIVER_VER" \
    && fi \
    && echo "---------------------------------------" \
    && echo "Python version is $PYTHON_VERSION" \
    && apt-get update --assume-yes && apt-get install --assume-yes \
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
        gnupg \
        gnupg2 \
        gnupg1 \
    && echo "---------------------------------------" \
    && echo 'First apt-get update/install is completed' \
    && echo "---------------------------------------" \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/ubuntu/14.04/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && echo "---------------------------------------" \
    && echo 'Get odbc packages' \
    && echo "---------------------------------------" \
    && apt-get update -y \
    && ACCEPT_EULA=Y apt-get -y install msodbcsql17  \
    && ACCEPT_EULA=Y apt-get install -y  mssql-tools \
    && ACCEPT_EULA=Y apt-get install -y  unixodbc-dev \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
    && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
    && echo "---------------------------------------" \
    && if [ "$PYTHON_VERSION" = "" ; then echo "Python 2 being installed" ; else echo "Python 3 being installed" ; fi \
    && echo "---------------------------------------" \
    && if [ "$PYTHON_VERSION" = "3" ] ; then echo "Starting python 3 and selenium install" apt-get update --assume-yes && apt-get install --assume-yes python3-pip \
    && pip3 install -U selenium behave pytest pyodbc requests ; fi \
    && if [ "$PYTHON_VERSION" != "3" ]; then echo "Starting python 2 and selenium install" apt-get install --assume-yes python-pip python \
    && pip install selenium behave pytest requests ; fi \
    && echo "---------------------------------------" \
    && if [ "$BROWSER" = "chrome"]; then \
    && echo $CHROME_VERSION \
    && echo "---------------------------------------" \
    && if [ "$CHROME_VERSION" = "previous" ]; then CHROME_RELEASE="bionic"; fi \
    && if [ "$CHROME_VERSION" = "previous" ]; then CHROME_REPO="universe"; fi \
    && if [ "$CHROME_VERSION" = "previous" ]; then CHROME_INSTALL_CMD="chromium-browser"; fi \
    && if [ "$CHROME_VERSION" = "beta" ]; then CHROME_INSTALL_CMD="google-chrome-beta"; fi \
    && if [ "$CHROME_VERSION" = "unstable" ]; then CHROME_INSTALL_CMD="google-chrome-unstable"; fi \
    && if [ "$CHROME_VERSION" = "current"  ]; then CHROME_INSTALL_CMD="google-chrome-stable"; fi \
    && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && if [ "$CHROME_VERSION" = "previous" ]; then cd /tmp \
    && mkdir -p chrome-deb \
    && cd chrome-deb || return \
    && sh -c echo http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list \
    && curl http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb --output /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb \
    && dpkg -i /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb; fi \
    && if [ "$CHROME_VERSION" = "current" ] || [ $CHROME_VERSION = "beta" ]; then sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get -y update \
    && apt-get install -y ${CHROME_INSTALL_CMD}; fi \
    && system_type=$(uname -m) \
    && echo "---------------------------------------" \
    && echo $system_type \
    && echo "---------------------------------------" \
    && if [ "$CHROME_VERSION" = "current" ]; then driver_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
    && if [ "$CHROME_VERSION" = "beta" ]; then driver_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
    && if [ "$CHROME_VERSION" = "previous" ]; then driver_ver="${CHROME_DRIVER_VER}"; fi \
    && echo "---------------------------------------" \
    && echo $driver_ver \
    && echo "---------------------------------------" \
    && if [ "$system_type" = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo "---------------------------------------" \
    && echo $bit \
    && echo "---------------------------------------" \
    && mkdir -p /tmp/chromedriver \
    && curl "https://chromedriver.storage.googleapis.com/${driver_ver}/chromedriver_linux${bit}.zip" > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && rm -rf /tmp/chromedriver \
    && chmod +x /usr/local/bin/chromedriver \
    && if [ "$CHROME_VERSION" = "previous" ]; then ln -snf '/usr/local/bin/chromium-browser /usr/bin/google-chrome'; fi \
    && if [ "$CHROME_VERSION" = "beta" ]; then ln -snf '/usr/bin/google-chrome-beta /usr/bin/google-chrome'; fi \
    && echo "---------------------------------------" \
    && echo "End of Chrome and Chrome driver install" \
    && echo "---------------------------------------" \
    && fi \
    && if [ "$BROWSER" = "firefox" ]; then \
    && echo "---------------------------------------" \
    && echo "Beginning Firefox and Gecko Driver Install"
    && echo "---------------------------------------" \
    && echo $FIREFOX_VER \
    && echo "---------------------------------------" \
    # && if [ "$FIREFOX_VER" = "previous" ]; then FIREFOX_RELEASE="bionic"; fi \
    # && if [ "$FIREFOX_VER" = "previous" ]; then FIREFOX_REPO="universe"; fi \
    # && if [ "$FIREFOX_VER" = "previous" ]; then FIREFOX_INSTALL_CMD="marionatte-browser-browser"; fi \
    # && if [ "$FIREFOX_VER" = "beta" ]; then FIREFOX_INSTALL_CMD="firefox-beta"; fi \
    # && if [ "$FIREFOX_VER" = "unstable" ]; then FIREFOX_INSTALL_CMD="firefox-unstable"; fi \
    && if [ "$FIREFOX_VER" = "current"  ]; then FIREFOX_INSTALL_CMD="firefox-stable"; fi \
    # && wget -qO- https://dl-ssl.firefox.com/linux/linux_signing_key.pub | apt-key add - \
    # && if [ "$FIREFOX_VERSION" = "previous" ]; then cd /tmp \
    # && mkdir -p firefox-deb \
    # && cd firefox-deb || return \
    # && sh -c echo http://security.ubuntu.com/ubuntu/pool/universe/c/marionatte-browser/marionatte-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb >> /etc/apt/sources.list.d/google-chrome-${FIREFOX_RELEASE}.list \
    # && curl http://security.ubuntu.com/ubuntu/pool/universe/c/marionatte-browser/marionatte-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb --output /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb \
    # && dpkg -i /tmp/chrome-deb/chromium-browser_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb; fi \
    # && if [ "$FIREFOX_VERSION" = "current" ] || [ $FIREFOX_VERSION = "beta" ]; then sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
    # && apt-get -y update \
    # && apt-get install -y ${FIREFOX_INSTALL_CMD}; fi \
    && system_type=$(uname -m) \
    && echo "---------------------------------------" \
    && echo $system_type \
    && echo "---------------------------------------" \
    && if [ "$FIREFOX_REL" = "current" ]; then apt-get update && apt-get install -y firefox; fi \
    # && if [ "$FIREFOX_VERSION" = "beta" ]; then driver_ver="`wget -qO- http://geckodriver.storage.firefoxapis.com/LATEST_RELEASE`"; fi \
    # && if [ "$FIREFOX_VERSION" = "previous" ]; then driver_ver="${FIREFOX_DRIVER_VER}"; fi \
    && echo "---------------------------------------" \
    # && echo $driver_ver \
    && echo "---------------------------------------" \
    && if [ "$system_type" = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo "---------------------------------------" \
    && echo $bit \
    && echo "---------------------------------------" \
    && mkdir -p /tmp/geckodriver \
    && wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v$GECKODRIVER_VERSION/geckodriver-v$GECKODRIVER_VERSION-linux64.tar.gz > /tmp/geckodriver.tar.gz \
    && tar -xf /tmp/geckodriver.tar.gz -C /usr/local/bin \
    && rm -rf /tmp/geckodriver.tar.gz \
    && chmod +x /usr/local/bin/geckodriver \
    #&& if [ "$FIREFOX_VERSION" = "previous" ]; then ln -snf '/usr/local/bin/firefox-browser /usr/bin/firefox'; fi \
    #&& if [ "$FIREFOX_VERSION" = "beta" ]; then ln -snf '/usr/bin/firefox-beta /usr/bin/firefox'; fi \
    && fi \
    && echo "-----------ENDING SYSTEM SETUP------------"
    && mkdir -p /tmp \


# Define default command.
CMD ["bash"]
