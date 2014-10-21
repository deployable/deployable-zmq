require 'ffi-rzmq'
require 'json'

require 'deployable/patch/instance_class_variables'

module Deployable; module Zmq

DEFAULT_BIND_PORT    = 5563
DEFAULT_BIND_ADDRESS = '*'

class RequestPublish

  @port    = DEFAULT_BIND_PORT
  @address = DEFAULT_BIND_ADDRESS

  def initialize
    @context   = ZMQ::Context.new
    @publisher = @context.socket ZMQ::PUB
    @port      = __class_ivg 'port'
    @address   = __class_ivg 'address'
    @publisher.bind "tcp://#{address}:#{port}"
  end

  def send request, icap_code, response_code
    @publisher.send_string 'REQ_COMP', ZMQ::SNDMORE
    @publisher.send_string request, ZMQ::SNDMORE
    @publisher.send_string icap_code, ZMQ::SNDMORE
    @publisher.send_string response_code
  end

  def send_arr array
    @publisher.send_string 'REQ_COMP', ZMQ::SNDMORE
    limit = array.length - 1
    i=0; while i < limit do
      @publisher.send_string array[i], ZMQ::SNDMORE
      i+=1
    end
    @publisher.send_string array[i]
  end

  def send_json obj
    # parse before send in case of issues
    message = obj.to_json
    @publisher.send_string 'REQ_COMP', ZMQ::SNDMORE
    @publisher.send_string message
  end

  def end
    @publisher.close
  end
  
end



class RequestSubscribe

  @port    = BIND_PORT
  @address = BIND_ADDRESS
  
  def initialize address = nil
    @context    = ZMQ::Context.new
    @subscriber = @context.socket ZMQ::SUB
    @port       = __class_ivg 'port'
    @address    = address
    @address    = __class_ivg 'address' if @address.nil?
    @subscriber.connect "tcp://#{@address}:#{port}"
    @subscriber.setsockopt ZMQ::SUBSCRIBE, 'REQ_COMP'
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