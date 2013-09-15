require 'spec_helper'
require 'json'

describe HTTP do
  let(:test_endpoint)  { "http://127.0.0.1:#{ExampleService::PORT}/" }
  let(:proxy_endpoint) { "#{test_endpoint}proxy" }

  context "getting resources" do
    it "should be easy" do
      response = HTTP.get(test_endpoint)
      expect(response.body.to_s).to match(/<!doctype html>/)
    end

    context "with query string parameters" do
      it "should be easy" do
        response = HTTP.get("#{test_endpoint}params" , :params => {:foo => 'bar'})
        expect(response.body.to_s).to  match(/Params!/)
      end
    end

    context "with headers" do
      it "should be easy" do
        response = HTTP.accept(:json).get(test_endpoint)
        expect(response['Content-Type']).to eq 'application/json'
      end
    end

    it "should return the correct status" do
      res = HTTP.get(test_endpoint)
      expect(res.status).to eq(200)

      res = HTTP.get "#{test_endpoint}not-found"
      expect(res.status).to eq(404)
    end
  end

  context "with http proxy address and port" do
    it "should proxy the request" do
      response = HTTP.via("127.0.0.1", 8080).get(proxy_endpoint)
      expect(response.body.to_s).to match(/Proxy!/)
    end
  end

  context "with http proxy address, port username and password" do
    it "should proxy the request" do
      response = HTTP.via("127.0.0.1", 8081, "username", "password").get(proxy_endpoint)
      expect(response.body.to_s).to match(/Proxy!/)
    end
  end

  context "with http proxy address, port, with wrong username and password" do
    it "should proxy the request" do
      pending "fixing proxy support"

      response = HTTP.via("127.0.0.1", 8081, "user", "pass").get(proxy_endpoint)
      expect(response.body.to_s).to match(/Proxy Authentication Required/)
    end
  end

  context "without proxy port" do
    it "should raise an argument error" do
      expect { HTTP.via("127.0.0.1") }.to raise_error ArgumentError
    end
  end

  context "posting to resources" do
    it "should be easy to post forms" do
      response = HTTP.post "#{test_endpoint}form", :form => {:example => 'testing-form'}
      expect(response.body.to_s).to eq("passed :)")
    end
  end

  context "posting with an explicit body" do
    it "should be easy to post" do
      response = HTTP.post "#{test_endpoint}body", :body => "testing-body"
      expect(response.body.to_s).to eq("passed :)")
    end
  end

  context "with redirects" do
    it "should be easy for 301" do
      response = HTTP.with_follow(true).get("#{test_endpoint}redirect-301")
      expect(response.body.to_s).to match(/<!doctype html>/)
    end

    it "should be easy for 302" do
      response = HTTP.with_follow(true).get("#{test_endpoint}redirect-302")
      expect(response.body.to_s).to match(/<!doctype html>/)
    end

  end

  context "head requests" do
    it "should be easy" do
      response = HTTP.head test_endpoint
      expect(response.status).to eq(200)
      expect(response['content-type']).to match(/html/)
    end
  end
end
