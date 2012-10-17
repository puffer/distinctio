require 'spec_helper.rb'

describe "simple diff" do
  subject { Distinctio::Differs::Base }

  describe "text method" do

    context "a and b are hashes" do
      context "one entry as text, whole hash as an object" do
        let(:a) { { :id => 1, :name => 'Nancy', :message => 'hello, world!'} }
        let(:b) { { :id => 1, :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
        let(:delta) { {
          'message' => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
          'extra' => [nil, "Extra."]
        } }
        let(:opts) { { :message => :text } }

        specify { subject.calc(a, b, :object, opts).should == delta }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

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

      context "one entry as text, whole hash as a hash" do
        let(:a) { { :id => 1, :name => 'Nancy', :message => 'hello, world!'}.with_indifferent_access }
        let(:b) { { :id => 2, :name => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'}.with_indifferent_access }
        let(:delta) { [
          {'id'=>1, 'name'=>"Nancy", 'message'=>"hello, world!"},
          {'id'=>2, 'name'=>"Nancy", 'message'=>"The world is mine!", 'extra'=>"Extra."}
        ] }

        specify { subject.calc(a, b, :object).should == delta }
        specify { subject.apply(a, delta, :object).should == b.with_indifferent_access }
      end
    end

    context do

      context "one entry as text, another one as an object" do
        let(:a) { { :id =>1, :name => 'Nancy', :message => 'hello, world!'} }
        let(:b) { { :id =>1, :name => 'Andy', :message => 'The world is mine!', :extra => 'Extra.'} }
        let(:delta) { {
          'message' => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
          'extra' => [nil, "Extra."],
          'name' => ["Nancy", "Andy"]
        } }
        let(:opts) { { :message => :text, :name => :simple } }

        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context "with keys as symbols & strings" do
        let(:a) { { :id => 1, 'name' => 'Nancy', :message => 'hello, world!'} }
        let(:b) { { :id => 1, 'name' => 'Nancy', :message => 'The world is mine!', :extra => 'Extra.'} }
        let(:delta) { {
          :message => "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n",
          :extra => [nil, "Extra."]
        } }
        let(:opts) { { :message => :text, :name => :object } }

        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context "a and b are strings" do
        let(:a) { 'hello, world!' }
        let(:b) { 'The world is mine!' }
        let(:delta) { "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n" }

        specify { subject.calc(a, b, :text).should == delta }
        specify { subject.apply(a, delta, :text).should == b }
      end
    end

    context "with nested hashes" do
      context 'one-level nested hash' do
        let(:a) { {
            :name => 'Page',
            :page_part_attributes => { :id => 1, :body => "Lorem ipsum", :name => "Heading" }
        } }
        let(:b) { {
            :name => 'Page',
            :page_part_attributes => { :id => 1, :body => "Lorem ipsum dolor" }
        } }

        let(:delta) { subject.calc(a, b) }
        specify { subject.apply(a, delta).should == b }
      end

      context 'one-level nested hash' do
        let(:a) { {
            :id => 1,
            :name => 'Page',
            :page_part_attributes => { :id => 1, :body => "Lorem ipsum", :name => "Heading" }
        } }
        let(:b) { {
            :id => 1,
            :name => 'Page',
            :page_part_attributes => { :id => 2, :body => "Lorem ipsum dolor" }
        } }
        let(:delta) {
          {
            :page_part_attributes=>[
              {:id=>1, :body=>"Lorem ipsum", :name=>"Heading"},
              {:id=>2, :body=>"Lorem ipsum dolor"}
            ]
          }.with_indifferent_access
        }
        specify { subject.calc(a, b, :object).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object).should == b.with_indifferent_access }
      end

      context 'one-level nested hash' do
        let(:a) { {
            :id => 1,
            :name => 'Page',
            :page_part_attributes => { :id => 1, :body => "Lorem ipsum", :name => "Heading" }
        } }
        let(:b) { {
            :id => 1,
            :name => 'Page',
            :page_part_attributes => { :id => 2, :body => "Lorem ipsum dolor" }
        } }
        let(:delta) do
          {
            :page_part_attributes=>[
              {:id=>1, :body=>"Lorem ipsum", :name=>"Heading"},
              {:id=>2, :body=>"Lorem ipsum dolor"}
            ]
          }.with_indifferent_access
        end
        let(:opts) { { :page_part_attributes => :simple } }

        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context 'one-level nested hash' do
        let(:a) { {
            :id => 1,
            :name => 'Page',
            :page_part_attributes => { :id => 1, :body => "Lorem ipsum", :name => "Heading" }
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
              :name=>["Heading", nil],
              :entry=>[nil, {:id=>1, :name=>"Name"}]
            }
          }
        }
        let(:opts) { { :page_part_attributes => { :body => :text } } }
        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context 'one-level nesting' do
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
        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context 'one-level nesting with ids as strings and symbols' do
        let(:a) { {
            :id => 1,
            :name => 'Page',
            :page_parts => [
              { 'id' => 1, :body => "Lorem ipsum" },
              { :id => 2, :body => "Sit amet" }
            ]
        } }
        let(:b) { {
            :id => 1,
            :name => 'Page',
            :page_parts => [
              { 'id' => 1, :body => "Lorem ipsum dolor" },
              { 'id' => 2, :body => "Sit amet consectetur" }
            ]
        } }

        let(:delta) { {
          :page_parts => [
            { :body=>"@@ -4,8 +4,14 @@\n em ipsum\n+ dolor\n", 'id'=>1 },
            { :body=>"@@ -1,8 +1,20 @@\n Sit amet\n+ consectetur\n", 'id'=>2 }
          ]
        } }
        let(:opts) { { :page_parts => { :body => :text } } }
        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context 'two-level nesting' do
        let(:a) { {
            :id => 1,
            :name => 'Page',
            :page_parts => [
              { :id => 1, :body => "Lorem ipsum", :elems => [
                { :id => 1, :value => 'value' }
              ] },
              { :id => 2, :body => "Sit amet", :elems => [
                { :id => 2, :value => 'another value' }
              ] }
            ]
        } }
        let(:b) { {
            :id => 1,
            :name => 'Page',
            :page_parts => [
              { :id => 1, :body => "Lorem", :elems => [
                { :id => 1, :value => 'simple value' }
              ] },
              { :id => 2, :body => "Sit", :elems => [
                { :id => 2, :value => 'another value' }
              ] }
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

        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end

      context 'two-level nesting' do
        let(:a) { {
          :id => 1,
            :name => 'Page',
            :page_parts => [
              { :id => 1, :body => "Lorem ipsum", :elems => [
                { :id => 1, :value => 'value' }
              ] },
              { :id => 2, :body => "Sit amet", :elems => [
                { :id => 2, :value => 'another value' }
              ] }
            ]
        } }
        let(:b) { {
          :id => 1,
            :name => 'Page',
            :page_parts => [
              { :id => 1, :body => "Lorem", :elems => [
                { :id => 1, :value => 'simple value' }
              ] },
              { :id => 2, :body => "Sit", :elems => [
                { :id => 2, :value => 'another value' }
              ] }
            ]
        } }

        let(:delta) {
          {
            :page_parts=>[
              {:body=>"@@ -2,10 +2,4 @@\n orem\n- ipsum\n",
                :elems=>[{:value=>"@@ -1,5 +1,12 @@\n+simple \n value\n", :id=>1}], :id=>1},

              {:body=>"@@ -1,8 +1,3 @@\n Sit\n- amet\n", :id=>2}]}
        }
        let(:opts) { { :page_parts => { :elems => { :value => :text }, :body => :text } } }
        specify { subject.calc(a, b, :object, opts).should == delta.with_indifferent_access }
        specify { subject.apply(a, delta, :object, opts).should == b.with_indifferent_access }
      end
    end
  end
end