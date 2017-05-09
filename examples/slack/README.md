# [janis](https://www.janis.ai) Slack Bot Ruby Example

This is a simple Slack bot with janis integration example based on [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot)

### Sign Up With janis

You'll need an API key from janis, as well as a Client Key for each Chatbot.  You can get both of those (free) when you add [janis for Slack](https://slack.com/oauth/authorize?scope=users:read,users:read.email,commands,chat:write:bot,channels:read,channels:write,bot&client_id=23850726983.39760486257) via through a conversation with the janis bot. 

### Connecting Your Bot to Slack

To connect a bot to Slack, [get a Bot API token from the Slack integrations page](https://my.slack.com/services/new/bot).

### Installation

```bash
$ gem install slack-ruby-bot ; gem install janis
```

### Usage

Set your environmental variables for `JANIS_API_KEY`, `JANIS_CLIENT_KEY`, `SLACK_API_TOKEN`.

```bash
$ export JANIS_API_KEY=xxxxxxxxxxxxxxxxxxxx
$ export JANIS_CLIENT_KEY=xxxxxxxxxxxxxxxxxxxx
$ export SLACK_API_TOKEN=xxxxx-xxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxx
```

Run the following command to get your bot online:

```bash
$ ruby slackbot.rb
```
