# [Janis](https://www.janis.ai) Slack Chatbot Ruby Example

This is a simple Slack bot with a Janis integration example based on [slack-ruby-bot](https://github.com/dblock/slack-ruby-bot) and assumes you are coding and hosting your own Chatbot.  If you want to experiment with a hosted Chatbot example, you can remix our [Glitch](https://glitch.com/edit/#!/blaze-temper) project. 


### Sign Up With janis

You'll need an API key from Janis and a Client Key for your Chatbot.  You can get both of those (free) when you add [Janis for Slack](https://www.janis.ai) and start a conversation with Janis in Slack.

### Connecting Your Bot to Slack

To connect a bot to Slack, [get a Bot API token from the Slack integrations page](https://my.slack.com/services/new/bot).

### Installation

```bash
$ gem install slack-ruby-bot ; gem install janis-ai
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
