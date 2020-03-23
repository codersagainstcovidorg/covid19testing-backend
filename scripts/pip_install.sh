#!/bin/bash
pip install "$1"
pip freeze > requirements.txt