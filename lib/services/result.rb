require 'trailblazer/operation'
require 'sequel'


module Checker
  class GetStatistic < Trailblazer::Operation

    step :get_host
    success :get_stats_sql
    success :render_stats

    def get_host(_options, params:, **)
      hosts = Checker::Host.where(name: params[:host])
      @host = hosts.first
      !hosts.empty?
    end

    def get_stats_sql(_options, params:, **)
      if params[:date_start] && params[:date_end]
        date_start = params[:date_start].strftime("%Y-%m-%d 00:00:00.000000+0000")
        date_end = params[:date_end].strftime("%Y-%m-%d 00:00:00.000000+0000")
        query = <<~SQL
          SELECT
            hosts.name as name,
            min(stats.response) as min_response,
            max(stats.response) as max_response,
            avg(stats.response) as avg_response,
            sum(stats.packets_transmitted) as packets_trans,
            sum(stats.packets_received) as packets_received
          FROM stats
            INNER JOIN hosts
              ON (hosts.id= stats.host_id)
          WHERE ((host_id = :host_id)
            AND (stats.date > :date_start)
            AND (stats.date < :date_end))
          GROUP BY
            hosts.name
        SQL
        @stats_sql = Checker::DB[query,
                                 date_start: date_start,
                                 date_end: date_end,
                                 host_id: @host.id]
      else
        query = <<~SQL
          SELECT
            hosts.name as name,
            min(stats.response) as min_response,
            max(stats.response) as max_response,
            avg(stats.response) as avg_response,
            sum(stats.packets_transmitted) as packets_trans,
            sum(stats.packets_received) as packets_received
          FROM stats
            INNER JOIN hosts
              ON (hosts.id= stats.host_id)
          WHERE (host_id = :host_id)
          GROUP BY
            hosts.name
        SQL
        @stats_sql = Checker::DB[query,
                                 host_id: @host.id]
      end
    end

    def render_stats(_options, **)
      @stats_sql.all.each do |result|
        packets_lost_perc = 0
        if result[:packets_trans] && result[:packets_received]
          packets_lost_perc = (result[:packets_received] * 100) / result[:packets_trans]
        end
        result = {
          host: result[:name],
          min_response: result[:min_response]&.to_i&.round(2),
          max_response: result[:max_response]&.to_i&.round(2),
          avg_response: result[:avg_response]&.to_i&.round(2),
          packets_lost_perc: packets_lost_perc
        }
        puts result
      end
    end
  end
end
