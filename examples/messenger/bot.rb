require 'dotenv'
Dotenv.load

require 'facebook/messenger'
require 'rubygems'
require 'janis'

include Facebook::Messenger


janis.token = ENV['ACCESS_TOKEN']
janis.clientkey = ENV['JANIS_CLIENT_KEY']
janis.apikey = ENV['JANIS_API_KEY']
janis.platform = "messenger"

janis.on :'chat response' do |data|
    channel = data['channel']
    text = data['text']
    payload = {'recipient': {'id': channel},'message': {'text': text}}
    Bot.deliver(payload, access_token: ENV['ACCESS_TOKEN'])
end

janis.on :'channel update' do |data|
end

def sendIt(message, data)
    payload = {
        recipient: message.sender,
        message: data   
    }
    message.reply(data)
    janis.hopOut(payload)
end

Bot.on :message do |message|
  puts "Received '#{message.inspect}' from #{message.sender}"
  
  hopInResponse = janis.hopIn(message.messaging)
  # If your bot is paused, stop it from replying
  if hopInResponse['paused'] != true
      case message.text
      when /hello/i
        sendIt(message, text: 'Hello there.')
      when /help/i
        # let the user know that they are being routed to a human
        sendIt(message, text: 'Hang tight. Let me see what I can do.')
        # send a janis alert to your slack channel
        # that the user could use assistance
        janis.assistanceRequested(message.messaging)
      else
        # let the user know that the bot does not understand
        sendIt(message, text: 'Huh?')
        # capture conversational dead-ends.
        janis.logUnknownIntent(message.messaging)
      end
    end
end
