#!/bin/bash

zipfile=https://github.com/dsentker/kioskscripts/archive/refs/heads/main.zip
curl -O $zipfile && unzip main.zip && chmod +x setup.sh && ./setup.sh
