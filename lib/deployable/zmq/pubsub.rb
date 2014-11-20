require 'ffi-rzmq'
require 'json'

require 'deployable/patch/instance_class_variables'

module Deployable; module Zmq

DEFAULT_BIND_PORT    = 5563
DEFAULT_BIND_ADDRESS = '*'


class Publish

  @port    = DEFAULT_BIND_PORT
  @address = DEFAULT_BIND_ADDRESS

  def initialize options = {}
    @context   = ZMQ::Context.new
    @publisher = @context.socket ZMQ::PUB

    @port      = options.fetch :port, __class_ivg( 'port' )
    @port      = DEFAULT_BIND_PORT if @port.nil?

    @address   = options.fetch :address, __class_ivg( 'address' )
    @address   = DEFAULT_BIND_ADDRESS if @address.nil?

    uri = "tcp://#{@address}:#{@port}"
    unless rc = @publisher.bind( uri ) == 0
      raise "zmq bind failed [#{rc}] [#{uri}]"; end
    puts "zmq pusblish on [#{uri}]"
  end

  def send_string label, message
    @publisher.send_string label, ZMQ::SNDMORE
    @publisher.send_string message
  end

  def send_arr label, array
    @publisher.send_string label, ZMQ::SNDMORE
    limit = array.length - 1
    i=0; while i < limit do
      @publisher.send_string array[i], ZMQ::SNDMORE
      i+=1
    end
    @publisher.send_string array[i]
  end

  def send_json label, obj
    # parse before send in case of issues
    message = obj.to_json
    @publisher.send_string label, ZMQ::SNDMORE
    @publisher.send_string message
  end

  def end
    @publisher.close
  end
  
end



class Subscribe

  @port    = DEFAULT_BIND_PORT
  @address = 'localhost'
  
  def initialize options = {}
    @context    = ZMQ::Context.new
    @subscriber = @context.socket ZMQ::SUB

    @port       = options.fetch :port, __class_ivg('port')
    @port       = DEFAULT_BIND_PORT if @port.nil?

    @address    = options.fetch :options, __class_ivg('address')
    raise "No valid address [#{@address}]" if @address.nil? or @address == '*'

    url = "tcp://#{@address}:#{@port}"

    unless rc = @subscriber.connect( url ) == 0 
      raise "Failed to connect to [#{url}] [#{rc}]"; end

    if options.fetch( :subscribe, nil ) != nil
      unless rc = @subscriber.setsockopt( ZMQ::SUBSCRIBE, 'REQ_COMP' ) == 0 
        raise "Failed to subscribe to [#{url}] [#{rc}]"; end
    end
  end

  def receive
    @subscriber.recv_strings( parts = [] )
    printf "an queue item [%s]\n", parts.join(' ')
    parts
  end

  def go callback
    loop do
      callback.call receive
    end
  end

  def end
    @subscriber.close
  end
  
end


end; end