#!/bin/sh
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B
echo "Updating iPython!"
pip install --no-use-wheel --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" ipython
mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
