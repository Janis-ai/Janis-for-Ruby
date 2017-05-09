require 'dotenv'
Dotenv.load
require 'slack-ruby-bot'
require 'janis'
require 'json'

# janis Api Key
janis.apikey = ENV['JANIS_API_KEY']
# Unique janis Client Key for your bot
janis.clientkey = ENV['JANIS_CLIENT_KEY']
# possible values: "messenger" or "slack"
janis.platform = "slack"

class Bot < SlackRubyBot::Bot
    
    
    # Handle forwarding the messages sent by a human through your bot
    janis.on :'chat response' do |data|
        client = self.instance.hooks.client
        text = data['text']
        channel = data['channel']
        client.say({'text': text, 'channel': channel})
    end

    janis.on :'channel update' do |data|
    end

    command 'hi' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = janis.hopIn(body)
        # If your bot is paused, stop it from replying
        if hopInResponse['paused'] != true
            text = 'Hello there.'
            outgoingMessage = {channel: data.channel, text: text}
            janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
        end
    end

    command 'help' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = janis.hopIn(body)
        # let the user know that they are being routed to a human
        if hopInResponse['paused'] != true
            text = 'Hang tight. Let me see what I can do.'
            outgoingMessage = {channel: data.channel, text: text}
            janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # send a janis alert to your slack channel
            # that the user could use assistance
            janis.assistanceRequested(body);
        end
    end

    match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/) do |client, data, match|
        body = JSON.parse(data.to_json)
        hopInResponse = janis.hopIn(body)
        if hopInResponse['paused'] != true
            # let the user know that the bot does not understand
            text = 'Huh?'
            outgoingMessage = {channel: data.channel, text: text}
            janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # capture conversational dead-ends.
            janis.logUnknownIntent(body);
        end
    end

end

SlackRubyBot::Client.logger.level = Logger::WARN

Bot.run
