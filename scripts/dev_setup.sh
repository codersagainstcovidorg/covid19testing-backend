#!/bin/bash
#todo: add dirname "$(readlink -f "$0")"

python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt