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
RUN wget -O /tmp/chromedriver/LATEST_RELEASE http://chromedriver.storage.googleapis.com/LATEST_RELEASE
RUN if [ $system_type == i686 ]; then set bit=32; elif [ $system_type == x86_64 ]; then set bit=64; fi
RUN echo $bit
RUN cat /tmp/chromedriver/LATEST_RELEASE ; chrome_ver=$(cat /tmp/chromedriver/LATEST_RELEASE)
RUN echo $chrome_ver
RUN wget -O /tmp/chromedriver/chromedriver.zip 'http://chromedriver.storage.googleapis.com/'echo $chrome_ver'/chromedriver_linux'$b'.zip'
RUN unzip -o /tmp/chromedriver/chromedriver.zip chromedriver -d /usr/local/bin/
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
