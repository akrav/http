require 'spec_helper'
require 'json'

describe HTTP::Response do
  describe "headers" do
    subject { HTTP::Response.new(200, "1.1", "Content-Type" => "text/plain") }

    it "exposes header fields for easy access" do
      expect(subject["Content-Type"]).to eq("text/plain")
    end

    it "provides a #headers accessor too" do
      expect(subject.headers).to eq("Content-Type" => "text/plain")
    end
  end

  describe "to_a" do
    context "on an unregistered MIME type" do
      let(:body)         { "Hello world" }
      let(:content_type) { "text/plain" }
      subject { HTTP::Response.new(200, "1.1", {"Content-Type" => content_type}, body) }

      it "returns a Rack-like array" do
        expect(subject.to_a).to eq([200, {"Content-Type" => content_type}, body])
      end
    end
  end
end
