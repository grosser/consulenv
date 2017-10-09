require "spec_helper"

SingleCov.covered!

describe Consulenv do
  it "has a VERSION" do
    expect(Consulenv::VERSION).to match(/^[\.\da-z]+$/)
  end
end
