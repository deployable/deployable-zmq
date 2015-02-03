require 'spec_helper'
require 'deployable/zmq/publish'

describe Deployable::Zmq::Publish do


  it "should have a VERSION constant" do
    expect( Module.const_get('VERSION') ).to_not be_empty
  end


  describe "binds" do

    it "binds a new connection" do
      @connection = Deployable::Zmq::Publish.new
    end 

    it "binds a new connection on a port" do
      @connection = Deployable::Zmq::Publish.new( port: 5123 )
    end

    it "binds a new connection to an address" do
      @connection = Deployable::Zmq::Publish.new( address: '127.0.0.1' )
    end

    it "binds a new connection to an address and port" do
      @connection = Deployable::Zmq::Publish.new( port: 5123, address: '127.0.0.1' )
    end

    after :each do
      @connection.end if @connection
    end

  end


  describe "sends" do
    
    before :each do
      @connection = Deployable::Zmq::Publish.new
    end

    after :each do
      @connection.end if @connection
    end

    it "sends a string" do
      @connection.send_string "label", 'something'
    end

    it "sends array of string" do
      @connection.send_arr "label", ['1','2','3']
    end

    it "sends arrays of non strings" do
      @connection.send_arr "label", [1,2,3]
    end

    it "sends json" do
      @connection.send_json "label", { sometthing: 2 }
    end

  end
  

end
