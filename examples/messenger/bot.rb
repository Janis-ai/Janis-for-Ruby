require 'dotenv'
Dotenv.load

require 'facebook/messenger'
require 'rubygems'
require 'janis-ai'

include Facebook::Messenger


Janis.token = ENV['ACCESS_TOKEN']
Janis.clientkey = ENV['JANIS_CLIENT_KEY']
Janis.apikey = ENV['JANIS_API_KEY']
Janis.platform = "messenger"

Janis.on :'chat response' do |data|
    channel = data['channel']
    text = data['text']
    payload = {'recipient': {'id': channel},'message': {'text': text}}
    Bot.deliver(payload, access_token: ENV['ACCESS_TOKEN'])
end

Janis.on :'channel update' do |data|
end

def sendIt(message, data)
    payload = {
        recipient: message.sender,
        message: data   
    }
    message.reply(data)
    Janis.hopOut(payload)
end

Bot.on :message do |message|
  puts "Received '#{message.inspect}' from #{message.sender}"
  
  hopInResponse = Janis.hopIn(message.messaging)
  # If your bot is paused, stop it from replying
  if hopInResponse['paused'] != true
      case message.text
      when /hello/i
        sendIt(message, text: 'Hello there.')
      when /help/i
        # let the user know that they are being routed to a human
        sendIt(message, text: 'Hang tight. Let me see what I can do.')
        # send a Janis alert to your slack channel
        # that the user could use assistance
        Janis.assistanceRequested(message.messaging)
      else
        # let the user know that the bot does not understand
        sendIt(message, text: 'Huh?')
        # capture conversational dead-ends.
        Janis.logUnknownIntent(message.messaging)
      end
    end
end
