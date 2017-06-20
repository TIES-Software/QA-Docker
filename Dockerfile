FROM debian:jessie

RUN apt-get update && apt-get install -y \
        python \
        python-pip \
        curl \
        unzip \
        wget \
        libgconf-2-4

RUN pip install pytest \
        selenium \
        behave

# Install most recent Chrome

RUN echo 'deb http://dl.google.com/linux/chrome/deb/ stable main' > /etc/apt/sources.list.d/chrome.list

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -

RUN set -x \
    && apt-get update \
    && apt-get install -y \
        xvfb \
        google-chrome-stable

ADD xvfb-chrome /usr/bin/xvfb-chrome
RUN ln -sf /usr/bin/xvfb-chrome /usr/bin/google-chrome

ENV CHROME_BIN /usr/bin/google-chrome


# Install most recent Firefox

#RUN set -x \
#    && apt-get update \
#    && apt-get install -y \
#        pkg-mozilla-archive-keyring

#RUN echo 'deb http://mozilla.debian.net/ jessie-backports firefox-esr' >> /etc/apt/sources.list.d/jessie-backports.list

#RUN set -x \
#    && apt-get update \
#    && apt-get install -y \
#        xvfb \
#    && apt-get install -y -t \
#        jessie-backports \
#        firefox-esr

#ADD xvfb-firefox /usr/bin/xvfb-firefox
#RUN ln -sf /usr/bin/xvfb-firefox /usr/bin/firefox

#ENV FIREFOX_BIN /usr/bin/firefox


# Install most recent stable chromedriver
#RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/2.29/chromedriver_linux32.zip` \
    && mkdir -p /opt/chromedriver-$CHROMEDRIVER_VERSION \
    && curl -sS -o /tmp/chromedriver_linux64.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip \
    && unzip -qq /tmp/chromedriver_linux64.zip -d /opt/chromedriver-$CHROMEDRIVER_VERSION \
    && rm /tmp/chromedriver_linux64.zip \
    && chmod +x /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver \
    && ln -fs /opt/chromedriver-$CHROMEDRIVER_VERSION/chromedriver /usr/local/bin/chromedriver


#setup Xvfb
ADD xvfb-run.sh /usr/bin/xvfb-run
RUN chmod u+x /usr/bin/xvfb-run
