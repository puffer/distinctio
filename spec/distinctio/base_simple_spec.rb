require 'spec_helper.rb'

describe "simple diff" do
  describe "simple method" do
    subject { Distinctio::Differs::Base }

    shared_examples_for "calc and apply difference" do
      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
    end

    context "a and b are hashes" do
      context do
        let(:a) { { :name => 'txt' } }
        let(:b) { { :name => 'txt' } }
        let(:delta) { nil }

        specify { subject.calc(a, b).should == delta }
        specify { subject.apply(a, delta).should == b }
        specify { subject.apply(b, delta).should == a }
      end

      context "raises an exception on mailformed a or b" do
        specify do
          expect { Distinctio::Differs::Base.calc(3, 2, :text) }.to raise_error(ArgumentError)
        end

      end

      context "raises an exception on mailformed delta" do
        specify do
          expect { Distinctio::Differs::Base.apply(3, 2) }.to raise_error(ArgumentError)
        end

        specify do
          expect { Distinctio::Differs::Base.apply(3, [3]) }.to raise_error(ArgumentError)
        end

        specify do
          expect { Distinctio::Differs::Base.apply(3, [1, 2, 3]) }.to raise_error(ArgumentError)
        end

        specify do
          expect { Distinctio::Differs::Base.apply(3, 2, :text) }.to raise_error(ArgumentError)
        end

      end

      context "returns an error on inapplicable delta on simple" do
        subject { Distinctio::Differs::Base.apply(3, [1, 2]) }

        it { should be_a(Distinctio::Differs::Simple::Error) }
        its(:actual_a) { should == 3 }
        its(:expected_a) { should == 1 }
        its(:expected_b) { should == 2 }
      end

      context do
        let(:a) { { :name => 'txt' } }
        let(:b) { { } }
        let(:delta) { [{:name=>"txt"}, {}] }

        specify { subject.calc(a, b).should == delta }
        specify { subject.apply(a, delta).should == b }
        specify { subject.apply(b, delta).should == a }
      end

      context do
        let(:a) { { } }
        let(:b) { { } }
        let(:delta) { nil }
        it_should_correctly "calc and apply difference"
      end

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

      describe "" do
        describe do
          let(:a) { { :id => 1, :data => 'data' } }
          let(:b) { { :id => 1, :code => 'code' } }
          let(:delta) { {
            'data' =>  ['data', Distinctio::Nothing.new],
            'code' =>  [Distinctio::Nothing.new, 'code']
          } }

          specify { subject.calc(a, b, :object).should == delta }
          specify { subject.apply(a, delta, :object).should == b.with_indifferent_access }
          specify { subject.apply(b, delta, :object).should == a.with_indifferent_access }
        end

        describe do
          let(:a) { { :id => 1, :code => nil, :data => 'data' } }
          let(:b) { { :id => 1, :code => 'code', :data => nil } }
          let(:delta) { {
            'data' =>  ['data', nil],
            'code' =>  [nil, 'code']
          } }

          specify { subject.calc(a, b, :object).should == delta }
          specify { subject.apply(a, delta, :object).should == b.with_indifferent_access }
          specify { subject.apply(b, delta, :object).should == a.with_indifferent_access }
        end
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
        specify { subject.apply(a, delta, :object).should == b.with_indifferent_access }
        specify { subject.apply(b, delta, :object).should == a.with_indifferent_access }
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
        let(:delta) { nil }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are nil" do
        let(:a) { nil }
        let(:b) { 1 }
        let(:delta) { [nil, 1] }
        it_should_correctly "calc and apply difference"
      end

      context "a and b are equal objects" do
        let(:a) { 1 }
        let(:b) { 1 }
        let(:delta) { nil }
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