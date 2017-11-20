require 'trailblazer/operation'
require 'sequel'
require 'rubygems'
require 'net/ping'
require 'concurrent'

module Checker
  class CheckHost < Trailblazer::Operation

    # step :connect_to_base
    step :check_host

    def check_host(_options, **)
      hosts = Checker::Host.all
      hosts.each do |host|
        # puts host
        p = Concurrent::Promise.fulfill(30)
                .then { pinger_start(host) }
                .then { |result| save_result(result, host) }
                .rescue { |reason| puts "Error #{reason}" }
                .execute
          #

        # save_result(get_ping(host.name), host)

        # icmp = Net::Ping::ICMP.new(host.name)
        # response = icmp.ping
        #
        # result = Checker::Stats.new
        # result.date = DateTime.now
        # result.response = response
        # result.host = host
        # result.save
        #
        # puts "#{host.name} #{response}"
      end
      puts 'waiting'
      30.times do
        print '.'
        sleep(1)
      end
      puts 'OK'
    end

    private

    class Pinger
      include Concurrent::Async

      attr_reader :result

      def get_ping(host)
        IO.popen("ping -w 20 #{host}") do |io|
          @result = io.readlines
        end
        # Process.wait(out.pid)
      end
    end

    def pinger_start(host)
      pinger = Pinger.new
      i = pinger.async.get_ping(host.name)
      i.wait!
      pinger.result
    end

    def save_result(result, host)
      has_result = /.*ping statistics.*/m.match(result.join('\n'))
      return nil unless has_result
      count = 1
      responses = []
      (result.size-2).times do
        m = /.*=([0-9]*[.]*[0-9]*) ms/.match(result[count])
        if m && !m.captures.empty?
          responses.push(m.captures[0].to_f.round(1))
        end

        count += 1
      end
      response = responses.inject { |sum, el| sum + el } / responses.size
      m = /(\d+) packets transmitted, (\d+) received/.match(result[-2])
      packets_transmitted = 0
      packets_received = 0
      if m && !m.captures.empty?
        packets_transmitted = m.captures[0]
        packets_received = m.captures[1]
      end

      result = Checker::Stats.new
      result.date = Time.now
      result.response = response
      result.packets_transmitted = packets_transmitted
      result.packets_received = packets_received
      result.host_id = host.id
      result.save
    end
  end
end
