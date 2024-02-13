#!/bin/bash

zipfile=https://github.com/dsentker/kioskscripts/archive/refs/heads/main.zip
curl -O $zipfile && unzip $zipfile && chmod +x setup.sh && ./setup.sh
