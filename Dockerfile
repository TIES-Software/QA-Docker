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

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update \
RUN apt-get install -y google-chrome-stable

# install chromedriver
RUN apt-get install -yqq unzip
RUN system_type=$(uname -m) \
    && chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`" \
    && if [ $system_type == i686 ]; then bit=32; elif [ $system_type == x86_64 ]; then bit=64; fi \
    && mkdir -p /tmp/chromedriver \
    && curl http://chromedriver.storage.googleapis.com/$chrome_ver/chromedriver_linux$bit.zip > /tmp/chromedriver/chromedriver.zip \
    && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
    && ls -l \
    && cp chromedriver-3 chromedriver \
    && rm -rf chromedriver-3 \
    && rm -rf /tmp/chromedriver

# set display port to avoid crash
ENV DISPLAY=:99

# step 8
RUN pip install behave

# step 9 Define default command.
CMD ["bash"]
