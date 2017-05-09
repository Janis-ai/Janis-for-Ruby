require 'dotenv'
Dotenv.load
require 'slack-ruby-bot'
require 'janis-ai'
require 'json'

# janis Api Key
Janis.apikey = ENV['JANIS_API_KEY']
# Unique janis Client Key for your bot
Janis.clientkey = ENV['JANIS_CLIENT_KEY']
# possible values: "messenger" or "slack"
Janis.platform = "slack"

class Bot < SlackRubyBot::Bot
    
    
    # Handle forwarding the messages sent by a human through your bot
    Janis.on :'chat response' do |data|
        client = self.instance.hooks.client
        text = data['text']
        channel = data['channel']
        client.say({'text': text, 'channel': channel})
    end

    Janis.on :'channel update' do |data|
    end

    command 'hi' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = Janis.hopIn(body)
        # If your bot is paused, stop it from replying
        if hopInResponse['paused'] != true
            text = 'Hello there.'
            outgoingMessage = {channel: data.channel, text: text}
            Janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
        end
    end

    command 'help' do |client, data, _match|
        body = JSON.parse(data.to_json)
        hopInResponse = Janis.hopIn(body)
        # let the user know that they are being routed to a human
        if hopInResponse['paused'] != true
            text = 'Hang tight. Let me see what I can do.'
            outgoingMessage = {channel: data.channel, text: text}
            Janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # send a Janis alert to your slack channel
            # that the user could use assistance
            Janis.assistanceRequested(body);
        end
    end

    match(/^(?<bot>\S*)[\s]*(?<expression>.*)$/) do |client, data, match|
        body = JSON.parse(data.to_json)
        hopInResponse = Janis.hopIn(body)
        if hopInResponse['paused'] != true
            # let the user know that the bot does not understand
            text = 'Huh?'
            outgoingMessage = {channel: data.channel, text: text}
            Janis.hopOut(outgoingMessage)
            client.say(text: text, channel: data.channel)
            # capture conversational dead-ends.
            Janis.logUnknownIntent(body);
        end
    end

end

SlackRubyBot::Client.logger.level = Logger::WARN

Bot.run
