require 'spec_helper.rb'

describe Distinctio::Nothing do

  describe "equality rules" do
    let(:a) { Distinctio::Nothing.new }
    let(:b) { Distinctio::Nothing.new }

    specify { (a == b).should be_true }
    specify { (b == a).should be_true }
    specify { (a === b).should be_true }
    specify { (b === a).should be_true }
    specify { (a.eql? b).should be_true }
    specify { (b.eql? a).should be_true }
  end

  describe "can be serialized in a hash key" do
    before  { History.create :model_type => 'None', :model_id => 1, :delta => { :k => Distinctio::Nothing.new } }
    specify { History.last.delta[:k].should be_a(Distinctio::Nothing) }
  end

end