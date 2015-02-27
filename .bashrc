# .bashrc
# S.M.A.R.T. Lab global definitions


##############################
########## LAB NEWS ##########
##############################
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
  echo -e "\e[41m##############################################\e[49m"
  echo -e "\e[41m#~~~~~~~~~~~~~~~~~LAB INFO~~~~~~~~~~~~~~~~~~~#\e[49m"
  echo -e "\e[41m##############################################\e[49m"
  echo "- You can now use pip normally to install packages and it will automatically put them in your home."
  echo "- Pip now has basic autocomplete for commands, use TAB and TAB TAB while typing commands."
  echo -e "\e[92m- Smartdispatch updates to version 1.1! New list char \"[]\" see smart_dispatch.py --help.\033[0m"
  echo ""
fi

######################################
########## CLUSTER SPECIFIC ##########
######################################
function get_cluster {
  if [ $LMOD_SYSTEM_NAME ]; then
    echo "colosse"
  elif [ $BQMAMMOUTH ]; then
    echo $BQMAMMOUTH
  elif [ "`qstat -sql | grep server:`" == "server: gm-schrmat" ]; then
    echo "guillimin"
  fi
}
export CLUSTER_NAME=$(get_cluster)
export HOME_GROUP=`dirname "$BASH_SOURCE"`


#############################
########## EXPORTS ##########
#############################
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME_GROUP/.local/bin

export CPATH=$CPATH:$HOME/.local/include
export CPATH=$CPATH:$HOME_GROUP/.local/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$HOME/.local/include
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$HOME_GROUP/.local/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME/.local/include
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:$HOME_GROUP/.local/include

export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/
export PYTHONPATH=$PYTHONPATH:$HOME/.local/lib/python2.7/site-packages/
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

  # Cleaning up modules
  module purge 2> /dev/null
  if [ $CLUSTER_NAME == "colosse" ]; then
    module rm mpi/openmpi/1.8.4 cuda/6.0.37
  fi
  module save 2> /dev/null

  # Flagging the one time config as done
  touch $HOME/.group_config_run
  echo "Done"
fi

########################
######## MODULE ########
########################
if [ -f $HOME_GROUP/SRC/bashrc/.$CLUSTER_NAME ]; then
  . $HOME_GROUP/SRC/bashrc/.$CLUSTER_NAME
else
    echo -e "\033[1;31mNew cluster or change in old cluster.\033[0m"
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
  bind '"\eOC":forward-word'
  bind '"\eOD":backward-word'
fi


###########################################
##########       FUNCTIONS       ##########
###########################################
function ipdb {
  params="$@"
  ipython --pdb -c "%run $params"
}


###########################################
##########        SETTINGS       ##########
###########################################
# Set default permission of new files to be writable for the group
umask 0002

# Bash history size
if [ -t 0 ]; then # Verify that this is an interactive shell
  export HISTSIZE=50000
  export HISTFILESIZE=10000
fi

# PIP bash completion
if [ -t 0 ]; then # Verify that this is an interactive shell
  _pip_completion()
  {
      COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                     COMP_CWORD=$COMP_CWORD \
                     PIP_AUTO_COMPLETE=1 $1 ) )
  }
  complete -o default -F _pip_completion pip
fi

# Source git prompt colors
if [ -t 0 ]; then # Verify that this is an interactive shell
  if [ -f $HOME_GROUP/.git-prompt ]; then
      . $HOME_GROUP/.git-prompt
  fi
fi

############################
########## PROMPT ##########
############################
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
    PS1="\[\e[34;1m\]\u@\[\e[33;1m\]$CLUSTER_NAME-\H \[\e[0m\]\W\[\e[32;1m\]\$(parse_git_branch_or_tag)\[\e[31;1m\]$ \[\e[0m\]"
fi
