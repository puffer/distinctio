require 'spec_helper.rb'

describe "simple diff" do
  subject { Distinctio::Differs::Base }

  context "a and b are hashes" do

    context do
      let(:a) { { 'id' => 1, 'name' => 'txt' } }
      let(:b) { { 'id' => 1, 'name' => 'pdf' } }
      let(:delta) { { 'name' => ['txt', 'pdf'] } }

      specify { subject.calc(a, b, :object).should == delta }
      specify { subject.apply(a, delta, :object).should == b }
      specify { subject.apply(b, delta, :object).should == a }
    end

    context "bad delta" do
      context "delta from another object" do
        let(:a) { { 'id' => 1, 'name' => 'txt' } }
        let(:b) { { 'id' => 1, 'name' => 'pdf' } }
        let(:bad_delta) { { 'name' => ['doc', 'pdf'] } }

        specify { subject.apply(a, bad_delta, :object)[:name].should be_a(Distinctio::Differs::Simple::Error) }
      end

      context "delta is not a hash" do
        let(:a) { { 'id' => 1, 'name' => 'txt' } }

        specify do
          expect {
            subject.apply({ 'id' => 1, 'name' => 'txt' }, 'str', :object)
          }.to raise_error(ArgumentError)
        end

        specify do
          expect {
            subject.apply([{ 'id' => 1, 'name' => 'txt' }], 'str', :object)
          }.to raise_error(ArgumentError)
        end
      end

      context "bad argument" do
        let(:delta) { { 'name' => ['txt', 'pdf'] } }

        specify do
          expect { subject.apply('str', delta, :object) }.to raise_error(ArgumentError)
        end

        specify do
          expect { subject.apply('str', delta, :object) }.to raise_error(ArgumentError)
        end
      end
    end

    context do
      let(:a) { { 'id' => 1, 'key' => 0 } }
      let(:b) { { 'id' => 1, 'key' => 1 } }
      let(:delta) { { 'key' => [0, 1] } }

      specify { subject.calc(a, b, :object).should == delta }
      specify { subject.apply(a, delta, :object).should == b }
      specify { subject.apply(b, delta, :object).should == a }
    end

    context do
      let(:a) { { 'id' => 1, 'key' => [1, 2] } }
      let(:b) { { 'id' => 1, 'key' => [2, 3] } }
      let(:delta) { { 'key' => [[1, 2], [2, 3]] } }

      specify { subject.calc(a, b, :object).should == delta }
      specify { subject.apply(a, delta, :object).should == b }
      specify { subject.apply(b, delta, :object).should == a }
    end

    context do
      let(:a) { { :id => 1, :name => 'txt', :body => 'hello!', :count => 5, :stats => [3, 7], :data => 'data' } }
      let(:b) { { :id => 1, :name => 'txt', :body => 'goodbye!', :count => 7, :stats => [6, 7], :code => 'code' } }
      let(:delta) { {
        'body' =>  ['hello!', 'goodbye!'],
        'count' => [5, 7],
        'stats' => [[3, 7], [6, 7]],
        'data' =>  ['data', nil],
        'code' =>  [nil, 'code']
      } }

      specify { subject.calc(a, b, :object).should == delta }
      specify { subject.apply(a, delta, :object).except(:data).should == b.with_indifferent_access }
      specify { subject.apply(b, delta, :object).except(:code).should == a.with_indifferent_access }
    end
  end

  context "a and b are arrays of hashes with id" do
    context "as a symbol" do
      let(:a) { [ {:id => 1, :name => 'world'}, {:id => 2, :name => 'hello'} ] }
      let(:b) { [ {:id => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, 'name' => ['world', 'hello'] },
        { :id => 2, 'name' => ['hello', 'world'] },
        { :id => 3, 'name' => [nil, 'goodbye'] }
      ] }
      let(:opts) { :object }

      specify { subject.calc(a, b, opts).should == delta }

      specify { subject.apply(a, delta, opts).should include({'id' => 2, 'name' => 'world'}) }
      specify { subject.apply(a, delta, opts).should include({'id' => 1, 'name' => 'hello'}) }
      specify { subject.apply(a, delta, opts).should include({'id' => 3, 'name' => 'goodbye'}) }

      specify { subject.apply(b, delta, opts).should include({'id' => 1, 'name' => 'world'}) }
      specify { subject.apply(b, delta, opts).should include({'id' => 2, 'name' => 'hello'}) }
      specify { subject.apply(b, delta, opts).should_not include({'id' => 3, 'name' => 'goodbye'}) }
    end

    context "as a string" do
      let(:a) { [ {"id" => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
      let(:b) { [ {"id" => 2, :name => 'world'}, {"id" => 1, :name => 'hello'}, {"id" => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, "name" => ['world', 'hello'] },
        { :id => 2, "name" => ['hello', 'world'] },
        { :id => 3, "name" => [nil, 'goodbye'] }
      ] }

      specify { subject.calc(a, b, :object).should == delta }

      specify { subject.apply(a, delta, :object).should include({"id" => 2, "name" => 'world'}) }
      specify { subject.apply(a, delta, :object).should include({"id" => 1, "name" => 'hello'}) }
      specify { subject.apply(a, delta, :object).should include({"id" => 3, "name" => 'goodbye'}) }

      specify { subject.apply(b, delta, :object).should include({"id" => 1, "name" => 'world'}) }
      specify { subject.apply(b, delta, :object).should include({"id" => 2, "name" => 'hello'}) }
      specify { subject.apply(b, delta, :object).should_not include({"id" => 3, :name => 'goodbye'}) }
    end

    context "as a string and a symbol" do
      let(:a) { [ {:id => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
      let(:b) { [ {"id" => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, 'name' => ['world', 'hello'] },
        { :id => 2, 'name' => ['hello', 'world'] },
        { :id => 3, 'name' => [nil, 'goodbye'] }
      ] }

      specify { subject.calc(a, b, :object).should == delta }

      specify { subject.apply(a, delta, :object).should include({"id" => 2, 'name' => 'world'}) }
      specify { subject.apply(a, delta, :object).should include({"id" => 1, 'name' => 'hello'}) }
      specify { subject.apply(a, delta, :object).should include({"id" => 3, 'name' => 'goodbye'}) }

      specify { subject.apply(b, delta, :object).should include({"id" => 1, 'name' => 'world'}) }
      specify { subject.apply(b, delta, :object).should include({"id" => 2, 'name' => 'hello'}) }
      specify { subject.apply(b, delta, :object).should_not include({"id" => 3, 'name' => 'goodbye'}) }
    end
  end
end