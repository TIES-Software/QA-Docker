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

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
    unzip \
    wget

# install google chrome
RUN echo 'install chrome'
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable
RUN echo 'chrome install steps complete, may NOT be successful'

# install chromedriver
RUN echo 'installing chromedriver'
RUN apt-get install -yqq unzip
RUN system_type=$(uname -m)
RUN echo $system_type
RUN chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`"
RUN echo $chrome_ver
RUN if [ $system_type == i686 ]; then bit=32; elif [ $system_type == x86_64 ]; then bit=64; fi
RUN echo $bit
RUN mkdir -p /tmp/chromedriver
RUN curl http://chromedriver.storage.googleapis.com/$chrome_ver/chromedriver_linux$bit.zip > /tmp/chromedriver/chromedriver.zip
RUN unzip -o /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
RUN rm -rf /tmp/chromedriver
RUN echo 'chromedriver install steps complete, may NOT be successful'

# set display port to avoid crash
RUN echo 'setting display port'
ENV DISPLAY=:99
RUN echo 'completed setting display port'

# step 8
RUN echo 'installing behave'
RUN pip install behave
RUN echo 'behave install steps complete, may NOT be successful'

# step 9 Define default command.
RUN echo 'using bash'
CMD ["bash"]
