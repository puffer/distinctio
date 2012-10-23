require 'spec_helper.rb'

describe Distinctio::Differs::Base do
      context "one entry as text, whole hash as a hash" do
        let(:a) { { :id => 1, :name => 'Nancy', :message => 'hello, world!'} }
        let(:b) { { :id => 1, :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
        let(:delta) { [
          {:id=>1, :name=>"Nancy", :message=>"hello, world!"},
          {:id=>1, :name=>"Nancy", :message=>"The world is mine!", :extra=>"Extra."}
        ] }
        let(:opts) { { :message => :text } }

        specify { subject.calc(a, b, :simple, opts).should == delta }
        specify { subject.apply(a, delta, :simple, opts).should == b }
      end

      context "entries have no id, whole hash as an object" do
        let(:a) { { :name => 'Nancy', :message => 'hello, world!'} }
        let(:b) { { :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
        let(:delta) { [
          { :name=>"Nancy", :message=>"hello, world!"},
          { :name=>"Nancy", :message=>"The world is mine!", :extra=>"Extra."}
        ] }
        let(:opts) { { :message => :text } }

        specify { subject.calc(a, b, :simple, opts).should == delta }
        specify { subject.apply(a, delta, :simple, opts).should == b }
      end
end