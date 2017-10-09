require "spec_helper"

SingleCov.covered!

describe Consulenv do
  around do |test|
    begin
      original = ENV.to_h
      test.call
    ensure
      ENV.replace(original)
    end
  end

  it "has a VERSION" do
    expect(Consulenv::VERSION).to match(/^[\.\da-z]+$/)
  end

  it "can read keys" do
    stub_request(:put, "http://localhost:8500/v1/txn").
      with(body: [{"KV"=>{"Verb"=>"get", "Key"=>"foo/bar"}}, {"KV"=>{"Verb"=>"get", "Key"=>"bar/foo"}}].to_json).
      to_return(body: {
        "Results" => [
          {"KV" => {"Key" => "foo/bar", "Value" => Base64.encode64("Hello")}},
          {"KV" => {"Key" => "bar/foo", "Value" => Base64.encode64("World")}}
        ]
      }.to_json)
    Consulenv.load(
      "foo/bar" => "FOO",
      "bar/foo" => "BAR"
    )
    expect(ENV["FOO"]).to eq "Hello"
    expect(ENV["BAR"]).to eq "World"
  end

  it "can read null" do
    stub_request(:put, "http://localhost:8500/v1/txn").
      with(body: [{"KV"=>{"Verb"=>"get", "Key"=>"foo/bar"}}].to_json).
      to_return(body: {"Results" => [{"KV" => {"Key" => "foo/bar", "Value" => "null"}}]}.to_json)
    ENV["FOO"] = "Hello"
    Consulenv.load("foo/bar" => "FOO")
    expect(ENV["FOO"]).to eq nil
  end

  it "splits at 64" do
    keys = (0..65).to_a.map(&:to_s)
    request = stub_request(:put, "http://localhost:8500/v1/txn").
      to_return(body: {"Results" => keys.map { |k| {"KV" => {"Key" => k, "Value" => Base64.encode64("Hello")}}}}.to_json)
    Consulenv.load(keys.map { |k| [k, k]}.to_h)
    expect(ENV["1"]).to eq "Hello"
    assert_requested(request, times: 2)
  end

  it "raises on error" do
    stub_request(:put, "http://localhost:8500/v1/txn").to_return(status: 500, body: "Nope")
    expect { Consulenv.load("foo/bar" => "FOO") }.to raise_error(Consulenv::ConsulError, "Consul request failed: Nope")
  end
end
