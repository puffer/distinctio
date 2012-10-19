require 'spec_helper.rb'

describe Distinctio::ActiveRecord do

  describe "#attributes_were" do
    describe "result" do

      context "no attrs specified" do
        let(:club) { Fabricate.build :club }
        subject { club.attributes_were }

        it { should be_a(Hash) }
        it { should have(3).keys }
        it { should have_key('id') }
        it { should have_key('name') }
        it { should have_key('url') }
      end

      context "attrs specified in distinctio method" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_were }

        it { should be_a(Hash) }
        it { should have(6).keys }
        it { should have_key('id') }
        it { should have_key('bio') }
        it { should have_key('name') }
        it { should have_key('club') }
        it { should have_key('books') }
        it { should have_key('awards') }
        it { should_not have_key('nonexisting_field') }

        describe "belongs_to model attributes" do
          let(:club) { author.attributes_were['club'] }
          subject { club }
          it { should have(3).keys }
          it { should have_key('id') }
          it { should have_key('name') }
          it { should have_key('url') }
        end

        describe "has_many model attributes that has no distinctio method and Distinctio::ActiveRecord" do
          let(:awards) { author.attributes_were['awards'] }
          subject { awards }

          its(:count) { should == 2 }

          describe "model attributes" do
            subject { awards.first }
            it { should have(2).keys }
            it { should have_key('id') }
            it { should have_key('name') }
          end
        end

        describe "habtm model attributes" do
          let(:books) { author.attributes_were['books'] }
          subject { books }

          its(:count) { should == 1 }

          describe "model attributes" do
            subject { books.first }
            it { should have(3).keys }
            it { should have_key('id') }
            it { should have_key('name') }
            it { should have_key('year') }

            specify "do not contain attributes that are absent in habtm model" do
              subject.should_not have_key('nonexisting_field')
            end
          end
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

    describe "" do
      let(:club) { Fabricate.build :club }
      specify do
        expect { club.save }.to change(club, :attributes_are)
          .from({"id" => nil, "name" => "Pickwick club", "url" => nil})
          .to({"id" => 1, "name" => "Pickwick club", "url" => nil})
      end
    end
  end

  describe "#attributes_are" do
    describe "result" do

      context "no attrs specified" do
        let(:club) { Fabricate.build :club }
        subject { club.attributes_are }

        it { should be_a(Hash) }
        it { should have(3).keys }
        it { should have_key('id') }
        it { should have_key('name') }
        it { should have_key('url') }
      end

      context "attrs specified in distinctio method" do
        let(:author) { Fabricate.build :author }
        subject { author.attributes_are }

        it { should be_a(Hash) }
        it { should have(6).keys }
        it { should have_key('id') }
        it { should have_key('bio') }
        it { should have_key('name') }
        it { should have_key('club') }
        it { should have_key('books') }
        it { should have_key('awards') }

        describe "belongs_to model attributes" do
          let(:club) { author.attributes_are['club'] }
          subject { club }
          it { should have(3).keys }
          it { should have_key('id') }
          it { should have_key('name') }
          it { should have_key('url') }
        end

        describe "has_many model attributes that has no distinctio method and Distinctio::ActiveRecord" do
          let(:awards) { author.attributes_are['awards'] }
          subject { awards }

          its(:count) { should == 2 }

          describe "model attributes" do
            subject { awards.first }
            it { should have(2).keys }
            it { should have_key('id') }
            it { should have_key('name') }
          end
        end

        describe "habtm model attributes" do
          subject { author.attributes_are['books'] }
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
      specify { author.attributes_are['name'].should == "Another Name" }
    end
  end

end