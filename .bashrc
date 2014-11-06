# .bashrc
# S.M.A.R.T. Lab global definitions

### Initial Setup test taht failed ###
# mkdir /rap/ycy-622-aa/.local/
# mkdir /rap/ycy-622-aa/.local/bin
# mkdir /rap/ycy-622-aa/.local/shared
# mkdir /rap/ycy-622-aa/.local/lib
# mkdir /rap/ycy-622-aa/.local/lib/python2.7
# mkdir /rap/ycy-622-aa/.local/lib/python2.7/site-packages
# easy_install --prefix=$HOME_GROUP/.local/ ipython
# mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B; pip install --install-option="--prefix=/rap/ycy-622-aa/.local" numpy pydot nose; mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
# mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B; pip install --install-option="--prefix=/rap/ycy-622-aa/.local" scipy; mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
# matplotlib scipy

### Initial Setup ###
# mkdir /rap/ycy-622-aa/.local/
# mkdir /rap/ycy-622-aa/.local/bin
# mkdir /rap/ycy-622-aa/.local/shared
# mkdir /rap/ycy-622-aa/.local/lib
# mkdir /rap/ycy-622-aa/.local/lib/python2.7
# mkdir /rap/ycy-622-aa/.local/lib/python2.7/site-packages
# mkdir /rap/ycy-622-aa/canopy
# bash canopy-1.4.1-full-rh5-64.sh canopy/
# /rap/ycy-622-aa/canopy/canopy_cli --no-gui-setup --common-install --install-dir=/rap/ycy-622-aa/.local


###################################
########## Dynamic loads ##########
###################################
## Loading canopy python
VIRTUAL_ENV_DISABLE_PROMPT=1 source /rap/ycy-622-aa/.local/Canopy_64bit/User/bin/activate


#############################
########## EXPORTS ##########
#############################
export HOME_GROUP=$RAP
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME_GROUP/.local/bin

export CPATH=$CPATH:$HOME/.local/include
export CPATH=$CPATH:$HOME_GROUP/.local/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$HOME/.local/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$HOME_GROUP/.local/include
export CPATH=$CPATH:$HOME_GROUP/.local/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME/.local/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME_GROUP/.local/include

export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/
export PYTHONPATH=$PYTHONPATH:$HOME_GROUP/.local/lib/
export PYTHONPATH=$PYTHONPATH:$HOME_GROUP/.local/lib/python2.7/site-packages/

export MLPYTHON_DATASET_REPO=$HOME_GROUP/ml_datasets


#################################
######## ONE TIME THINGS ########
#################################
if [ ! -f $HOME/.group_config_run ]; then
  echo -n "Running one time config ... "
  # Configuring pip
  if [ ! -d $HOME/.pip ]; then
      mkdir -p $HOME/.pip
  fi
  if [ ! -f $HOME/.pip/pip.conf ]; then
      ln -s $HOME_GROUP/.pip/pip.conf $HOME/.pip/pip.conf
  fi

  # Setting up modules
  module purge 2> /dev/null
  # apps/python/2.7.5
  module add apps/git/1.8.5.3 apps/mercurial/2.7.2 libs/hdf5/1.8.11 apps/gnuplot/4.6.4 libs/mkl/11.1 apps/cmake/2.8.12.1 apps/gdb/7.6.1 libs/boost/1.55.0
  module save 2> /dev/null

  # Flagging the one time config as done
  touch $HOME/.group_config_run
  echo "Done"
fi


###########################
########## ALIAS ##########
###########################
alias l='ls -al --color=tty'
alias ll='ls -lhF --color=tty'
alias ca='setxkbmap ca'
alias us='setxkbmap us'


##############################
########## BINDINGS ##########
##############################
if [ -t 0 ]; then # Verify that this is an interactive shell before binding
  bind '"\C-p": shell-kill-word'
fi


###########################################
##########       FUNCTIONS       ##########
###########################################
ipdb() {
  params="$@"
  ipython --pdb -c "%run $params"
}


###########################################
##########        SETTINGS       ##########
###########################################
# Set default permission of new files to be writable for the group
umask 0002

# Bash history size
export HISTSIZE=50000
export HISTFILESIZE=10000

# PIP bash completion
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip

# Source git prompt colors
if [ -f $HOME_GROUP/.git-prompt ]; then
    . $HOME_GROUP/.git-prompt
fi


############################
########## PROMPT ##########
############################
#if [ ${HOSTNAME:0:5} != 'cg000' ]; then
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
    PS1="\[\e[34;1m\]\u@\[\e[33;1m\]\H \[\e[0m\]\W\[\e[32;1m\]\$(parse_git_branch_or_tag)\[\e[31;1m\]$ \[\e[0m\]"
fi


##############################
########## LAB NEWS ##########
##############################
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
  echo -e "\e[41m##############################################\e[49m"
  echo -e "\e[41m#~~~~~~~~~~~~~~~~~LAB INFO~~~~~~~~~~~~~~~~~~~#\e[49m"
  echo -e "\e[41m##############################################\e[49m"
  echo "- You can now use pip normally to install packages and it will automatically put them in your home."
  echo "- Pip now has basic autocomplete for commands, use TAB and TAB TAB while typing commands."
  echo -e "\e[92m- New version of Smartdispatch! Just type smart_dispatch.py --help.\033[0m"
  echo ""
fi
