#!/usr/bin/env ruby
require 'dotenv'
Dotenv.load('config/app.env')

require 'rubygems'
require 'thor'
require './lib/base'


class ServerChecker < Thor
  package_name 'Server checker'
  desc 'add [HOST]', 'add host to checker'
  def add(host)
    Checker::AddHost.call(host: host)
  end

  desc 'delete [HOST]', 'delete host from checker'
  def delete(host)
    Checker::DeleteHost.call(host: host)
  end

  desc 'check', 'check all host from base'
  def check
    Checker::CheckHost.()
  end


  desc "stat [HOST] [PERIOD_START] [PERIOD_END]\n", 'get stats of server in period'
  d = <<~END
    "Get stats of server ping in period. Period can be empty.\n
    \b\bExamples:\n
    stat google.ru 2017.09.31 2017.11.01\n
    stat google.ru
  END
  long_desc d
  def stat(host, period_start=nil, period_end=nil)
    if period_start.nil? || period_end.nil?
      date_start = nil
      date_end = nil
    else
      date_start = Time.strptime(period_start, "%Y.%m.%d")
      date_end = Time.strptime(period_end, "%Y.%m.%d")
    end

    Checker::GetStatistic.call(host: host, date_start: date_start, date_end: date_end)
  end

end

ServerChecker.start(ARGV)
