#!/bin/bash
# slack-backup.sh
# by Chris Holt 2016-04-18

# Purpose:
#  Download slack history then convert it into browsable HTML files

version="1.0"
author="Chris Holt, @humor4fun"

printf "Slack-Backup $version by $author\n Thanks for using this tool to log your Slack channels.\n"
if [[ -z "$1" ]]
 then
	printf "ERROR: cannot proceed with ($1) as the Slack API token. Please supply your Slack API token as a parameter."
	printf " \n token can be generated here: https://api.slack.com/web"
	printf "\n\n Usage:\n\tslack-backup.sh abcd-0123456789-0123456789-01234567890-abc123def4\n"
	exit 401
fi

printf "\nPerforming software updates/installs to make sure you have everything we need, then we'll get started.\n"
	apt-get -y install php5-common php5-cli wget
	wget -qO- https://deb.nodesource.com/setup | bash -
	apt-get -y install nodejs
	npm install npm -g
	npm install slack-history-export -g

printf "\nSetting up working environment..."
	directory="slack-backup_`date +%Y-%m-%d-%H.%M.%S`"
	debug="$directory/_debug"
	mkdir $directory $debug
	slack_token=$1

#Get a json response from the slack API then clean it up; remove the first X lines of the responses that show: 
	#{
	#    "ok": true,
	#    "channels": 
	## and the last line that shows:
	#}
# from all files created as a result of the wget api calls.

printf "\nGetting Channel meta data...\n"
	wget https://slack.com/api/channels.list?token=$slack_token -O "channels.list.json"
printf "\nCleaning Channel meta data...\n"
	sed 's/{\"ok\":true,\"channels\"://1w tmp.json' channels.list.json
	sed '$ s/.$//w channels.json' tmp.json
	rm -v tmp.json 
	mv -v channels.list.json $debug
	mv -v channels.json $directory

printf "\nGetting Users meta data...\n"
	wget https://slack.com/api/users.list?token=$slack_token -O "users.list.json"	
printf "\nCleaning Users meta data...\n"
	sed 's/{\"ok\":true,\"members\"://1w tmp.json' users.list.json
	sed '$ s/.$//w users.json' tmp.json
	rm -v tmp.json 
	mv -v users.list.json $debug
	mv -v users.json $directory

printf "\nGetting IntegrationLogs data...\n"
	wget https://slack.com/api/team.integrationLogs.list?token=$slack_token -O "team.integrationLogs.json"	
printf "\nCleaning IntegrationLogs data...\n"
	sed 's/{\"ok\":true,\"members\"://1w tmp.json' team.IntegrationLogs.json
	printf "[\n\n]" >> integration_logs.json
		#most users won't have slack-admin rights for this, check for an error and if it occured then just write a blank file "[\n]"
	#if you have slack-admin rights then use the sed line below
	#sed '$ s/.$//w integration_logs.json' tmp.json
	rm -v tmp.json
	mv -v team.integrationLogs.json $debug
	mv -v integration_logs.json $directory

printf "\nGetting optional meta data...\n"
	wget https://slack.com/api/team.info?token=$slack_token -O "$debug/team.info.json"
	wget https://slack.com/api/reminders.list?token=$slack_token -O "$debug/reminders.list.json"
	wget https://slack.com/api/emoji.list?token=$slack_token -O "$debug/emoji.list.json"
printf "\nDone fetching meta data.\n"

#this piece is coming soon
printf "\nGetting list of all chat threads...\n"
	wget https://slack.com/api/im.list?token=$slack_token -O "$debug/im.list.json"
	wget https://slack.com/api/groups.list?token=$slack_token -O "$debug/groups.list.json"
	wget https://slack.com/api/channels.list?token=$slack_token -O "$debug/channels.list.json"
	#wget https://slack.com/api/mpim.list?token=$slack_token -O "$debug/mpim.list.json"
		#slack-history-export can't handle these yet
	#wget https://slack.com/api/mpim.history?token=$slack_token&channel=$mpim_channel -O "$debug/mpim.history.json"
printf "\nParsing chat thread lists...\n"
	#python parse-json.py im.list.json > dm_list
	#mv -v im.list.json $debug
	#python parse-json.py groups.list.json > private_list
	#mv -v groups.list.json $debug
	#python parse-json.py channels.list.json > public_list
	#mv -v channels.list.json $debug


printf "\nGetting Direct Messages...\n"
dm_list=( "insert" "your" "list" "by" "hand" )
#generate a list of IMs from the im.list.json file
for dm in "${dm_list[@]}"
do
	printf "\nDM with: $dm\n"
	dir="$directory/$dm"
	mkdir $dir
	slack-history-export --token $slack_token --type 'dm' --username $dm --directory $dir #--filename $dm
done

printf "\nGetting Private channels...\n"
private_list=( "insert" "your" "list" "by" "hand" )
#generate a list of channels from the groups.list.json file
for dm in "${private_list[@]}"
do
	printf "\nPrivate Channel: $dm\n"
	dir="$directory/$dm"
	mkdir $dir
	slack-history-export --token $slack_token --type 'group' --group $dm --directory $dir #--filename "$dm"
done

printf "\nGetting Public channels...\n"
public_list=( "insert" "your" "list" "by" "hand" )
#generate a list of channels from the channels.list.json file
for dm in "${public_list[@]}"
do
	printf "\nPublic Channel: $dm\n"
	dir="$directory/$dm"
	mkdir $dir
	slack-history-export --token $slack_token --type 'channel' --channel $dm --directory $dir #--filename "$dm"
done


printf "\nFinished downloading history.\n"

printf "\nGetting prettifying resources...\n"
	cd $directory
	wget "https://gist.githubusercontent.com/dharmastyle/5d1e8239c5684938db0b/raw/cf1afe32967c6b497ed1ed97ca4a8ab5ee3df953/slack-json-2-html.php"
	chmod 777 slack-json-2-html.php

printf "\nMaking things pretty...\n"
	php slack-json-2-html.php

printf "\nCleaning up...\n"
	rm "slack-json-2-html.php"
	mv -v *.json $debug
	cd ..
	mv -v slack2html/ $directory/
	cd $directory
	mv slack2html _slacklog_ui

printf "\nCompleted Task.\n"
exit 200
