#!/bin/sh
echo "Updating theano!"
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B
pip install --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" git+https://github.com/Theano/Theano
mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
