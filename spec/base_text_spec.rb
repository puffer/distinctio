require 'spec_helper.rb'

describe "simple diff" do
  describe "text method" do
    subject { Distinctio::Base.new method: :text }

    context "a and b are hashes" do
      let(:a) { { :name => 'Nancy', :message => 'hello, world!'} }
      let(:b) { { :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
      let(:delta) { {
        :message => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
        :extra => [nil, "Extra."]
      } }

      specify { subject.calc(a, b, { :message => :text }).should == delta }
      specify { subject.apply(a, delta).should == b }
    end

    context "a and b are strings" do
      let(:a) { 'hello, world!' }
      let(:b) { 'The world is mine!' }
      let(:delta) { "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n" }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
    end

    context do
      let(:a) { {
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem ipsum" },
            { :id => 2, :body => "Sit amet" }
          ]
      } }
      let(:b) { {
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem ipsum dolor" },
            { :id => 2, :body => "Sit amet consectetur" }
          ]
      } }

      let(:delta) { {
        :page_parts => [
          { :body=>"@@ -4,8 +4,14 @@\n em ipsum\n+ dolor\n", :id=>1 },
          { :body=>"@@ -1,8 +1,20 @@\n Sit amet\n+ consectetur\n", :id=>2 }
        ]
      } }
      subject { Distinctio::Base.new }

      specify { subject.calc(a, b, { :page_parts => :object, 'page_parts.body' => :text }).should == delta }

    end
  end
end