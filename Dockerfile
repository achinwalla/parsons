FROM python:3.7

####################
## Selenium setup ##
####################

# Download Chrome and Driver
# For Selenium Runs

# Run update in case
RUN apt-get -y update

# We need wget to set up the PPA and xvfb to have a virtual screen and unzip to install the Chromedriver
RUN apt-get install -y wget xvfb unzip

# Set up the Chrome PPA
RUN apt install sudo -y --no-install-recommends
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN sudo apt install ./google-chrome-stable_current_amd64.deb -y --no-install-recommends

# Update the package list and install chrome
RUN apt-get update -y
RUN apt-get install -y google-chrome-stable

# Set up Chromedriver Environment variables
ENV CHROMEDRIVER_VERSION 99.0.4844.51
ENV CHROMEDRIVER_DIR /chromedriver
RUN mkdir $CHROMEDRIVER_DIR

# Download and install Chromedriver
RUN wget -q --continue -P $CHROMEDRIVER_DIR "http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip"
RUN unzip $CHROMEDRIVER_DIR/chromedriver* -d $CHROMEDRIVER_DIR

# Put Chromedriver into the PATH
ENV PATH $CHROMEDRIVER_DIR:$PATH

# Install libraries chromedriver needs
RUN apt-get install -y libglib2.0-0 \
    libnss3 \
    libgconf-2-4 \
    libfontconfig1

# TODO Remove when we have a TMC-specific Docker image

# Much of this was pulled from examples at https://github.com/joyzoursky/docker-python-chromedriver

# install google chrome
#RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
#RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
#RUN apt-get -y update
#RUN apt-get install -y google-chrome-stable

# install chromedriver
#RUN apt-get install -yqq unzip
#RUN wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE`/chromedriver_linux64.zip
#RUN unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/

# set display port to avoid crash
#ENV DISPLAY=:99

###################
## Parsons setup ##
###################

RUN mkdir /src

COPY requirements.txt /src/
RUN pip install -r /src/requirements.txt

COPY . /src/
WORKDIR /src

RUN python setup.py develop

# The /app directory can house the scripts that will actually execute on this Docker image.
# Eg. If using this image in a Civis container script, Civis will install your script repo
# (from Github) to /app.
RUN mkdir /app
WORKDIR /app
# Useful for importing modules that are associated with your python scripts:
env PYTHONPATH=.:/app
