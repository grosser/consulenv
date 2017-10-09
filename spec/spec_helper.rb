require "bundler/setup"

require "single_cov"
SingleCov.setup :rspec

require "webmock/rspec"
require "consulenv/version"
require "consulenv"
