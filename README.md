Building automatically from https://github.com/TIES-Software/QA-Docker

This docker image expands on markadams/chromium-xvfb, an image which has a hack in place to get chrome running headlessly. (https://hub.docker.com/r/markadams/chromium-xvfb/) (https://github.com/mark-adams/docker-chromium-xvfb/tree/master/images/base)

The key thing to know from this image is that his shell script (xvfb-chromium) is run in place of google-chrome or chromium, to make it work within docker. The key lines from his dockerfile are:
```
ADD xvfb-chrome /usr/bin/xvfb-chrome
RUN ln -sf /usr/bin/xvfb-chrome /usr/bin/google-chrome
```

The analagous is also done with Xvfb:
```
ADD xvfb-run.sh /usr/bin/xvfb-run
RUN chmod u+x /usr/bin/xvfb-run
```

Check the repo on Github for more detail on the xvfb-chrome and xvfb-run.sh files.


The following software is installed on this image, which has *debian:jessie* as its base:
* python
* pip
* pytest
* selenium
* behave
* Xvfb
* chromium (not google-chrome)
* chromedriver (most recent stable)

# To use this image

Simply begin your Dockerfile with 
```
FROM tiessoftware/qa_base
```

And you're all set!
