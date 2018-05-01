FROM debian:jessie

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

ARG CHROME_VERSION=current
ARG CHROME_INSTALL_CMD=google-chrome-stable
ARG CHROME_RELEASE=stable
ARG CHROME_REPO=main
ENV DISPLAY=:99
#COPY --from=base .

RUN echo $CHROME_VERSION
RUN if [ $CHROME_VERSION = 'previous' ]; then $CHROME_RELEASE='bionic'; fi
RUN if [ $CHROME_VERSION = 'previous' ]; then $CHROME_REPO='universe'; fi
RUN if [ $CHROME_VERSION = 'previous' ]; then CHROME_INSTALL_CMD='chromium-browser'; fi
RUN if [ $CHROME_VERSION = 'beta' ]; then CHROME_INSTALL_CMD='google-chrome-beta'; fi
RUN if [ $CHROME_VERSION = 'unstable' ]; then CHROME_INSTALL_CMD='google-chrome-unstable'; fi
RUN echo $CHROME_INSTALL_CMD
RUN echo $CHROME_RELEASE
RUN echo $CHROME_REPO


RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/${CHROME_INSTALL_CMD}.list'
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ ${CHROME_RELEASE} ${CHROME_REPO}" >> /etc/apt/sources.list.d/google.list'
RUN apt-get -y update
RUN apt-get install -y ${CHROME_INSTALL_CMD}

RUN system_type=$(uname -m) \
    && echo $system_type \
    && chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`" \
    && if [ $system_type = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
    && echo $bit \
    && mkdir -p /tmp/chromedriver \
    && curl http://chromedriver.storage.googleapis.com/$chrome_ver/chromedriver_linux$bit.zip > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && rm -rf /tmp/chromedriver \
    && chmod +x /usr/local/bin/chromedriver

FROM tiessoftware/feepay_tests:updates

# Define default command.
CMD ["bash"]
