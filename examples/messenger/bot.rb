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


Bot.on :message do |message|
  puts "Received '#{message.inspect}' from #{message.sender}"

  case message.text
  when /hello/i
    message.reply(
      text: 'Hello, human!',
      quick_replies: [
        {
          content_type: 'text',
          title: 'Hello, bot!',
          payload: 'HELLO_BOT'
        }
      ]
    )
  when /help/i
    # let the user know that they are being routed to a human
    message.reply(text: 'Hang tight. Let me see what I can do.')
    # send a Janis alert to your slack channel
    # that the user could use assistance
    Janis.assistanceRequested(message.messaging)
  when /something humans like/i
    message.reply(
      text: 'I found something humans seem to like:'
    )

    message.reply(
      attachment: {
        type: 'image',
        payload: {
          url: 'https://i.imgur.com/iMKrDQc.gif'
        }
      }
    )

    message.reply(
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: 'Did human like it?',
          buttons: [
            { type: 'postback', title: 'Yes', payload: 'HUMAN_LIKED' },
            { type: 'postback', title: 'No', payload: 'HUMAN_DISLIKED' }
          ]
        }
      }
    )
  else
    # let the user know that the bot does not understand
    
    message.reply(
      text: 'You are now marked for extermination.'
    )

    message.reply(
      text: 'Have a nice day.'
    )
    # capture conversational dead-ends.
    Janis.logUnknownIntent(message.messaging)
  end
end

Bot.on :read do |message_read|
  puts "Read '#{message_read.inspect}' from #{message_read.sender}"

end

Bot.on :message_echo do |message_echo|
  # See: https://developers.facebook.com/docs/messenger-platform/handover-protocol#app_roles
  # This app should be the Primary Receiver. Janis should be a Secondary Receiver.
  # Every time an echo from either Janis or the Page Inbox is received,
  # this app passes control over to Janis so the humans are the only ones who can respond.
  # Janis will pass control back to this app again after 10 minutes of inactivity.
  # If you want to manually pass back control, use the slash command `/resume`
  # in the Janis transcript channel, or press "Done" in the Page Inbox on the thread.
  Janis.passThreadControl(message_echo.messaging)
end

Bot.on :postback do |postback|
  case postback.payload
  when 'HUMAN_LIKED'
    text = 'That makes bot happy!'
  when 'HUMAN_DISLIKED'
    text = 'Oh.'
  end

  postback.reply(
    text: text
  )
end

Bot.on :delivery do |delivery|
  puts "Delivered message(s) #{delivery.ids}"
end

