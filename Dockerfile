# FROM debian:jessie
#
# RUN apt-get update && apt-get install -y \
#         python \
#         python-pip \
#         curl \
#         unzip \
#         wget \
#         apt-transport-https \
#     	ca-certificates \
#         libgconf-2-4
#
# RUN pip install pytest \
#         selenium \
#         behave
#
# # # get and install stable main google chrome
# # RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
# # RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
# # RUN apt-get -y update
# # # RUN apt-get install -y google-chrome-stable
# # # install current beta google chrome
# # RUN apt-get install -y google-chrome-beta
#
#
# # # install chromedriver
# # RUN system_type=$(uname -m) \
# #     && echo $system_type \
# #     && chrome_ver="`wget -qO- http://chromedriver.storage.googleapis.com/LATEST_RELEASE`" \
# #     && if [ $system_type = 'i686' ]; then bit='32'; elif [ $system_type = 'x86_64' ]; then bit='64'; fi \
# #     && echo $bit \
# #     && mkdir -p /tmp/chromedriver \
# #     && curl http://chromedriver.storage.googleapis.com/$chrome_ver/chromedriver_linux$bit.zip > /tmp/chromedriver/chromedriver.zip \
# #     && unzip -qqo /tmp/chromedriver/chromedriver chromedriver -d /usr/local/bin/ \
# #     && rm -rf /tmp/chromedriver \
# #     && chmod +x /usr/local/bin/chromedriver
#
# # set ENV Variables
# ENV DISPLAY=:99
# ENV CHROME_DRIVER_DIR="/usr/local/bin"
# ENV FIREFOX_BINARY_PATH="/usr/local/bin"
# ENV PROD_ID="test"
# ENV ROSTER_USER="ci+rosterview@feepay.com"
#
#
#
# # Define default command.
# CMD ["bash"]
