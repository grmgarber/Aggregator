# frozen_string_literal: true
require 'json'
require 'async'
require 'async/http/internet'

ROOT_SERVICE_URL = 'https://takehome.io'

SERVICES = %w(twitter facebook instagram).freeze

class AggregatesController < ApplicationController
  def index
    clients = {}
    responses = {}
    tasks = []
    SERVICES.each do |service|
      url = "#{ROOT_SERVICE_URL}/#{service}"

      Async do |task|
        tasks << task
        clients[service] = Async::HTTP::Internet.new
        task.with_timeout(10) do
          responses[service] = clients[service].get(url).read
        rescue Async::TimeoutError
          responses[service] = 'TIMED OUT'
        rescue => exc
          responses[service] = "Exception: #{exc}"
        ensure
          clients[service].close
        end
      end
    end

    results = tasks.map(&:wait)

    render json: responses
  end
end

