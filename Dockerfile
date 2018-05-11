# FROM debian:jessie
FROM ubuntu:14.04

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
        libgtk-3-0

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
   && wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
   && if [ $CHROME_VERSION = 'current' ]; then sh -c echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list ; fi \
   && if [ $CHROME_VERSION = 'previous' ]; then cd /tmp \
   && mkdir chrome-deb \
   && cd chrome-deb \
#   && sh -c echo http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-browser_65.0.3325.181-0ubuntu1_amd64.deb >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list; fi \
   && sh -c echo http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-browser/chromium-chromedriver_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb >> /etc/apt/sources.list.d/google-chrome-${CHROME_RELEASE}.list; fi \
   && if [ $CHROME_VERSION = 'previous' ]; then curl http://security.ubuntu.com/ubuntu/pool/universe/c/chromium-chromedriver_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb --output /tmp/chrome-deb/chromium-chromedriver_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb \
   && dpkg -i /tmp/chrome-deb/chromium-chromedriver_65.0.3325.181-0ubuntu0.14.04.1_amd64.deb; fi \
   && if [ $CHROME_VERSION = 'current' ]; then apt-get -y update \
   && apt-get install -y ${CHROME_INSTALL_CMD}; fi

# Get selenium chromedriver TODO: Read from http://chromedriver.chromium.org/downloads
RUN system_type=$(uname -m) \
   && RUN echo $system_type \
   && echo $CHROME_DRIVER_VER \
   && if [ $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"; fi \
   && if [ ! $CHROME_DRIVER_VER = "latest" ]; then chrome_ver="${DRIVER_VER}"; fi \
   && echo $chrome_ver \
   && if [ $system_type = "i686" ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
   && echo $bit \
   && mkdir -p /tmp/chromedriver \
   && echo $chrome_ver \
   && curl "https://chromedriver.storage.googleapis.com/${chrome_ver}/chromedriver_linux${bit}.zip" > /tmp/chromedriver/chromedriver.zip \
   && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
   && rm -rf /tmp/chromedriver \
   && chmod +x /usr/local/bin/chromedriver

RUN echo google-chrome --version
RUN echo /usr/local/bin/chromium-browser --version

# #===============
# # Google Chrome
# #===============
# # TODO: Use Google fingerprint to verify downloads
# #  https://www.google.de/linuxrepositories/
# ARG EXPECTED_CHROME_VERSION="66.0.3359.139"
# ENV CHROME_URL="https://dl.google.com/linux/direct/" \
#     CHROME_BASE_DEB_PATH="/tmp/chrome_deb/google-chrome" \
#     GREP_ONLY_NUMS_VER="[0-9.]{2,20}"
#
# LABEL selenium_chrome_version "${EXPECTED_CHROME_VERSION}"
#
#
# # Layer size: huge: 196.3 MB
# RUN apt -qqy update \
#   && mkdir -p /tmp \
#   && cd /tmp/chrome_deb \
#   && wget -nv "${CHROME_URL}google-chrome-stable_current_amd64.deb" \
#           -O google-chrome-stable_current_amd64.deb \
#   && apt -qyy --no-install-recommends install google-chrome-stable_current_amd64 \
#   && rm -f google-chrome-stable_current_amd64.deb \
#
#
#
#   # && wget -nv ${CHROME_URL}/google-chrome-stable_current_amd64.deb -O /tmp/chrome-deb/google-chrome-stable_current_amd64.deb \
#   # && apt -qyy --no-install-recommends install /tmp/chrome-deb/google-chrome-stable_current_amd64.deb \
#   # && rm -f /tmp/chrome-deb/google-chrome-stable_current_amd64.deb \
#  # && rm -rf /tmp/chrome_deb\
#   && apt -qyy autoremove \
#   && rm -rf /var/lib/apt/lists/* \
#   && apt -qyy clean \
#   && export CH_STABLE_VER=$(/usr/bin/google-chrome-stable --version | grep -iEo "${GREP_ONLY_NUMS_VER}") \
#   && echo "CH_STABLE_VER:'${CH_STABLE_VER}' vs EXPECTED_CHROME_VERSION:'${EXPECTED_CHROME_VERSION}'" \
#   && [ "${CH_STABLE_VER}" = "${EXPECTED_CHROME_VERSION}" ] || fail
#
# # We have a wrapper for /opt/google/chrome/google-chrome
# RUN mv /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome-base
# COPY selenium-node-chrome/opt /opt
# COPY lib/* /usr/lib/
#
# #==================
# # Chrome webdriver
# #==================
# # How to get cpu arch dynamically: $(lscpu | grep Architecture | sed "s/^.*_//")
# ARG CHROME_DRIVER_VERSION="2.38"
# ENV CHROME_DRIVER_BASE="chromedriver.storage.googleapis.com" \
#     CPU_ARCH="64"
# ENV CHROME_DRIVER_FILE="chromedriver_linux${CPU_ARCH}.zip"
# ENV CHROME_DRIVER_URL="https://${CHROME_DRIVER_BASE}/${CHROME_DRIVER_VERSION}/${CHROME_DRIVER_FILE}"
# # Gets latest chrome driver version. Or you can hard-code it, e.g. 2.15
# # Layer size: small: 6.932 MB
# RUN wget -nv -O chromedriver_linux${CPU_ARCH}.zip ${CHROME_DRIVER_URL} \
#   && unzip chromedriver_linux${CPU_ARCH}.zip \
#   && rm chromedriver_linux${CPU_ARCH}.zip \
#   && mv chromedriver \
#         chromedriver-${CHROME_DRIVER_VERSION} \
#   && chmod 755 chromedriver-${CHROME_DRIVER_VERSION} \
#   && ln -s chromedriver-${CHROME_DRIVER_VERSION} \
#            chromedriver \
#   && sudo ln -s /home/seluser/chromedriver /usr/bin

RUN echo google-chrome --version
RUN echo /usr/local/bin/chromium-browser --version

FROM tiessoftware/feepay_tests:updates

# Define default command.
CMD ["bash"]
