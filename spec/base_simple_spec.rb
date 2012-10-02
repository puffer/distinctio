require 'spec_helper.rb'

describe "simple diff" do
  describe "simple method" do
    subject { Distinctio::Base.new }

    shared_examples_for "calc and apply difference" do
      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
    end

    context "a and b are hashes" do
      context do
        let(:a) { { :name => 'txt' } }
        let(:b) { { :name => 'txt' } }
        let(:delta) { {} }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { :name => 'txt' } }
        let(:b) { { } }
        let(:delta) { { :name => ['txt', nil] } }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { } }
        let(:b) { { } }
        let(:delta) { { } }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { :name => 'txt' } }
        let(:b) { { :name => 'pdf' } }
        let(:delta) { { :name => ['txt', 'pdf'] } }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { :key => 0 } }
        let(:b) { { :key => 1 } }
        let(:delta) { { :key => [0, 1] } }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { :key => [1, 2] } }
        let(:b) { { :key => [2, 3] } }
        let(:delta) { { :key => [[1, 2], [2, 3]] } }
        it_should_correctly "calc and apply difference"
      end

      context do
        let(:a) { { :name => 'txt', :body => 'hello!', :count => 5, :stats => [3, 7], :data => 'data' } }
        let(:b) { { :name => 'txt', :body => 'goodbye!', :count => 7, :stats => [6, 7], :code => 'code' } }
        let(:delta) { {
          :body =>  ['hello!', 'goodbye!'],
          :count => [5, 7],
          :stats => [[3, 7], [6, 7]],
          :data =>  ['data', nil],
          :code =>  [nil, 'code']
        } }
        it_should_correctly "calc and apply difference"
      end
    end

    context "a and b are arrays of hashes with id" do
      context "as a symbol" do
        let(:a) { [ {:id => 1, :name => 'world'}, {:id => 2, :name => 'hello'} ] }
        let(:b) { [ {:id => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
        let(:delta) { [
          { :id => 1, :name => ['world', 'hello'] },
          { :id => 2, :name => ['hello', 'world'] },
          { :id => 3, :name => [nil, 'goodbye'] }
        ] }

        specify { subject.calc(a, b).should == delta }

        specify { subject.apply(a, delta).should include({:id => 2, :name => 'world'}) }
        specify { subject.apply(a, delta).should include({:id => 1, :name => 'hello'}) }
        specify { subject.apply(a, delta).should include({:id => 3, :name => 'goodbye'}) }

        specify { subject.apply(b, delta).should include({:id => 1, :name => 'world'}) }
        specify { subject.apply(b, delta).should include({:id => 2, :name => 'hello'}) }
        specify { subject.apply(b, delta).should_not include({:id => 3, :name => 'goodbye'}) }
      end

      context "as a string" do
        let(:a) { [ {"id" => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
        let(:b) { [ {"id" => 2, :name => 'world'}, {"id" => 1, :name => 'hello'}, {"id" => 3, :name => 'goodbye'}] }
        let(:delta) { [
          { "id" => 1, :name => ['world', 'hello'] },
          { "id" => 2, :name => ['hello', 'world'] },
          { "id" => 3, :name => [nil, 'goodbye'] }
        ] }

        specify { subject.calc(a, b).should == delta }

        specify { subject.apply(a, delta).should include({"id" => 2, :name => 'world'}) }
        specify { subject.apply(a, delta).should include({"id" => 1, :name => 'hello'}) }
        specify { subject.apply(a, delta).should include({"id" => 3, :name => 'goodbye'}) }

        specify { subject.apply(b, delta).should include({"id" => 1, :name => 'world'}) }
        specify { subject.apply(b, delta).should include({"id" => 2, :name => 'hello'}) }
        specify { subject.apply(b, delta).should_not include({"id" => 3, :name => 'goodbye'}) }
      end

      context "as a string and a symbol" do
        let(:a) { [ {:id => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
        let(:b) { [ {"id" => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
        let(:delta) { [
          { :id => 1, :name => ['world', 'hello'] },
          { :id => 2, :name => ['hello', 'world'] },
          { :id => 3, :name => [nil, 'goodbye'] }
        ] }

        specify { subject.calc(a, b).should == delta }

        specify { subject.apply(a, delta).should include({:id => 2, :name => 'world'}) }
        specify { subject.apply(a, delta).should include({:id => 1, :name => 'hello'}) }
        specify { subject.apply(a, delta).should include({:id => 3, :name => 'goodbye'}) }

        specify { subject.apply(b, delta).should include({"id" => 1, :name => 'world'}) }
        specify { subject.apply(b, delta).should include({"id" => 2, :name => 'hello'}) }
        specify { subject.apply(b, delta).should_not include({"id" => 3, :name => 'goodbye'}) }
      end
    end

    context "a and b are objects" do
      context "a and b are ints" do
        let(:a) { 1 }
        let(:b) { 2 }
        let(:delta) { [1, 2] }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are strings" do
        let(:a) { 'q' }
        let(:b) { 'w' }
        let(:delta) { ['q', 'w'] }
        it_should_correctly "calc and apply difference"
      end

      context "one object is nil" do
        let(:a) { 1 }
        let(:b) { nil }
        let(:delta) { [1, nil] }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are nil" do
        let(:a) { nil }
        let(:b) { nil }
        let(:delta) { {} }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are equal objects" do
        let(:a) { 1 }
        let(:b) { 1 }
        let(:delta) { {} }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are arrays" do
        let(:a) { [{ :a => 'hello' },  { :a => 'pdf' }] }
        let(:b) { [{ :a => 'goodbye' }, { :b => 'png' }] }
        let(:delta) { [[{ :a => 'hello' },  { :a => 'pdf' }], [{ :a => 'goodbye' }, { :b => 'png' }]] }
        it_should_correctly "calc and apply difference"
      end
    end
  end
end