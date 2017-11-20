module Checker
  class Host < Sequel::Model(Checker::DB[:hosts])
    one_to_many :stats
  end
end
