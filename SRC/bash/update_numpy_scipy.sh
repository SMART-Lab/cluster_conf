#!/bin/sh
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B
echo "Updating Numpy!"
pip install --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" numpy
echo "Updating Scipy!"
pip install --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" scipy
mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
