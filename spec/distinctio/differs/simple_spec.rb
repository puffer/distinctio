require 'spec_helper.rb'

describe Distinctio::Differs::Simple do
  describe "delta calclation rules" do
    shared_examples_for "calc and apply difference" do
      specify { subject.calc(a, b).should == delta }
      specify { subject.apply(a, delta).should == b }
      specify { subject.apply(b, delta).should == a }
    end

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

    context "a and b are equal objects" do
      let(:a) { 1 }
      let(:b) { 1 }
      let(:delta) { nil }
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

    context "a and b are arrays" do
      let(:a) { [{ :a => 'hello' },  { :a => 'pdf' }] }
      let(:b) { [{ :a => 'goodbye' }, { :b => 'png' }] }
      let(:delta) { [[{ :a => 'hello' },  { :a => 'pdf' }], [{ :a => 'goodbye' }, { :b => 'png' }]] }
      it_should_correctly "calc and apply difference"
    end

    context do
      let(:a) { { :name => 'txt' } }
      let(:b) { { } }
      let(:delta) { [{:name=>"txt"}, {}] }
      it_should_correctly "calc and apply difference"
    end
  end

  describe "#apply" do
    context "raises an exception on mailformed delta" do
      specify { expect { subject.apply(3, 2) }.to raise_error(ArgumentError) }
      specify { expect { subject.apply(3, [3]) }.to raise_error(ArgumentError) }
      specify { expect { subject.apply(3, [1, 2, 3]) }.to raise_error(ArgumentError) }
      specify { expect { subject.apply(3, 2, :text) }.to raise_error(ArgumentError) }
    end

    context "returns an error on inapplicable delta" do
      subject { Distinctio::Differs::Base.apply(3, [1, 2]) }

      it { should be_a(Distinctio::Differs::Simple::Error) }
      its(:actual_a) { should == 3 }
      its(:expected_a) { should == 1 }
      its(:expected_b) { should == 2 }
    end
  end
end