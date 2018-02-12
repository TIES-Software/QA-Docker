FROM ubuntu

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
FROM selenium/standalone-chrome
