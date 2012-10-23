require 'spec_helper.rb'

describe Distinctio::Differs::Object do
  describe "a and b are object attributes hashes" do
    context do
      let(:a) { { 'id' => 1, 'name' => 'txt' } }
      let(:b) { { 'id' => 1, 'name' => 'pdf' } }
      let(:delta) { { 'name' => ['txt', 'pdf'] } }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
    end

    context do
      let(:a) { { 'id' => 1, 'key' => 0 } }
      let(:b) { { 'id' => 1, 'key' => 1 } }
      let(:delta) { { 'key' => [0, 1] } }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
    end

    context do
      let(:a) { { 'id' => 1, 'key' => [1, 2] } }
      let(:b) { { 'id' => 1, 'key' => [2, 3] } }
      let(:delta) { { 'key' => [[1, 2], [2, 3]] } }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
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

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).except(:data).should == b.with_indifferent_access }
      specify { subject.apply(b, delta).except(:code).should == a.with_indifferent_access }
    end

    context "one entry as text, whole hash as a hash" do
      let(:a) { { :id => 1, :name => 'Nancy' }.with_indifferent_access }
      let(:b) { { :id => 2, :name => 'Nancy', :extra => 'Extra.'}.with_indifferent_access }
      let(:delta) { [
        {'id'=>1, 'name'=>"Nancy" },
        {'id'=>2, 'name'=>"Nancy", 'extra'=>"Extra."}
      ] }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b.with_indifferent_access }
    end
  end

  describe "a and b are arrays of object attributes hashes" do
    context "id is a symbol" do
      let(:a) { [ {:id => 1, :name => 'world'}, {:id => 2, :name => 'hello'} ] }
      let(:b) { [ {:id => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, 'name' => ['world', 'hello'] },
        { :id => 2, 'name' => ['hello', 'world'] },
        { :id => 3, 'name' => [nil, 'goodbye'] }
      ] }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should include({'id' => 2, 'name' => 'world'}) }
      specify { subject.apply(a, delta).should include({'id' => 1, 'name' => 'hello'}) }
      specify { subject.apply(a, delta).should include({'id' => 3, 'name' => 'goodbye'}) }
      specify { subject.apply(b, delta).should include({'id' => 1, 'name' => 'world'}) }
      specify { subject.apply(b, delta).should include({'id' => 2, 'name' => 'hello'}) }
      specify { subject.apply(b, delta).should_not include({'id' => 3, 'name' => 'goodbye'}) }
    end

    context "id is a string" do
      let(:a) { [ {"id" => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
      let(:b) { [ {"id" => 2, :name => 'world'}, {"id" => 1, :name => 'hello'}, {"id" => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, "name" => ['world', 'hello'] },
        { :id => 2, "name" => ['hello', 'world'] },
        { :id => 3, "name" => [nil, 'goodbye'] }
      ] }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should include({"id" => 2, "name" => 'world'}) }
      specify { subject.apply(a, delta).should include({"id" => 1, "name" => 'hello'}) }
      specify { subject.apply(a, delta).should include({"id" => 3, "name" => 'goodbye'}) }
      specify { subject.apply(b, delta).should include({"id" => 1, "name" => 'world'}) }
      specify { subject.apply(b, delta).should include({"id" => 2, "name" => 'hello'}) }
      specify { subject.apply(b, delta).should_not include({"id" => 3, :name => 'goodbye'}) }
    end

    context "ids are a string and a symbol" do
      let(:a) { [ {:id => 1, :name => 'world'}, {"id" => 2, :name => 'hello'} ] }
      let(:b) { [ {"id" => 2, :name => 'world'}, {:id => 1, :name => 'hello'}, {:id => 3, :name => 'goodbye'}] }
      let(:delta) { [
        { :id => 1, 'name' => ['world', 'hello'] },
        { :id => 2, 'name' => ['hello', 'world'] },
        { :id => 3, 'name' => [nil, 'goodbye'] }
      ] }

      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should include({"id" => 2, 'name' => 'world'}) }
      specify { subject.apply(a, delta).should include({"id" => 1, 'name' => 'hello'}) }
      specify { subject.apply(a, delta).should include({"id" => 3, 'name' => 'goodbye'}) }
      specify { subject.apply(b, delta).should include({"id" => 1, 'name' => 'world'}) }
      specify { subject.apply(b, delta).should include({"id" => 2, 'name' => 'hello'}) }
      specify { subject.apply(b, delta).should_not include({"id" => 3, 'name' => 'goodbye'}) }
    end

    context do
        let(:a) do
          [
            { :id => 1, :name => 'Jack' },
            { :id => 2, :name => 'Jill' }
          ]
        end
        let(:b) do
          [
            { :id => 2, :name => 'Jill' }.with_indifferent_access,
            { :id => 3, :name => 'Fred' }.with_indifferent_access
          ]
        end
        let(:delta) do
          [
            { :id => 1, "name" => ["Jack", nil] },
            { :id => 3, "name" => [nil, "Fred"] }
          ]
        end

        specify { subject.calc(a, b).should == delta }
        specify { subject.apply(a, delta).should == b }
      end
  end

  describe "#apply" do
    context "delta from another object" do
      let(:a) { { 'id' => 1, 'name' => 'txt' } }
      let(:b) { { 'id' => 1, 'name' => 'pdf' } }
      let(:bad_delta) { { 'name' => ['doc', 'pdf'] } }
      specify { subject.apply(a, bad_delta)[:name].should be_a(Distinctio::Differs::Simple::Error) }
    end

    context "delta is not a hash" do
      let(:a) { { 'id' => 1, 'name' => 'txt' } }
      specify { expect { subject.apply({ 'id' => 1, 'name' => 'txt' }, 'str') }.to raise_error(ArgumentError) }
      specify { expect { subject.apply([{ 'id' => 1, 'name' => 'txt' }], 'str') }.to raise_error(ArgumentError) }
    end

    context "bad argument" do
      let(:delta) { { 'name' => ['txt', 'pdf'] } }
      specify { expect { subject.apply('str', delta) }.to raise_error(ArgumentError) }
      specify { expect { subject.apply('str', delta) }.to raise_error(ArgumentError) }
    end
  end

  describe "with options" do
    context "one key as text" do
      let(:a) { { :id => 1, :name => 'Nancy', :message => 'hello, world!'} }
      let(:b) { { :id => 1, :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
      let(:delta) do
        { 'message' => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n", 'extra' => [nil, "Extra."] }
      end

      specify { subject.calc(a, b, { :message => :text }).should == delta }
      specify { subject.apply(a, delta, { :message => :text }).should == b.with_indifferent_access }
    end

    context "one key as text, another one as simple" do
      let(:a) { { :id =>1, :name => 'Nancy', :message => 'hello, world!'} }
      let(:b) { { :id =>1, :name => 'Andy', :message => 'The world is mine!', :extra => 'Extra.'} }
      let(:delta) { {
        'message' => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
        'extra' => [nil, "Extra."],
        'name' => ["Nancy", "Andy"]
      } }
      let(:opts) { { :message => :text, :name => :simple } }

      specify { subject.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { subject.apply(a, delta, opts).should == b.with_indifferent_access }
    end
  end

  context "with nested hashes" do
    context 'one-level nested hash as simple' do
      let(:a) { {
          :id => 1,
          :name => 'Page',
          :page_parts => { :id => 1, :body => "Lorem ipsum", :name => "Heading" }
      } }
      let(:b) { {
          :id => 1,
          :name => 'Page',
          :page_parts => { :id => 2, :body => "Lorem ipsum dolor" }
      } }
      let(:delta) {
        {
          :page_parts=>[
            {:id=>1, :body=>"Lorem ipsum", :name=>"Heading"},
            {:id=>2, :body=>"Lorem ipsum dolor"}
          ]
        }.with_indifferent_access
      }
      specify { Distinctio::Differs::Object.calc(a, b).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta).should == b.with_indifferent_access }
    end

    context 'one-level nested hash as object' do
      let(:a) { {
          :id => 1,
          :name => 'Page',
          :page_part_attributes => { :id => 1, :body => "Lorem ipsum" }
      } }
      let(:b) { {
          :id => 1,
          :name => 'Page',
          :page_part_attributes => { :id => 1, :body => "Lorem ipsum dolor", :entry => { :id => 1, :name => "Name" } }
      } }

      let(:delta) {
        {
          :page_part_attributes=>{
            :body=>"@@ -4,8 +4,14 @@\n em ipsum\n+ dolor\n",
            :entry=>[nil, {:id=>1, :name=>"Name"}]
          }
        }
      }
      let(:opts) { { :page_part_attributes => { :body => :text } } }
      specify { Distinctio::Differs::Object.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta, opts).should == b.with_indifferent_access }
    end

    context 'one-level nested array of hashes as object,' do
      let(:a) { {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem ipsum" },
            { :id => 2, :body => "Sit amet" }
          ]
      } }
      let(:b) { {
          :id => 1,
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
      let(:opts) { { :page_parts => { :body => :text } } }
      specify { Distinctio::Differs::Object.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta, opts).should == b.with_indifferent_access }
    end

    context 'one-level nesting with ids as strings and symbols' do
      let(:a) do
        {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { 'id' => 1, :body => "Lorem ipsum" },
            { :id => 2, :body => "Sit amet" }
          ]
        }
      end
      let(:b) do
        {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem ipsum dolor" },
            { 'id' => 2, :body => "Sit amet consectetur" }
          ]
        }
      end
      let(:delta) do
        {
          :page_parts => [
            { :body=>"@@ -4,8 +4,14 @@\n em ipsum\n+ dolor\n", 'id'=>1 },
            { :body=>"@@ -1,8 +1,20 @@\n Sit amet\n+ consectetur\n", 'id'=>2 }
          ]
        }
      end
      let(:opts) { { :page_parts => { :body => :text } } }
      specify { Distinctio::Differs::Object.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta, opts).should == b.with_indifferent_access }
    end

    context 'two-level nesting, second-level nested array of hashes as simple' do
      let(:a) do {
        :id => 1,
        :name => 'Page',
        :page_parts => [
          { :id => 1, :body => "Lorem ipsum", :elems => [ { :id => 1, :value => 'value' } ] },
          { :id => 2, :body => "Sit amet",    :elems => [ { :id => 2, :value => 'another value' } ] }
        ]
      } end
      let(:b) { {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem", :elems => [ { :id => 1, :value => 'simple value' } ] },
            { :id => 2, :body => "Sit",   :elems => [ { :id => 2, :value => 'another value' } ] }
          ]
      } }

      let(:delta) { {
        :page_parts=>[
          {
            :body=>"@@ -2,10 +2,4 @@\n orem\n- ipsum\n",
            :elems=>[
              [{:id=>1, :value=>"value"}],
              [{:id=>1, :value=>"simple value"}]
            ], :id=>1
          }, {
            :body=>"@@ -1,8 +1,3 @@\n Sit\n- amet\n",
            :id=>2
          }
        ]
      } }
      let(:opts) { { :page_parts => { :body => :text } } }

      specify { Distinctio::Differs::Object.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta, opts).should == b.with_indifferent_access }
    end

    context 'two-level nesting, second-level nested array of hashes as an object' do
      let(:a) do
        {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem ipsum", :elems => [ { :id => 1, :value => 'value' } ] },
            { :id => 2, :body => "Sit amet",    :elems => [ { :id => 2, :value => 'another value' } ] }
          ]
        }
      end
      let(:b) do
        {
          :id => 1,
          :name => 'Page',
          :page_parts => [
            { :id => 1, :body => "Lorem", :elems => [ { :id => 1, :value => 'simple value' } ] },
            { :id => 2, :body => "Sit",   :elems => [ { :id => 2, :value => 'another value' } ] }
          ]
        }
      end
      let(:delta) do
        {
          :page_parts=>[
            {:body=>"@@ -2,10 +2,4 @@\n orem\n- ipsum\n",
              :elems=>[{:value=>"@@ -1,5 +1,12 @@\n+simple \n value\n", :id=>1}], :id=>1},
            {:body=>"@@ -1,8 +1,3 @@\n Sit\n- amet\n", :id=>2}]
        }
      end
      let(:opts) { { :page_parts => { :elems => { :value => :text }, :body => :text } } }
      specify { Distinctio::Differs::Object.calc(a, b, opts).should == delta.with_indifferent_access }
      specify { Distinctio::Differs::Object.apply(a, delta, opts).should == b.with_indifferent_access }
    end
  end
end