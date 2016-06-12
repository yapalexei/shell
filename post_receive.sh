#!/bin/sh

##set -e ## to exit script on any error

env="production"
siteDir="/var/www/site"
brewAppsRoot="/home/ec2-user/.linuxbrew/bin"
forever="$brewAppsRoot/forever"
node="$brewAppsRoot/node"
npm="$brewAppsRoot/npm"
bower="$brewAppsRoot/bower"
grunt="$brewAppsRoot/grunt"
slackMessageUrl="https://hooks.slack.com/services/some-key/some-other-key"

check_dirs()
{
        if [ ! -d $siteDir ]; then
                mkdir -p $siteDir
        else
                echo "the dir does exist: $siteDir"
        fi
}

check_env()
{
        echo "################################################"
        echo "############# Checking ENV Vars  ###############"

        echo "USER set to: $USER "
        echo "NODE_ENV set to: $NODE_ENV"


        if [ "$NODE_ENV" == "production" -o "$NODE_ENV" == "dev" -o "$NODE_ENV" == "stage" ]; then
                echo "node env is: $NODE_ENV"
        else
                echo "NODE_ENV not set."
        fi
        cd $siteDir && source "$siteDir/"env_export.sh "$siteDir/.env"
        echo "Setting NODE_ENV to: '$NODE_ENV'"
        env="$NODE_ENV" #setting it to be used with other components.

        if [ "$NODE_ENV" != "production" ]; then
                brewAppsRoot="/usr/local/bin"
                echo "set brewAppsRoot to $brewAppsRoot"
        fi

}

set_vars()
{
        forever="$brewAppsRoot/forever"
        node="$brewAppsRoot/node"
        npm="$brewAppsRoot/npm"
        bower="$brewAppsRoot/bower"
        grunt="$brewAppsRoot/grunt"
}

git_checkout()
{
        export GIT_WORK_TREE=/var/www/site
        export GIT_DIR=/var/www/site.git
        git checkout -f
}

stop_server()
{
        echo "################################################"
        echo "############## Stopping Server #################"
        $forever stopall
        echo " "
}

install_node_deps()
{
        echo "################################################"
        echo "######### Installing Node Dependancies #########"
        cd $siteDir && $npm install --production
        echo " "
}

install_bower_deps()
{
        echo "################################################"
        echo "######### Installing Bower Dependancies ########"
        cd $siteDir && $bower install
        echo " "
}

build_dist()
{
        echo "################################################"
        echo "############## Build Dist Folder #################"
        cd $siteDir && $grunt build
        echo " "
}

start_server()
{
        echo "################################################"
        echo "############## Starting Server #################"
        $forever start server.js
}

done_deploy()
{
        echo "#################### Done ######################"
        echo "################################################"
}

notify_slack_deploy_started()
{
	payload="{\"channel\": \"#deploy\" , \"username\": \"$NODE_ENV-front\" , \"text\": \":circle_yellow: Deploy started\" , \"icon_emoji\": \":vertical_traffic_light:\"}"
	curl -X POST -H 'Content-type: application/json' --data "$payload" $slackMessageUrl
}


notify_slack_deploy_ended_success()
{
	payload="{\"channel\": \"#deploy\" , \"username\": \"$NODE_ENV-front\" , \"text\": \":circle_green: Deploy finished\" , \"icon_emoji\": \":vertical_traffic_light:\"}"
	curl -X POST -H 'Content-type: application/json' --data "$payload" $slackMessageUrl
}

check_dirs

check_env

set_vars

git_checkout

notify_slack_deploy_started

if git status | grep --quiet -E "server.js|server/"; then
    echo "We have some server changes so we need to restart the server."
    stop_server
else
    echo "No changes to the sever files. Continuing without restarting."
fi


if git status | grep --quiet -E "package.json"; then
    echo "We have some new node package updates. install them."
    install_node_deps
else
    echo "No node package updates"
fi


install_bower_deps

build_dist

check_env

if git status | grep --quiet -E "server.js|server/"; then
    start_server
fi

done_deploy

notify_slack_deploy_ended_success
