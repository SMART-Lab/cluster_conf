# .bashrc
# S.M.A.R.T. Lab global definitions

#################################
######## ONE TIME THINGS ########
#################################
if [ ! -d $HOME/.pip ]; then
    mkdir -p $HOME/.pip
fi
if [ ! -f $HOME/.pip/pip.conf ]; then
    ln -s $HOME_GROUP/.pip/pip.conf $HOME/.pip/pip.conf
fi


########################
######## MODULE ########
########################
if [ "$BQMAMMOUTH" == "ms" ]; then # If on MS2
    # python64/2.7.1 was loaded instead of .5 for some reason
    module load python64/2.7.5 mkl64/10.1.3.027 lapack64/3.1.1
else
    module load mercurial python64/2.7.5 intel64/12.0.5.220 #ask mammouth guy about why it's better to load the old intel64/12.0.5.220 (only one linked with mkl/python)

    if [ ${HOSTNAME:0:5} == 'cg000' ] && [ ${HOSTNAME:5} != '5' ]; then # If on CUDA GPU node
        module load cuda
    fi
fi


#############################
########## EXPORTS ##########
#############################
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME_GROUP/.local/bin
export PATH=$PATH:/home/laroche1/software/Jobman/bin

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
export PYTHONPATH=$PYTHONPATH:/home/laroche1/software/Jobman

#export MLPYTHON_DATASET_REPO=$HOME_GROUP/ml_datasets
#export MLPYTHON_DATASET_REPO=$SHARE_NOBACKUP/ml_datasets
# Hack to have access on BRUME
export MLPYTHON_DATASET_REPO=/nfs3_ib/10.0.220.3/tank/nfs/larochel/nobackup/share/ml_datasets

#export SCRATCH=`env | grep -m1 PARALLEL_SCRATCH_GROUP_MP2* | tr '=' '\n' | grep '/'`


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
# Useful script
# /opt/ccstools/bin/
ipdb() {
  params="$@"
  ipython --pdb -c "%run $params"
}

qqJobs() {
  bqmon -u $USER | grep $LOGNAME'\|^  [^ ]\|qwork\|qtest\|qfat256\|qfat512\|qlong\|Nodes\|Total'
}

function get_current_user_quota_usage_percentage {
    usage=(`getstatusdisk_user.sh 2> /dev/null | grep $USER`)
    usage=${usage[2]}
    usage=${usage:0:$[(`expr length $usage`)-1]}

    group_quota=(`getstatusdisk_user.sh 2> /dev/null | tail -n8 | head -n1`)
    group_quota=${group_quota[3]}
    group_quota=${group_quota:0:$[(`expr length $group_quota`)-1]}

    bc <<< 'scale=2; '$usage'/'$group_quota
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
    PS1="\[\e[34;1m\]\u@\[\e[33;1m\]\H-$BQMAMMOUTH \[\e[0m\]\W\[\e[32;1m\]\$(parse_git_branch_or_tag)\[\e[31;1m\]$ \[\e[0m\]"
fi


##############################
########## LAB NEWS ##########
##############################
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
  echo -e "\e[41m##############################################\e[49m"
  echo -e "\e[41m#~~~~~~~~~~~~~~~~~LAB INFO~~~~~~~~~~~~~~~~~~~#\e[49m"
  echo -e "\e[41m##############################################\e[49m"
  echo "- Jobdispatch is available. jobdispatch --help | less. [You should now use smartDispatch instead]"
  echo "- Please make sure that you moved your datasets to the ml_datasets folder. If you want help with that just ask."
  echo "- You can now use pip normally to install packages and it will automatically put them in your home."
  echo "- Pip now has basic autocomplete for commands, use TAB and TAB TAB while typing commands."
  echo -e "\e[92m- New version of Smartdispatch! Just type smart_dispatch.py --help.\033[0m"
  echo ""
fi


###########################
########## QUOTA ##########
###########################
if [ -t 0 ]; then # Verify that this is an interactive shell before printing
  function get_group_max_quota () {
    group_quota=(`quota -g $1 | tail -n1`)
    group_quota=${group_quota[1]}
    echo $[$group_quota/1024]
  }

  function get_user_usage () {
    if [ "$BQMAMMOUTH" == "ms" ]; then
      usage=(`ssh larochel-mp2.rqchp.ca getstatusdisk_user.sh 2> /dev/null | grep $1`)
    else
      usage=(`getstatusdisk_user.sh 2> /dev/null | grep $1`)
    fi
    usage=${usage[2]}
    usage=${usage:0:$[(`expr length $usage`)-1]}
    echo $usage
  }

  function get_current_user_quota_usage_percentage {
      usage=$(get_user_usage $USER)
      group_quota=$(get_group_max_quota 'larochel')
      bc <<< 'scale=2; '$usage'/'$group_quota'*100'
  }

  function get_number_of_user_in_group () {
      getent group $1 | tr "," "\n" | wc -l
  }

  usage_percent=$(get_current_user_quota_usage_percentage)

  nb_user=$(get_number_of_user_in_group 'laroche1')
  max_usage_percent=$(bc <<< 'scale=2; 100/'$nb_user)


  if (( $(echo "$usage_percent > $max_usage_percent" | bc -l) ));then
      echo -e "\033[31mYou are using to much data! Please clean your home."
      echo -e "You are using" $usage_percent"% of the whole group and you should not use more than" $max_usage_percent"%."

      # Compute how much to remove
      group_quota=$(get_group_max_quota 'larochel')
      t=$(bc <<< 'scale=4; '$max_usage_percent'/100')
      max_usage_mb=$(bc -l <<< 'scale=0; ('$group_quota'*'$t')/1')
      usage_usage_mb=$(get_user_usage $USER)
      to_remove=$[$usage_usage_mb-$max_usage_mb]

      echo -e "Please remove at least" $to_remove"mb! :D\033[0m"
  fi
fi
