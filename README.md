# slack-backup
cron-able script to use Slack APIs to archive all messages

For those of us that like to log our chat history... No more will coworkers be able to delete messages from Slack!

Use your Slack Web API token to download all of your messages then beautify the JSON jargon into a readable HTML interface.

Able to get an up-to-date list of IM/Group/Channels that user has access to, removing the need to hardcode those lists.

Credit to: https://github.com/hisabimbola/slack-history-export https://gist.githubusercontent.com/dharmastyle/5d1e8239c5684938db0b/raw/cf1afe32967c6b497ed1ed97ca4a8ab5ee3df953/slack-json-2-html.php


Sample Executions:
./slack-backup.sh --debug-on --all --slack-token-file token

./slack-backup.sh -d -a -t token

./slack-backup.sh --debug-on --bypass-setup --all --slack-token-file token

./slack-backup.sh -d -s -a -t token

./slack-backup.sh --debug-on --bypass-setup --slack-token-file token --direct-messages dm.list --public-channels pc.list --private-groups pg.list

./slack-backup.sh -s -t token -m dm.list -c pc.list -g pg.list
