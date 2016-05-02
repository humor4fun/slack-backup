#!/bin/bash
# slack-backup.sh
# by Chris Holt 2016-04-18

# Purpose:
#  Download slack history then convert it into browsable HTML files

##################################
# environment variables
version="1.1"
author="Chris Holt, @humor4fun"
date="2016-05-02"
usage="Slack Backup by $author 
	Version: $version 
	Last updated date: $date 
	
Usage: 
	slack-backup.sh -t token [options]

Options:
	-c | --public-channels FILE 
		FILE to read list of channel names for pulling Public Channel conversaitons. 
	
	-g | --private-groups FILE 
		FILE to read list of group names for pulling Private Group conversaitons. 
	
	-h | --help 
		Display this help message. 
	
	-m | --direct-messages FILE 
		FILE to read list of usernames for pulling Direct Message conversaitons.
	
	-s | --bypass-setup 
		Skip the software setup and check steps. 
		Possibly speeds up run time by ~10-50 percent depending on number of conversations being downloaded.
	
	-t | --slack-token-file  FILE
		Text FILE containing the Slack API token. 
	
	-T | --slack-token TOKEN 
		Slack token embedded into the command parameters.
	NOTE: Token can be generated here: https://api.slack.com/web 
	
	-w | --bypass-warnings 
		Automatically continue even if warnings occur during setup. \n"


printf "Slack-Backup $version by $author\n"
##################################


##################################
# read input from command line
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
slack_token="x"
dm_file="x"
public_file="x"
private_file="x"
cont=false
setup=true
help=false

while [[ $# > 0 ]]
do
key="$1"

case $key in
    -t|--slack-token-file)
    slack_token="`cat $2`"
    shift # past argument
    ;;
    -T|--slack-token)
    slack_token="$2"
    shift # past argument
    ;;

    -m|--direct-messages)
    dm_file="$2"
    shift # past argument
    ;;

    -c|--public-channels)
    public_file="$2"
    shift # past argument
    ;;

    -g|--private-groups)
    private_file="$2"
    shift # past argument
    ;;

    -h|--help)
    help=true
    ;;

    -w|--bypass-warnings)
    cont=true
    ;;
    
    -s|--bypass-setup)
    setup=false
    ;;

    *) # unknown option
    ;;
esac
shift # past argument or value
done
##################################


##################################
# check for input errors and fail
if ( $help )
 then
	printf "$usage"
	exit 200
fi

if [[ $slack_token == "x" ]]
 then
	printf "ERROR: cannot proceed with ($slack_token) as the Slack API token. Please supply your Slack API token as a parameter."
	printf "Use --help for more information."
	exit 404
fi
##################################


##################################
# check for input warnings and notify
warn=false
if [[ $private_file == "x" ]]
 then
	printf "WARNING: proceeding without the list of Private Groups."
	$warn=true
fi

if [[ $public_file == "x" ]]
 then
	printf "WARNING: proceeding without the list of Public Channels."
	$warn=true
fi

if [[ $dm_file == "x" ]]
 then
	printf "WARNING: proceeding without the list of Direct Message personnel."
	$warn=true
fi

if ( $warn && $cont ) #check for suppression
 then #ask if the user wnts to contninue with warnings
	printf "Warnings were generated, continue? (Y/n) "
	read cont
	if ! [[ $cont == "y" || $cont == "Y" ]]
	 then
		exit 301
	fi
fi
##################################


##################################
# software prep
if ( $setup )
 then
	printf "\nPerforming software updates/installs to make sure you have everything we need, then we'll get started.\n"
		apt-get -y install php5-common php5-cli wget
		wget -qO- https://deb.nodesource.com/setup | bash -
		apt-get -y install nodejs
		npm install npm -g
		npm install slack-history-export -g
fi

printf "\nSetting up working environment..."
	directory="slack-backup_`date +%Y-%m-%d-%H.%M.%S`"
	debug="$directory/_debug"
	mkdir $directory $debug
	#slack_token=$1

##################################


##################################
#check Slack token for auth
printf "Checking Slack Token for valid auth..."
	auth=`wget https://slack.com/api/auth.test?token=$slack_token | grep -m 1 "\"ok\": true,"`
	if ! ( $auth )
	 then
		printf "API Token not authorized. Quitting."
		exit 401
	fi
printf "done.\n"
##################################


##################################
# fetch metadata
#Get a json response from the slack API then clean it up; remove the first X lines of the responses that show: 
	#{
	#    "ok": true,
	#    "channels": 
	## and the last line that shows:
	#}
# from all files created as a result of the wget api calls.
printf "\nGetting Channel meta data..."
	wget https://slack.com/api/channels.list?token=$slack_token -O "channels.list.json"
printf "done.\n"

printf "\nCleaning Channel meta data..."
	sed 's/{\"ok\":true,\"channels\"://1w tmp.json' channels.list.json
	sed '$ s/.$//w channels.json' tmp.json
	rm -v tmp.json 
	mv -v channels.list.json $debug
	mv -v channels.json $directory
