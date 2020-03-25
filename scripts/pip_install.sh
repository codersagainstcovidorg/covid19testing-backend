#!/bin/bash
#todo: add dirname "$(readlink -f "$0")"
pip install "$1"
pip freeze > requirements.txt