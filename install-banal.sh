#!/bin/bash

# TODO: check
wget 'http://www.sysnet.ucsd.edu/sigops/banal/pdftohtml-0.40c.tar.gz'
tar xvzf pdftohtml-0.40c.tar.gz
cd pdftohtml-0.40c
make
sudo cp ./src/pdftohtml /usr/local/bin
sudo chmod 755 /usr/local/bin/pdftohtml
sudo chown $(whoami):admin /usr/local/bin/pdftohtml
cd ..
rm -rf pdftohtml-0.40c
rm pdftohtml-0.40c.tar.gz

echo "this should show the help message"
pdftohtml

# Setup Banal
wget 'http://www.sysnet.ucsd.edu/sigops/banal/banal'
sudo mv banal /usr/local/bin
sudo chmod 755 /usr/local/bin/banal
sudo chown $(whoami):admin /usr/local/bin/banal

echo "this should show the help message"
banal --help
