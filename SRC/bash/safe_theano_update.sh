#!/bin/sh
function verify_user_job {
    declare -A servers
    servers=( ["@ms"]="larochel-ms.rqchp.ca" ["@mp2"]="larochel-mp2.rqchp.ca" ["@brume"]="larochel-mp2.rqchp.ca" )
    if [ ! `ssh ${servers[$1]} qstat $1 -u $2 | wc -l` -eq 0 ]; then
        echo -e "\033[31m"$2 "has job running on" $1". Not updating theano.\033[0m"
        exit
    fi
}

export all_user_in_group=`getent group laroche1 | tr ":" "\n" | tail -n1 | tr "," "\n"`

# Verify that no user have running jobs
for user in $all_user_in_group;do
    verify_user_job '@ms' $user
    verify_user_job '@mp2' $user
    verify_user_job '@brume' $user
done

echo "Updating theano!"
mv $HOME/.pip/pip.conf $HOME/.pip/pip.conf_B
pip install --upgrade --no-deps --install-option="--prefix=$HOME_GROUP/.local" git+https://github.com/Theano/Theano
mv $HOME/.pip/pip.conf_B $HOME/.pip/pip.conf
