require 'trailblazer/operation'
require 'sequel'

module Checker
  class DeleteHost < Trailblazer::Operation

    # step :connect_to_base
    step :delete_host

    def delete_host(_options, params:, **)
      host = Checker::Host.where(:host)
      host.name = params[:host]
      host.save
    end
  end
end
