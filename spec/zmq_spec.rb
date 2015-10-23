require 'spec_helper'
require 'deployable/zmq'

describe Deployable::Zmq do
  it "should have a VERSION constant" do
    expect( Module.const_get('VERSION') ).to_not be_empty
  end
end
