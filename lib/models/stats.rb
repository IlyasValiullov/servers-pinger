module Checker
  class Stats < Sequel::Model(Checker::DB[:stats])
    one_to_one :host
  end
end
