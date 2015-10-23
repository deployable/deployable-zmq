require 'deployable/zmq/version'
require 'deployable/zmq/defaults'
require 'deployable/patch/instance_class_variables'

require 'ffi-rzmq'
require 'json'


module Deployable; module Zmq

# Deployable::Zmq provides a generic set of helpers do you
# don't have to do so much leg work. 

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
      raise "zmq bind failed [#{rc}] [#{uri}]" 
    end

    #log.debug "zmq publishing on [#{uri}]"
  end

  # String a simple string
  def send_string label, message
    @publisher.send_string label, ZMQ::SNDMORE
    @publisher.send_string message
  end

  # Send an array of messages
  def send_arr label, array
    @publisher.send_string label, ZMQ::SNDMORE

    # Everything but the last element
    array[0..-2].each do |e|
      @publisher.send_string e.to_s, ZMQ::SNDMORE
    end
    @publisher.send_string array.last.to_s
  end

  # Send an object in json
  def send_json label, obj
    # parse before send in case of issues
    message = obj.to_json
    @publisher.send_string label, ZMQ::SNDMORE
    @publisher.send_string message
  end

  # End the connection
  def end
    @publisher.close
  end
  
end


end;end;