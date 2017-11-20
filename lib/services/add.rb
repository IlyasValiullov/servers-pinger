require 'trailblazer/operation'
require 'sequel'

module Checker
  class AddHost < Trailblazer::Operation

    # step :connect_to_base
    step :check_exist
    success :add_host

    def check_exist(_options, params:, **)
      Checker::Host.where(name: params[:host]).empty?
    end

    def add_host(_options, params:, **)
      host = Checker::Host.new
      host.name = params[:host]
      if host.save
        puts 'Success'
      end
    end
  end
end
