#!/bin/bash
# slack-backup.sh
# by Chris Holt 2016-04-18

# Purpose:
#  Download slack history then convert it into browsable HTML files

##################################
# environment variables
START=$(date +%s)
version="1.95b"
author="Chris Holt, @humor4fun"
date="2016-05-05"
usage="Slack Backup by $author 
	Version: $version 
	Last updated date: $date 
	
Usage: 
	slack-backup.sh -t token [options]
	
	TOKEN is the only required variable, if no Group, Channel or User options are specified, only USERS will be queried and this list will be force-fetched. Use `slack-backup.sh --setup` first before attempting to use the main body of this script.

Options:
	-a | --all
		Implies --fetch --bypass-warnings. Use the web APIs to force a download of ALL Public Channels, Private Groups (the user has access to) and Direct Message conversations.
		Note: This WILL take quite a wile! Use with caution.

	-A|--all-users	
		Fetch all users to put into the Direct Messages list.
		Note: This WILL take quite a wile! Use with caution if downloading conversations for this list.
	
	-c | --public-channels FILE 
		FILE to read list of channel names for pulling Public Channel conversaitons. 

	-d | --debug-on
		Keep the Debug folder after the script executes. Defaults to OFF so this folder will be deleted, saving disk space.

	-f | --fetch
		Fetches the user lists for public, private and DM messages. Stores them in local files for later use. 

	-F | --fetch-only
		Like --fetch, but quits the remaining script execution afterwards. This will still perform all of the setup but will not execute the conversation download or cleaning.
	
	-g | --private-groups FILE 
		FILE to read list of group names for pulling Private Group conversaitons. 
	
	-h | --help 
		Display this help message. 
	
	-m | --direct-messages FILE 
		FILE to read list of usernames for pulling Direct Message conversaitons.
	
	-s | --setup 
		Run the software setup and check steps. This can take 1 - 5 minutes to execute.
	
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
# Use > 0 to consume one or more arguments per pass in the loop (e.g. some arguments don't have a corresponding value to go with it such as in the --default example).
slack_token="x"
dm_file="x"
dm_do=true
public_file="x"
public_do=false
private_file="x"
private_do=false
cont=false
setup=false
help=false
fetch=false
fetch_only=false
all=false
debug_off=true
fetch_all_users=false
fetch_users=false
fetch_public=false
fetch_private=false

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
			dm_do=true
			shift # past argument
		;;

		-c|--public-channels)
			public_file="$2"
			public_do=true
			shift # past argument
		;;

		-g|--private-groups)
			private_file="$2"
			private_do=true
			shift # past argument
		;;

		-a|--all) # parse all userIDs
			all=true
			fetch=true
			cont=true
		;;

		-A|--all-users) # fetch entire users list
			fetch_all_users=true
			dm_do=true
		;;

		-f|--fetch)
			fetch=true
		;;

		-F|--fetch-only)
			fetch=true
			fetch_only=true
		;;

		-h|--help)
			help=true
		;;

		-w|--bypass-warnings)
			cont=true
		;;

		-s|--setup)
			setup=true
		;;

		-d|--debug-on)
			debug_off=false;
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
else #prep the folders
	directory="slack-backup_`date +%Y-%m-%d-%H.%M.%S`"
	debug="$directory/_debug"
	logs="$debug/logs"
	mkdir $directory $debug $logs
	mkdir $logs/she_pg $logs/she_dm $logs/she_pc $logs/users
	mkdir $debug/users
fi

if ( $setup )
 then
	printf "Performing software updates/installs to make sure you have everything we need, then we'll get started.\n"
		apt-get -y install php5-common php5-cli wget  1>$logs/setup1.log 2>&1
		wget -qO- https://deb.nodesource.com/setup | bash - 1>$logs/setup2.log 2>&1
		apt-get -y install nodejs 1>$logs/setup3.log 2>&1
		npm install npm -g 1>$logs/setup4.log 2>&1
		npm install slack-history-export -g 1>$logs/setup5.log 2>&1
	printf "\n"
	exit 200
fi

if [[ $slack_token == "x" ]]
 then
	printf "ERROR: cannot proceed with ($slack_token) as the Slack API token. Please supply your Slack API token as a parameter."
	printf "Use --help for more information."
	exit 404
fi

#check Slack token for auth
printf "Checking Slack Token for valid auth..."
	wget https://slack.com/api/auth.test?token=$slack_token -O $debug/auth.test  1>$logs/wget_auth.log 2>&1
	auth=`cat $debug/auth.test | grep -m 1 "\"ok\": true,"`
	if ! ( $auth )
	 then
		printf "API Token not authorized. Quitting."
		exit 401
	fi
printf "done.\n"

# check for input warnings and notify
warn=false
if [[ $private_file == "x" ]]
 then
	printf "\tWARNING: proceeding without the list of Private Groups. If required, this list will be fetched.\n"
	warn=true
	fetch_private=true
	fetch=true
	private_file="private.list"
fi

