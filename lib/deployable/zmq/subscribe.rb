require 'deployable/zmq/version'
require 'deployable/zmq/defaults'
require 'deployable/patch/instance_class_variables'

require 'ffi-rzmq'
require 'json'


module Deployable; module Zmq

# Deployable::Zmq provides a generic set of helpers do you
# don't have to do so much leg work. 

class Subscribe

  @port    = DEFAULT_BIND_PORT
  @address = DEFAULT_CONNECT_ADDRESS
  
  def initialize options = {}
    @context    = ZMQ::Context.new
    @subscriber = @context.socket ZMQ::SUB

    @port       = options.fetch :port, __class_ivg('port')
    @port       = DEFAULT_BIND_PORT if @port.nil?

    @address    = options.fetch :options, __class_ivg('address')
    raise "No valid address [#{@address}]" if @address.nil? or @address == '*'

    url = "tcp://#{@address}:#{@port}"

    raise "Failed to connect to [#{url}] [#{rc}]" unless
      rc = @subscriber.connect( url ) == 0 

    #log.debug "zmq subscribing to [#{url}]"

    @subscribe = options.fetch( :subscribe, nil )
    
    raise "Failed to subscribe to [#{url}] [#{rc}]" unless
      @subscribe.nil? or 
      rc = @subscriber.setsockopt( ZMQ::SUBSCRIBE, 'REQ_COMP' ) == 0 

  end

  # Recieve a message off the queue
  def receive
    @subscriber.recv_strings( parts = [] )
    #log.debug "a queue item [%s]\n", parts.join(' ')
    parts
  end

  # Watch a queue for messages
  def go callback
    loop do
      callback.call receive
    end
  end

  # End a subscription
  def end
    @subscriber.close
  end
  
end


end;end