printf "done.\n"

printf "\nGetting Users meta data..."
	wget https://slack.com/api/users.list?token=$slack_token -O "users.list.json"	
printf "done.\n"

printf "\nCleaning Users meta data..."
	sed 's/{\"ok\":true,\"members\"://1w tmp.json' users.list.json
	sed '$ s/.$//w users.json' tmp.json
	rm -v tmp.json 
	mv -v users.list.json $debug
	mv -v users.json $directory
printf "done.\n"

printf "\nGetting IntegrationLogs data..."
	wget https://slack.com/api/team.integrationLogs.list?token=$slack_token -O "team.integrationLogs.json"
printf "done.\n"
	
printf "\nCleaning IntegrationLogs data..."
	sed 's/{\"ok\":true,\"members\"://1w tmp.json' team.IntegrationLogs.json
	printf "[\n\n]" >> integration_logs.json
		#most users won't have slack-admin rights for this, check for an error and if it occured then just write a blank file "[\n]"
	#if you have slack-admin rights then use the sed line below
	#sed '$ s/.$//w integration_logs.json' tmp.json
	rm -v tmp.json
	mv -v team.integrationLogs.json $debug
	mv -v integration_logs.json $directory
printf "done.\n"

printf "\nGetting optional meta data..."
	wget https://slack.com/api/team.info?token=$slack_token -O "$debug/team.info.json"
	wget https://slack.com/api/reminders.list?token=$slack_token -O "$debug/reminders.list.json"
	wget https://slack.com/api/emoji.list?token=$slack_token -O "$debug/emoji.list.json"
printf "done.\n"

printf "\nGetting list of all chat threads..."
	wget https://slack.com/api/im.list?token=$slack_token -O "$debug/im.list.json"
	wget https://slack.com/api/groups.list?token=$slack_token -O "$debug/groups.list.json"
	wget https://slack.com/api/channels.list?token=$slack_token -O "$debug/channels.list.json"
	#wget https://slack.com/api/mpim.list?token=$slack_token -O "$debug/mpim.list.json"
		#slack-history-export can't handle these yet
	#wget https://slack.com/api/mpim.history?token=$slack_token&channel=$mpim_channel -O "$debug/mpim.history.json"
printf "done.\n"

printf "\nParsing chat thread lists..."
	#python parse-json.py im.list.json > dm_list
	#mv -v im.list.json $debug
	#python parse-json.py groups.list.json > private_list
	#mv -v groups.list.json $debug
	#python parse-json.py channels.list.json > public_list
	#mv -v channels.list.json $debug
printf "done.\n"
##################################


##################################
# get message data and parse it through the first pass of cleansing
printf "\nGetting Direct Messages..."
	mapfile -t dm_list < $dm_file
	#generate a list of IMs from the im.list.json file
	for dm in "${dm_list[@]}"
	do
		printf "\nDM with: $dm\n"
		dir="$directory/$dm"
		mkdir $dir
		slack-history-export --token $slack_token --type 'dm' --username $dm --directory $dir #--filename $dm
	done
printf "done.\n"

printf "\nGetting Private channels..."
	mapfile -t private_list < $private_file
	#generate a list of channels from the groups.list.json file
	for dm in "${private_list[@]}"
	do
		printf "\nPrivate Channel: $dm\n"
		dir="$directory/$dm"
		mkdir $dir
		slack-history-export --token $slack_token --type 'group' --group $dm --directory $dir #--filename "$dm"
	done
printf "done.\n"

printf "\nGetting Public channels..."
	mapfile -t public_list < $public_file
	#generate a list of channels from the channels.list.json file
	for dm in "${public_list[@]}"
	do
		printf "\nPublic Channel: $dm\n"
		dir="$directory/$dm"
		mkdir $dir
		slack-history-export --token $slack_token --type 'channel' --channel $dm --directory $dir #--filename "$dm"
	done
printf "done.\n"

printf "\nFinished downloading history.\n"
##################################


##################################
# clean up the data
printf "\nGetting prettifying resources..."
	cd $directory
	wget "https://gist.githubusercontent.com/dharmastyle/5d1e8239c5684938db0b/raw/cf1afe32967c6b497ed1ed97ca4a8ab5ee3df953/slack-json-2-html.php"
	chmod 777 slack-json-2-html.php
printf "done.\n"

printf "\nMaking things pretty..."
	php slack-json-2-html.php
printf "done.\n"
##################################


##################################
# clean up the environment
printf "\nCleaning up..."
	rm "slack-json-2-html.php"
	mv -v *.json $debug
	cd ..
	mv -v slack2html/ $directory/
	cd $directory
	mv slack2html _slacklog_ui
printf "done.\n"
##################################

printf "\nCompleted Task.\n"
exit 200

