# slack-backup
For those of us that like to log our chat history... No more will coworkers be able to delete messages from Slack! Use your Slack Web API token to download all of your messages then beautify the JSON jargon into a readable HTML interface. This tool is able to get an up-to-date list of IM/Group/Channels that user has access to, removing the need to hardcode those lists.

Cron-able script to use Slack APIs to archive all messages. 

## System Requirements
When I write bash scripts, I use a Kali linux VM that I try to keep as vanilla as possible, especially for new scripts so that I can catch all of the tools/packages that will be needed for the `--setup` switch. This script will almost certainly NOT function on MacOSX and will need modification to run on non Debian *nix machines.

Recommended: `Debian-Based Linux with a 4.9 kernel` 

When I wrote this script it was on a 2015 build of Kali, but currently I am working off of the `2016.2` version.
```
root@kali:~# uname -a
Linux kali 4.9.0-kali3-amd64 #1 SMP Debian 4.9.16-1kali1 (2017-03-24) x86_64 GNU/Linux
```

## Installation
1. Save slack-backup.sh to a file
2. `chmod 777 slack-backup.sh`
3. Get a Slack API token from your account-> [Can be generated here] (https://api.slack.com/web)
4. Put that token into a file and save it
5. Execute the setup to make sure you have all the required libraries `./slack-backup.sh --setup`

## Usage
Quick `./slack-backup --nike token`

General:  `./slack-backup.sh -t token [options]`

Run a backup routine of just the Direct Messages conversations that you have had with all users in your organization.
`./slack-backup.sh -t token`

Run a backup routine of all Public Channels, Private Groups and Direct Messages within your organization.
`./slack-backup.sh --debug-on --all --slack-token-file token`

Run a backup routine of the Public Channels specified in pc.list, Private Groups specified in pg.list, and Direct Messages for users specified in dm.list.
`./slack-backup.sh --slack-token-file token --direct-messages dm.list --public-channels pc.list --private-groups pg.list`

## Options
```
slack-backup.sh -t token [options]
	
	TOKEN is the only required variable, if no Group, Channel or User options are specified, only USERS will be queried and this list will be force-fetched. Use \"slack-backup.sh --setup\" first before attempting to use the main body of this script.

Options:
	-a | --all
		Implies --fetch --bypass-warnings. Use the web APIs to force a download of ALL Public Channels, Private Groups (the user has access to) and Direct Message conversations.
		Note: This WILL take quite a wile! Use with caution.

	-A | --all-users	
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

	--nike TOKEN
		\"Just Do It!\"
		This option will run --setup then execute the entire script again using the --all option with --debug-on and use the supplied token. 
	
	-s | --setup 
		Run the software setup and check steps. This can take 1 - 5 minutes to execute.
	
	-t | --slack-token-file  FILE
		Text FILE containing the Slack API token. 
	
	-T | --slack-token TOKEN 
		Slack token embedded into the command parameters.
	NOTE: Token can be generated here: https://api.slack.com/web 
	
	-w | --bypass-warnings 
		Automatically continue even if warnings occur during setup.
```

## Sample Input Files
token:
```
xoxp-0123456789-0123456789-01234567890-ABCDEF
```
dm.list:
```
john.doe
jane.doe
mr.potatohead
buzz.lightyear
awesomejoe.brown
slackbot
```
pc.list:
```
everyone
system-outtages
github-dev
```
pg.list:
```
team1
team2
```

## Thanks to: 
- @hisabimbola [slack-history-export] (https://github.com/hisabimbola/slack-history-export)
- @dharmastyle [slack2html.php] (https://gist.github.com/dharmastyle/5d1e8239c5684938db0b)
- Lots of Stack Overflow pages and Google searches for the inspiration to make this happen
