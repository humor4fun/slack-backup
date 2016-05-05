# slack-backup
For those of us that like to log our chat history... No more will coworkers be able to delete messages from Slack! Use your Slack Web API token to download all of your messages then beautify the JSON jargon into a readable HTML interface. This tool is able to get an up-to-date list of IM/Group/Channels that user has access to, removing the need to hardcode those lists.

Cron-able script to use Slack APIs to archive all messages. 

## Installation
1. Save slack-backup.sh to a file
2. `chmod 777 slack-backup.sh`
3. Get a Slack API token from your account-> [Can be generated here] (https://api.slack.com/web)
4. `./slack-backup.sh --setup`

## Usage
`./slack-backup.sh -t token [options]`
```
./slack-backup.sh --debug-on --all --slack-token-file token
./slack-backup.sh -d -a -t token
```
```
./slack-backup.sh --slack-token-file token --direct-messages dm.list --public-channels pc.list --private-groups pg.list
./slack-backup.sh -t token -m dm.list -c pc.list -g pg.list
```
## Options
```
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
-s | --setup 
	Run the software setup and check steps. This can take 1 - 5 minutes to execute.
-t | --slack-token-file  FILE
	Text FILE containing the Slack API token. 
-T | --slack-token TOKEN 
	Slack token embedded into the command parameters.
  NOTE: Token can be generated here: https://api.slack.com/web 
-w | --bypass-warnings 
	Automatically continue even if warnings occur during setup. \n"
```

## Thanks to: 
- @hisabimbola [slack-history-export] (https://github.com/hisabimbola/slack-history-export)
- @dharmastyle [slack2html.php] (https://gist.github.com/dharmastyle/5d1e8239c5684938db0b)
- Lots of Stack Overflow pages and Google searches for the inspiration to make this happen
