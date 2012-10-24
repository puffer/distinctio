require 'spec_helper.rb'

describe Distinctio::ActiveRecord do

  describe "diff saved on each update" do
    let(:club) { Fabricate :club }
    specify { expect { club.update_attributes(name: "A name") }.to change(History, :count).from(0).to(1) }

    describe "history object" do
      let!(:club) { Fabricate :club }
      before { club.update_attributes(name: "A name") }
      subject { History.last }
      its(:model_id) { should == club.id }
      its(:model) { should == club }
      its(:delta) { should == club.attributes_are }
    end
  end

  describe "#apply" do
    describe "no attr specified" do
      let(:club) { Fabricate :club }
      let(:old_attrs) { club.attributes_are }
      let(:new_attrs) { { 'id' => club.id, 'name' => 'A new name', 'url' => 'http://club.com' } }

      let(:delta) { Distinctio::Differs::Base.calc(old_attrs, new_attrs, :object) }

      specify { expect { club.apply(delta) }.not_to change(club, :id) }
      specify { expect { club.apply(delta) }.to change(club, :name).to('A new name') }
      specify { expect { club.apply(delta) }.to change(club, :url).from(nil).to('http://club.com') }
      specify { expect { club.apply(delta) }.not_to change(club, :valid?).to(false) }
    end

    describe "attrs specified in distinctio method" do
      let(:book) { Fabricate :book }
      let(:old_attrs) { book.attributes_are }
      let(:new_attrs) do
        {
          'id' => book.id, 'name' => 'A new name', 'year' => 1900,
          'authors' => [ { 'id' => 1, 'name' => 'Author Name', 'bio' => 'Author bio' } ]
        }
      end

      let(:delta) { Distinctio::Differs::Base.calc(old_attrs, new_attrs, :object, { :authors => :object }) }

      specify { expect { book.apply(delta) }.not_to change(book, :id) }
      specify { expect { book.apply(delta) }.to change(book, :name).to('A new name') }
      specify { expect { book.apply(delta) }.to change(book, :year).to(1900) }
      specify { expect { book.apply(delta) }.to change(book.authors, :size).from(0).to(1) }
      specify { expect { book.apply(delta) }.not_to change(book, :valid?).to(false) }
    end

    describe "attrs specified in distinctio method" do
      let(:book) { Fabricate(:book_with_author) }
      let(:old_attrs) { book.attributes_are }
      let(:new_attrs) do
        {
          'id' => book.id, 'name' => 'A new name', 'year' => 1900,
          'authors' => [
            { 'id' => 155, 'name' => 'Somebody', 'bio' => 'Somebody bio' } ,
            { 'id' => 551, 'name' => 'Anybody', 'bio' => 'Anybody bio' }
          ]
        }
      end

      let(:delta) { Distinctio::Differs::Base.calc(old_attrs, new_attrs, :object, { :authors => :object }) }

      specify { expect { book.apply(delta) }.not_to change(book, :id) }
      specify { expect { book.apply(delta) }.to change(book, :name).to('A new name') }
      specify { expect { book.apply(delta) }.to change(book, :year).to(1900) }
      specify { expect { book.apply(delta) }.to change(book.authors, :size).from(1).to(2) }
      specify { expect { book.apply(delta) }.not_to change(book, :valid?).to(false) }
    end

    describe "attrs specified in distinctio method" do
      let(:author) { Fabricate(:author) }
      let(:old_attrs) { author.attributes_are }
      let(:new_attrs) do
        {
          'id' => author.id, 'name' => 'A new name',
          'books' => [],
          'club' => nil,
          'awards' => [{ 'id' => 135, 'name' => 'Medal of Honor' }]
        }
      end

      let(:delta) do
        Distinctio::Differs::Base.calc(old_attrs, new_attrs, :object,
          { :books => :object, :awards => :object, :club => :object })
      end

      specify { expect { author.apply(delta) }.not_to change(author, :id) }
      specify { expect { author.apply(delta) }.to change(author, :name).to('A new name') }
      specify { expect { author.apply(delta) }.to change(author.books, :size).from(1).to(0) }
      specify { expect { author.apply(delta) }.to change(author.awards, :size).from(2).to(1) }
      specify { expect { author.apply(delta) }.to change(author, :club).to(nil) }
      specify { expect { author.apply(delta) }.not_to change(author, :valid?).to(false) }
    end

    describe "bad delta specified" do
      context "bad delta for object without embedded objects" do
        let(:club) { Fabricate :club }
        let(:wrong_delta) { {"name"=>['Fight club', 'A new name']} }
        before { club.apply(wrong_delta) }
        specify { club.name.should == 'A new name' }
        specify { club.distinctio_errors.size.should == 1 }
        specify { club.should be_invalid }
      end

      context "bad delta for embedded object" do
        let(:author) { Fabricate :author }
        let(:wrong_delta) do
          {
            "bio"=>["American author and humorist", nil],
            "club"=>{"name"=>["Sober Clam club", "Drunk Clam club"]},
            "awards"=>[
              {"id"=>author.awards.first.id, "name"=>["Award", "Medal of Honor"]},
              {"id"=>author.awards.last.id, "name"=>["Award", nil]}
            ],
            "books"=>[ {"id"=>author.books.first.id, "name"=>["The Adventures of Tom Sawyer", nil], "year"=>[1876, nil]} ]
          }
        end

        before(:all) { author.apply(wrong_delta) }

        specify { author.should be_invalid}
        specify { author.club.should be_invalid }
        specify { author.club.distinctio_errors.should_not be_empty }
        specify { author.awards.first.should be_invalid }
        specify { author.awards.first.distinctio_errors.should_not be_empty }
        specify { author.awards.last.should be_invalid }
        specify { author.awards.last.distinctio_errors.should_not be_empty }
      end
    end
  end

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
        next_id = Club.maximum(:id) + 1
        expect { club.save }.to change(club, :attributes_are)
          .from({"id" => nil, "name" => "Pickwick club", "url" => nil})
          .to({"id" => next_id, "name" => "Pickwick club", "url" => nil})
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