#!/bin/bash
tag="main"
zipfile="https://github.com/dsentker/kioskscripts/archive/refs/heads/$tag.zip"
mkdir kiosk && cd kiosk || exit
curl -O $zipfile && unzip "kioskscripts-$tag.zip" && chmod +x setup.sh && ./setup.sh
