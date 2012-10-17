require 'spec_helper.rb'

describe Distinctio::Differs::Text do
  let(:a) { 'hello, world!'}
  let(:b) { 'The world is mine!' }
  let(:delta) { "@@ -1,13 +1,18 @@\n+T\n he\n-llo,\n  world\n+ is mine\n !\n" }

  describe ".calc" do
    context "valid args" do
      specify { subject.calc(a, b).should == delta }
    end

    describe "returns an error on inapplicable delta" do
      let(:delta) { "@@ -1,13 +1,10 @@\n-Hello\n+By\n , world\n-!\n+.\n" }

      specify { subject.apply('foo', delta).a.should == 'foo' }
      specify { subject.apply('foo', delta).delta.should == delta }
    end

    describe "raises errors on invalid args" do

      specify do
        expect { subject.calc('txt', nil) }.to raise_error(ArgumentError)
      end

      specify do
        expect { subject.calc(nil, 'txt') }.to raise_error(ArgumentError)
      end

    end
  end

  describe ".apply" do
    context "valid args" do
      specify { subject.apply(a, delta).should == b }
    end

    describe "raises errors on invalid args" do

      specify do
        expect { subject.apply(nil, 'txt') }.to raise_error(ArgumentError)
      end

      specify do
        expect { subject.apply('txt', nil) }.to raise_error(ArgumentError)
      end

      specify do
        expect { subject.apply('txt', '@@ -1') }.to raise_error(ArgumentError)
      end

    end
  end

end