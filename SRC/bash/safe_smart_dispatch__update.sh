#!/bin/sh
echo "Updating SmartDispatch!"
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B
pip install --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" git+https://github.com/SMART-Lab/smartdispatch
mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
