# [Janis](https://developer.Janis.ai) - Manage AI From Slack
## For Chatbots Built in Python

Janis adds powerful AI management capabilities to Slack through a simple and intuitive natural language interface. Add Janis to Slack, then connect your AI in 60 seconds and start training from Slack in Sandbox Mode.  Integrate Janis into bots you're building with this SDK to monitor AI performance, get real-time alerts when your AI needs help, actionable analytics that tell you what to train and then measure results.  Stop training AI like you're training software and start training AI like a valued member of your team.

NOTE:  Currently Janis provides full support for API.AI developers, with limited support for Wit.ai developers.

This module has been tested with Messenger, Slack, Skype, and Microsoft Webchat. Please see our [examples](./examples/).
It supports bot developers working in Node, Python and Ruby and popular bot building frameworks like Botkit and Botpress.

### What you can do with Janis:
You can view a full list of features at (https://developer.janis.ai).  Key features include:
* Janis Train: Simulate automated conversations in a dedicated Slack channel. Collaborate with your team to define and manage intents, what users say, and your company's responses.
* Janis Triage: Get real-time alerts when your AI needs help. Pause your bot so you can chat live with your customer, while training your AI to learn from a customer transcript.
* Janis Insight: Drill down into bottlenecks and see where your AI needs more training, then measure the impact of additional training through ad hoc reports.

### What you need to get started:
* [Janis for Slack](https://slack.com/oauth/authorize?scope=im:history,users:read,users:read.email,commands,chat:write:bot,chat:write:user,channels:read,channels:history,files:write:user,channels:write,links:read,links:write,bot&client_id=23850726983.39760486257)
* [A Chatbot built in Ruby](./examples/)
* [Optional: An API.AI account](http://www.api.ai) 

##### Operational Dependencies:
1.  You'll need an API key from Janis and a Client Key for each Chatbot you register with Janis.  You can get both of those (free) when you add Janis to Slack. 
2.  If you're building a Messenger Chatbot, you'll need to setup a Facebook App, Facebook Page, get the Page Access Token from Facebook and link the Facebook App to the Facebook Page for Janis to work. This is standard for any Chatbot you build for Messenger.

### Installation

```bash
$ gem install janis
```


### Usage

Set your environmental variables for `JANIS_API_KEY`, `JANIS_CLIENT_KEY`, `ACCESS_TOKEN`.

```bash
$ export JANIS_API_KEY=xxxxxxxxxxxxxxxxxxxx
$ export JANIS_CLIENT_KEY=xxxxxxxxxxxxxxxxxxxx
$ export ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Add the janis class to your code and set the required parameter values.
```ruby
require 'janis'

# janis Api Key
janis.apikey = ENV['JANIS_API_KEY']
# Unique janis Client Key for your bot
janis.clientkey = ENV['JANIS_CLIENT_KEY']
# possible values: "messenger" or "slack"
janis.platform = "messenger" 
# Page Access Token (only required for Messenger bots)
janis.token = ENV['ACCESS_TOKEN']
```
##### Incoming Message Schema:
Throughout this documentation, you will see references to `incomingMessage`. Depending on whether you have a Messenger or Slack bot, the schema will be different. The value of `incomingMessage` should be equal to the message you receive directly from either the Messenger webhook response, or from the Slack RTM event response.

```python
# Example of a Slack Incoming Message
{
    "type": "message",
    "channel": "D024BE91L",
    "user": "U2147483697",
    "text": "Hello world",
    "ts": "1355517523.000005"
}

# Example of a Messenger Incoming Message
{
  "sender":{
    "id":"USER_ID"
  },
  "recipient":{
    "id":"PAGE_ID"
  },
  "timestamp":1458692752478,
  "message":{
    "mid":"mid.1457764197618:41d102a3e1ae206a38",
    "seq":73,
    "text":"hello, world!",
    "quick_reply": {
      "payload": "DEVELOPER_DEFINED_PAYLOAD"
    }
  }
}  
```

##### Outgoing Message Schema:
Throughout this documentation, you will see references to `outgoingMessage`. Depending on whether you have a Messenger or Slack bot, the schema, as defined by each platform, will be different. Every time you track an outgoing message, the schema requirements match the respective platform.

```python
# Example of Slack Outgoing Message
{
    "channel": "C024BE91L",
    "text": "Hello world"
}

# Exmaple of Messenger Outgoing Message
{
  "recipient":{
    "id":"USER_ID"
  },
  "message":{
    "text":"hello, world!"
  }
}
```

##### Tracking received messages:

When your bot receives an incoming message, you'll need to log the data with janis by calling to `janis.hopIn`. 
__Note__: janis can pause your bot so that it doesn't auto response while a human has taken over. The server response from your `hopIn` request will pass the `paused` state. Use that to stop your bot from responding to an incoming message. Here is an example:

```ruby
hopInResponse = janis.hopIn(incomingMessage)
if hopInResponse['paused'] != true
# proceed to process incoming message
 ...
```

##### Tracking sent messages:

Each time your bot sends a message, make sure to log that with janis by calling to `janis.hopOut`. Here is an example of a function that we're calling `sendIt` that tracks an outgoing message and at the same time, has the bot say the message:
```ruby
def sendIt(channel, text)
    # schema matches Messenger
    outgoingMessage = {recipient: {id: channel},message: {text: text}}
    janis.hopOut(outgoingMessage)
    client.say({'text': text, 'channel': channel})  # <= example of bot sending reply
    ...
```

##### Log Unknown Intents:

Find the spot in your code your bot processes incoming messages it does not understand. Within that block of code, call to `janis.logUnkownIntent` to capture these conversational ‘dead-ends’. Here's an example:

```ruby
# let the user know that the bot does not understand
sendIt(recipient_id, 'Huh?')
# capture conversational dead-ends.
janis.logUnknownIntent(incomingMessage) 
```
##### Dial 0 to Speak With a Live Human Being:

janis can trigger alerts to suggest when a human should take over for your Chatbot. To enable this, create an intent such as when a customer explicitly requests live assistance, and then include the following lines of code where your bot listens for this intent:

```ruby
# match an intent to talk to a real human
if text == 'help'
    # let the user know that they are being routed to a human
    sendIt(recipient_id, 'Hang tight. Let me see what I can do.')
    # send a janis alert to your slack channel
    # that the user could use assistance
    janis.assistanceRequested(incomingMessage);
```

##### Human Take Over:

To enable the ability to have a human take over your bot, add the code below to subscribe to the 'chat response' event. Alternatively, if you'd prefer to use a webhook to receive the payload, please get in touch with us at support@janis.ai and we can enable that for you.

```ruby
# Handle forwarding the messages sent by a human through your bot
janis.on :'chat response' do |data|
    text = data['text']
    channel = data['channel']
    client.say({'text': text, 'channel': channel})  # <= example of bot sending message
end
```

Go back to Slack and wait for alerts. That's it! 
[Be sure to check out our examples.](./examples/)


### Looking for something we don't yet support?  
* [Join our mailing list and we'll notifiy you](https://www.janis.ai)
* [Contact Support](mailto:support@janis.ai)
