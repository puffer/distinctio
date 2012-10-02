require 'spec_helper.rb'

describe "simple diff" do
  describe "text method" do
    subject { Diff::Differ.new method: :text }

    context "a and b are hashes" do
      let(:a) { { :name => 'Nancy', :message => 'hello, world!'} }
      let(:b) { { :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
      let(:delta) { {
        :message => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
        :extra => [nil, "Extra."]
      } }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
    end

    context "a and b are strings" do
      let(:a) { 'hello, world!' }
      let(:b) { 'The world is mine!' }
      let(:delta) { "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n" }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
    end
  end
end