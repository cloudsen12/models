# /*
# MIT License
#
# Copyright (c) [2022] [CloudSEN12 team]
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM rocker/rstudio

# Create a folder
RUN mkdir -p /home/cloudsen12/FMASK

# Download FMASK Matlab
RUN wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1ss7ZmkziP6QPvi2exc7dVuNjp_RAODGb' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1ss7ZmkziP6QPvi2exc7dVuNjp_RAODGb" -O /home/cloudsen12/Fmask_4_3_Linux_mcr.install && rm -rf /tmp/cookies.txt

# Change the access permissions of files
RUN chmod 777 -R /home/cloudsen12/

# Change the access permissions of files
RUN ./home/cloudsen12/Fmask_4_3_Linux_mcr.install -mode silent -agreeToLicense yes

RUN R -e "install.packages('googleCloudStorageR')"
COPY sen2_metadata.csv /home/cloudsen12/sen2_metadata.csv
COPY GCS_AUTH_FILE.json /home/cloudsen12/GCS_AUTH_FILE.json
COPY utils.R /home/cloudsen12/utils.R
COPY main.R /home/cloudsen12/main.R

# Copy files
RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update && \ 
    apt-get install -yq --no-install-recommends \ 
    libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \ 
    libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \ 
    libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
    libxcursor1 libxdamage1 libxext6 libxfixes3 libxt6 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \ 
    libnss3 gcc-9 libstdc++6
