require 'spec_helper'

describe HTTP::Options do
  subject { described_class.new(:response => :body) }

  it "behaves like a Hash for reading" do
    expect(subject[:nosuchone]).to be_nil
  end

  it "coerces to a Hash" do
    expect(subject.to_hash).to be_a(Hash)
  end
end
