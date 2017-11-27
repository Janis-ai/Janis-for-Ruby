require 'rubygems'
require 'socket.io-client-simple'
require 'httparty'

module Janis

    
    class Janiapi
        include HTTParty
        base_uri 'https://janis.ai/api/v1'
    end

    class FBApi
        include HTTParty
        base_uri 'https://graph.facebook.com/v2.6/me'
    end
    
    EVENTS = [:'chat response', :'socket_id_set', :'channel update'].freeze
    
    class << self
    
        attr_accessor :apikey, :clientkey, :token, :platform, :options

        def initialize
            @apikey
            @clientkey
            @token
            @platform
            @options
        end
        
        def new(*args, &block)
            obj = allocate
            obj.initialize(*args, &block)
            obj
        end
    
        # Return a Hash of hooks.
        def apikey
            @apikey ||= ENV['JANIS_API_KEY']
        end
        
        def clientkey
            @clientkey ||= ENV['JANIS_CLIENT_KEY']
        end
        
        def token
            @token ||= ENV['ACCESS_TOKEN'] ||= ''
        end
        
        def platform
            @platform ||= "messenger"
        end

        def janisappid
            @janisappid = 1242623579085955
        end
        
        def headers
            @headers = {'apikey':apikey,'clientkey':clientkey,'platform':platform, 'token': token}
        end
        
        def hooks
            @hooks ||= {}
        end
    
        socket = SocketIO::Client::Simple.connect 'https://wordhop-socket-server.herokuapp.com'
        
        socket.on :socket_id_set do |data|
            socket_id = data
            x = {'socket_id': socket_id, 'clientkey': JANIS_CLIENT_KEY}
            data = {
                body: x,
                headers: headers
            }
            Janiapi.post('/update_bot_socket_id', data)
        end

        socket.on :'chat response' do |data|
            channel = data['channel']
            text = data['text']
            messageData = {'recipient': {'id': channel},'message': {'text': text}}
            janis.hopOut(messageData)
            janis.trigger(:'chat response', messageData)
        end

        socket.on :'channel update' do |data|
            janis.trigger(:'channel update', data)
        end

        def on(event, &block)
            unless EVENTS.include? event
                raise ArgumentError,
                "#{event} is not a valid event; " \
                "available events are #{EVENTS.join(',')}"
            end
            hooks[event] = block
        end

        def trigger(event, *args)
            hooks.fetch(event).call(*args)
        rescue KeyError
            $stderr.puts "Ignoring #{event} (no hook registered)"
        end

        def hopIn(x)
            data = {'body':x, 'headers':headers}
            return Janiapi.post('/in', data)
        end
            
        def hopOut(x)
            data = {'body':x, 'headers':headers}
            return Janiapi.post('/out', data)
        end
            
        def logUnknownIntent(x)
            data = {'body':x, 'headers':headers}
            return Janiapi.post('/unknown', data)
        end
            
        def assistanceRequested(x)
            data = {'body':x, 'headers':headers}
            return Janiapi.post('/human', data)
        end

        def passThreadControl(x)
            message = x['message']
            recipientid = x['recipient']['id']
            appid = message['app_id']
            is_echo = message['is_echo']
            if message['is_echo'] && (appid == janisappid || appid.nil?)
                
                # If an agent responds via the Messenger Inbox, then `appId` will be null.
                # If an agent responds from Janis on Slack, the `appId` will be 1242623579085955.
                # In both cases, we should pause your bot by giving the thread control to Janis.
                # Janis will pass control back to your app again after 10 minutes of inactivity.
                # If you want to manually pass back control, use the slash command `/resume`
                # in the Janis transcript channel, or press "Done" in the Page Inbox on the thread.
                
                # See: https://developers.facebook.com/docs/messenger-platform/handover-protocol#app_roles
                # This app should be the Primary Receiver. Janis should be a Secondary Receiver.
                # Every time an echo from either Janis or the Page Inbox is received,
                # this app passes control over to Janis so the humans are the only ones who can respond.
                j = {"recipient": {"id": recipientid}, "target_app_id": janisappid, "metadata": "passing thread"}
                uri = "/pass_thread_control?access_token=" + token
                return FBApi.post(uri, {'body':j})
            end
            return false
        end
    end
end
