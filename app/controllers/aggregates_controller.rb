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
    urls = {}
    Async do
      SERVICES.each do |service|
        Async.run do
          urls[service] = "#{ROOT_SERVICE_URL}/#{service}"
          clients[service] = Async::HTTP::Internet.new
          puts "#{service} started at #{Time.now}"
          responses[service] = clients[service].get(urls[service]).read
          puts "#{service} finished at #{Time.now}"
        rescue => exc
          responses[service] = "Exception: #{exc}"
        ensure
          clients[service].close
        end
      end
    end

    render json: responses
  end
end

