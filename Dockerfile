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

FROM tiessoftware/feepay_tests:updates
ENV CHROME_VERSION
ENV CHROME_INSTALL_CMD
#COPY --from=base .

RUN if [ $CHROME_VERSION = 'beta' ]; then CHROME_INSTALL_CMD='google-chrome-beta'; elif [ $CHROME_VERSION = 'previous' ]; then CHROME_INSTALL_CMD='google-chrome'; elif [ $CHROME_VERSION = 'unstable' ]; then CHROME_INSTALL_CMD='google-chrome-unstable'; else CHROME_INSTALL_CMD='google-chrome-stable'; fi
RUN echo $CHROME_VERSION
RUN echo $CHROME_INSTALL_CMD


RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN echo $CHROME_INSTALL_CMD
RUN apt-get install -y $(CHROME_INSTALL_CMD)

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

# Define default command.
CMD ["bash"]
