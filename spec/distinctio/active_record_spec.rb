require 'spec_helper.rb'

describe Distinctio::ActiveRecord do

  describe "#attributes_were" do
    describe "result" do
      context "no attrs specified" do
        let(:book) { Fabricate.build :book }
        subject { book.attributes_were }

        it { should be_a(Hash) }
        it { should have(4).keys }
        it { should have_key('id') }
        it { should have_key('name') }
        it { should have_key('year') }
        it { should have_key('authors') }
      end

      context "attrs specified in distinctio method" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_were }

        it { should be_a(Hash) }
        it { should have(4).keys }
        it { should have_key('id') }
        it { should have_key('bio') }
        it { should have_key('name') }
        it { should have_key('books') }

        describe "habtm model attributes" do
          subject { author.attributes_were['books'] }
          its(:count) { should == 1 }
        end
      end

      context "custom attrs specified" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_were :name, 'bio' }

        it { should be_a(Hash) }
        it { should have(2).keys }
        it { should have_key('name') }
        it { should have_key('bio') }
      end
    end

    describe "returns the same result after changing attrs" do
      let(:author) { Fabricate.build :author }
      let!(:original) { author.attributes_were }
      before { author.name = "Another Name" }
      specify { author.attributes_were.should == original }
    end
  end

  describe "#attributes_are" do
    describe "result" do

      context "no attrs specified" do
        let(:book) { Fabricate.build :book }
        subject { book.attributes_are }

        it { should be_a(Hash) }
        it { should have(4).keys }
        it { should have_key('id') }
        it { should have_key('name') }
        it { should have_key('year') }
        it { should have_key('authors') }
      end

      context "attrs specified in distinctio method" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_are }

        it { should be_a(Hash) }
        it { should have(4).keys }
        it { should have_key('id') }
        it { should have_key('bio') }
        it { should have_key('name') }
        it { should have_key('books') }

        describe "habtm model attributes" do
          subject { author.attributes_were['books'] }
          its(:count) { should == 1 }
          specify { subject.first.should have(3).keys }
        end
      end

      context "custom attrs specified" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_are :name, 'bio' }

        it { should be_a(Hash) }
        it { should have(2).keys }
        it { should have_key('name') }
        it { should have_key('bio') }
      end
    end

    describe "returns changed attributes" do
      let(:author) { Fabricate.build :author }
      before { author.name = "Another Name" }
      specify { author.attributes_are()['name'].should == "Another Name" }
    end
  end

end