if [[ $public_file == "x" ]]
 then
	printf "\tWARNING: proceeding without the list of Public Channels. If required, this list will be fetched.\n"
	warn=true
	fetch_public=true
	fetch=true
	public_file="public.list"
fi

if [[ $dm_file == "x" ]]
 then
	printf "\tWARNING: proceeding without the list of Direct Message personnel. If required, this list will be fetched.\n"
	warn=true
	fetch_users=true
	dm_file="dm.list"
	fetch=true
	if ( $fetch_all_users )
	 then
		fetch_users=false
	fi
fi

if ( $warn && ! $cont ) #check for suppression
 then #ask if the user wants to contninue with warnings
	printf "Warnings were generated, continue? (Y/n) "
	read cont
	if ! [[ $cont == "y" || $cont == "Y" ]]
	 then
		exit 301
	fi
fi

#check that files are set
if ( $fetch || $fetch_only || $all ) #unneccessary checks, but still, good writing form
 then
	dm_file="dm.list"
	private_file="groups.list"
	public_file="channels.list"
fi
##################################


##################################
# software prep
printf "Setting up working environment..."
	wget "https://gist.githubusercontent.com/dharmastyle/5d1e8239c5684938db0b/raw/cf1afe32967c6b497ed1ed97ca4a8ab5ee3df953/slack-json-2-html.php" -O $directory/slack-json-2-html.php 1>$logs/wget_tools1.log 2>&1
	chmod 777 $directory/slack-json-2-html.php
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
printf "Getting Channel meta data..."
	wget https://slack.com/api/channels.list?token=$slack_token -O "channels.list.json" 1>$logs/wget_meta01.log 2>&1
	cat channels.list.json | sed 's/{\"ok\":true,\"channels\"://1' | sed '$ s/.$//' > channels.json
	mv channels.list.json $debug
	mv channels.json $directory
printf "done.\n"

printf "Getting Users meta data..."
	wget https://slack.com/api/users.list?token=$slack_token -O "users.list.json" 1>$logs/wget_meta02.log 2>&1
	cat users.list.json | sed 's/{\"ok\":true,\"members\"://1' | sed '$ s/.$//' > users.json
	mv users.list.json $debug
	mv users.json $directory
printf "done.\n"

printf "Getting IntegrationLogs data..."
	wget https://slack.com/api/team.integrationLogs.list?token=$slack_token -O "team.integrationLogs.json" 1>$logs/wget_meta03.log 2>&1
	#if you are an admin then use this
		#cat team.integrationLogs.json | sed 's/{\"ok\":true,\"members\"://1' |sed '$ s/.$//' > integration_logs.json
	#else use this default to create the blank file
		#most users won't have slack-admin rights for this, check for an error and if it occured then just write a blank file "[\n]"
		printf "[\n\n]" >> integration_logs.json
	mv team.integrationLogs.json $debug
	mv integration_logs.json $directory
printf "done.\n"

printf "Getting additional meta data..."
	wget https://slack.com/api/team.info?token=$slack_token -O "$debug/team.info.json" 1>$logs/wget_meta04.log 2>&1
	wget https://slack.com/api/reminders.list?token=$slack_token -O "$debug/reminders.list.json" 1>$logs/wget_meta05.log 2>&1
	wget https://slack.com/api/emoji.list?token=$slack_token -O "$debug/emoji.list.json" 1>$logs/wget_meta06.log 2>&1
	wget https://slack.com/api/im.list?token=$slack_token -O "$debug/im.list.json" 1>$logs/wget_meta07.log 2>&1
	wget https://slack.com/api/groups.list?token=$slack_token -O "$debug/groups.list.json" 1>$logs/wget_meta08.log 2>&1
	wget https://slack.com/api/channels.list?token=$slack_token -O "$debug/channels.list.json" 1>$logs/wget_meta09.log 2>&1
	wget https://slack.com/api/mpim.list?token=$slack_token -O "$debug/mpim.list.json" 1>$logs/wget_meta10.log 2>&1 #slack-history-export can't handle these yet
printf "done.\n"
##################################


##################################
# get message data and parse it through the first pass of cleansing

if ( $fetch )
 then
	printf "Parsing chat thread lists for names..."	
		if ( $fetch_all_users )
		 then
			cat $debug/users.list.json | tr , '\n' | grep -Po '"name":".*"' | sed 's/.*\":\"//g' | sed 's/"//g' > $dm_file
		fi
		if ( $fetch_users )
		 then
			cat $debug/im.list.json | tr , '\n' | grep -Po '"user":".*"' | sed 's/.*\":\"//g' | sed 's/"//g' > $debug/im.list
			usr_file=()
			mapfile -t user_list < $debug/im.list
			for user in "${user_list[@]}"
			 do
				wget "https://slack.com/api/users.info?token=$slack_token&user=$user" -O "$debug/users/$user.json" 1>$logs/users/$user.log 2>&1
				usr_file+=(`cat $debug/users/$user.json | tr , '\n' | grep -Po '"name":".*"' | sed 's/.*\":\"//g' | sed 's/"//g'`)
			 done
			printf "%s\n" "${usr_file[@]}" > $dm_file
		fi
		if ( $fetch_private )
		then 
			cat $debug/groups.list.json | tr , '\n' | grep -Po '"name":".*"' | sed 's/.*\":\"//g' | sed 's/"//g' > $private_file
		fi
		if ( $fetch_public )
		 then
			cat $debug/channels.list.json | tr , '\n' | grep -Po '"name":".*"' | sed 's/.*\":\"//g' | sed 's/"//g' > $public_file
		fi		
	printf "done.\n"

	if ( $fetch_only )
	 then
		exit 200
	fi
