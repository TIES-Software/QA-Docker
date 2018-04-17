FROM ubuntu
FROM python:2.7

# install selenium
RUN pip install selenium==3.8.0

RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
    unzip \
    wget

# install google chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN sudo apt-get install -y google-chrome-stable

# install chromedriver
RUN sudo echo apt-get install -yqq unzip
RUN set a=$(uname -m)
RUN rm -r /tmp/chromedriver
RUN mkdir /tmp/chromedriver
RUN wget -O /tmp/chromedriver/LATEST_RELEASE http://chromedriver.storage.googleapis.com/LATEST_RELEASE
RUN if [ $a == i686 ]; then set b=32; elif [ $a == x86_64 ]; then set b=64; fi
RUN set latest=$(cat /tmp/chromedriver/LATEST_RELEASE)
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'$latest'/chromedriver_linux'$b'.zip'
RUN sudo unzip -o /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
RUN set ENV DISPLAY=:99

# step 8
RUN pip install behave

# step 9 Define default command.
RUN CMD ["bash"]
