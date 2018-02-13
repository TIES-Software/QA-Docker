# Run Chrome Headless in a container
#
# What was once a container using the experimental build of headless_shell from
# tip, this container now runs and exposes stable Chrome headless via
# google-chome --headless.
#
# What's New
#
# 1. Pulls from Chrome Stable
# 2. You can now use the ever-awesome Jessie Frazelle seccomp profile for Chrome.
#     wget https://raw.githubusercontent.com/jfrazelle/dotfiles/master/etc/docker/seccomp/chrome.json -O ~/chrome.json
#
#
# To run (without seccomp):
# docker run -d -p 9222:9222 --cap-add=SYS_ADMIN justinribeiro/chrome-headless
#
# To run a better way (with seccomp):
# docker run -d -p 9222:9222 --security-opt seccomp=$HOME/chrome.json justinribeiro/chrome-headless
#
# Basic use: open Chrome, navigate to http://localhost:9222/
#

# step 1 Base docker image
FROM debian:sid


# step 2
LABEL name="chrome-headless" \
			maintainer="Justin Ribeiro <justin@justinribeiro.com>" \
			version="1.4" \
			description="Google Chrome Headless in a container"

# Install deps + add Chrome Stable + purge all the things
# step 3
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	ca-certificates \
	curl \
  	gnupg \
    --no-install-recommends \
    python-pip \
    python \
    python-setuptools  \
    unzip \
    wget \
    libgconf-2-4
#	&& curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
#	&& echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
#	&& apt-get update && apt-get install -y \
#	google-chrome-stable \
#    --only-upgrade install google-chrome-stable \
#	&& apt-get purge --auto-remove -y curl gnupg \
#	&& rm -rf /var/lib/apt/lists/*

# Chrome Browser
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/* \
  echo ${CHROME_VERSION:-google-chrome-stable}

#============================================
# Chrome webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
ARG CHROME_DRIVER_VERSION="latest"
RUN CD_VERSION=$(if [ ${CHROME_DRIVER_VERSION:-latest} = "latest" ]; then echo $(wget -qO- https://chromedriver.storage.googleapis.com/LATEST_RELEASE); else echo $CHROME_DRIVER_VERSION; fi) \
    && echo "Using chromedriver version: "$CD_VERSION \
    && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
    && rm -rf /opt/selenium/chromedriver \
    && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm /tmp/chromedriver_linux64.zip \
    && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CD_VERSION \
    && chmod 755 /opt/selenium/chromedriver-$CD_VERSION \
    && sudo ln -fs /opt/selenium/chromedriver-$CD_VERSION /usr/bin/chromedriver


# step 8
RUN pip install pytest \
    selenium \
    behave

# step 4 Add Chrome as a user
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# step 5 Run Chrome non-privileged
USER chrome

# step 6 Expose port 9222
EXPOSE 9222

# step 7 Autorun chrome headless with no GPU
#ENTRYPOINT [ "google-chrome-stable" ]

# step 9 Define default command.
CMD ["bash"]