fi

if ( $dm_do || $all )
 then
	printf "Getting Direct Messages..."
		touch $dm_file.act 	$dm_file.drop
		rDIR=0
		rADIR=0
		mapfile -t dm_list < $dm_file
		for dm in "${dm_list[@]}"
		do
			rADIR=$(($rADIR + 1))			
			printf "$dm, "
			dir="$directory/$dm"
			mkdir $dir
			slack-history-export --token $slack_token --username $dm --directory $dir 1>$logs/she_dm/$dm.log 2>&1

			if [[ `ls -1 $dir | wc -l` -eq 0 ]]
			 then
				rm -r $dir
				sed -i '$ a $dm' $dm_file.drop
			 else
				rDIR=$(($rDIR + 1))
				sed -i '$ a $dm' $dm_file.act
			fi
		done
		mv $dm_file.act $dm_file.drop $directory
	printf "done!\n"
fi

if ( $private_do || $all )
 then
	printf "Getting Private Groups..."
		touch $private_file.act $private_file.drop
		rPRIV=0
		rAPRIV=0
		mapfile -t private_list < $private_file
		for pg in "${private_list[@]}"
		do
			rAPRIV=$(($rAPRIV + 1))			
			printf "$pg, "
			dir="$directory/$pg"
			mkdir $dir
			slack-history-export --token $slack_token --group $pg --directory $dir 1>$logs/she_pg/$pg.log 2>&1
			if [[ `ls -1 $dir | wc -l` -eq 0 ]]
			 then
				rm -r $dir
				sed -i '$ a $dm' $private_file.drop
			else
				rPRIV=$(($rPRIV + 1))
				sed -i '$ a $dm' $private_file.act
			fi
		done
		mv $private_file.act $private_file.drop $directory
	printf "done!\n"
fi

if ( $public_do || $all )
 then
	printf "Getting Public Channels..."
		touch $public_file.act 	$public_file.drop
		rPUB=0
		rAPPUB=0		
		mapfile -t public_list < $public_file
		for pc in "${public_list[@]}"
		do
			rAPUB=$(($rAPUB + 1))				
			printf "$pc, "
			dir="$directory/$pc"
			mkdir $dir
			slack-history-export --token $slack_token --channel $pc --directory $dir 1>$logs/she_pc/$pc.log 2>&1
			if [[ `ls -1 $dir | wc -l` -eq 0 ]]
			 then
				rm -r $dir
				sed -i '$ a $dm' $public_file.drop
			else
				rPUB=$(($rPUB + 1))
				sed -i '$ a $dm' $public_file.act
			fi
		done
		mv $public_file.act $public_file.drop $directory
	printf "done!\n"
fi

printf "Finished downloading history.\n"

# clean up the data
printf "Making things pretty..."
	cd $directory	
	php slack-json-2-html.php # 1>$logs/sj2h.log 2>&1
	cd ..
printf "done.\n"
##################################


##################################
# clean up the environment
printf "\nCleaning up..."
	mv $directory/slack-json-2-html.php $debug/ 1>$logs/cleanup01.log 2>&1
	cp $dm_file $private_file $public_file $debug/ 1>$logs/cleanup02.log 2>&1
	mv $directory/* $debug 1>$logs/cleanup03.log 2>&1
	mv $directory/../slack2html/ $directory/ 1>$logs/cleanup04.log 2>&1
	mv $dm_file $public_file $private_file $directory

	if ( $debug_off )
	 then
		rm -r $debug 1>$logs/cleanup05.log 2>&1
	fi

printf "done.\n"
printf "\nCompleted Task.\n"
END=$(date +%s)
##################################


##################################
# print a report
SEC=$(( $END - $START ))
HOUR=$(( $SEC / 3600 ))
MIN=$(( ( $SEC % 3600 ) / 60 ))
SEC=$(( $SEC % 60 ))
REPORT="Execution Report:\n
Channels Counts\t\t   Checked  Downloaded
	 Private Groups:\t$rAPRIV\t$rPRIV
	Public Channels:\t$rAPUB\t$rPUB
	Direct Messages:\t$rADIR\t$rDIR
Time to Complete: $HOUR:$MIN:$SEC\n"

printf "$REPORT"
printf "$REPORT" > $directory/benchmark.log
##################################

exit 200
