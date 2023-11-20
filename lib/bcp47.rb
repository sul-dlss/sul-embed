# frozen_string_literal: true

# The `Parser`, `Record`, and `Registry` classes were adapted from Arthur
# Rosendahl's MIT-licensed `ruby-bcp47` library [1] and significantly modified
# for alignment with DLSS software design and development practices/conventions.
#
# The tests in `spec/lib/bcp47/registry_spec.rb` are largely the same as in
# Arthur's library. Thanks to Arthur for giving us his blessing to take this
# work forward and maintain it.
#
# [1]: https://github.com/reutenauer/ruby-bcp47
module Bcp47
  require 'bcp47/parser'
  require 'bcp47/record'
  require 'bcp47/registry'
end
