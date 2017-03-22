require "nokogiri"
require "httparty"

module Twoctwop
  module PaymentGateway
    class RequestStep
      Error = Class.new(StandardError)

      include HTTParty

      @@cookie_jar = {}

      attr_reader :url, :payload, :payment_response

      def initialize(options={})
        @url      = options.fetch(:url, nil)
        @payload  = options.fetch(:payload, nil)
        @details  = options.fetch(:details, nil)
      end

      def execute
        check_for_payment_response(post)
      end

      def prepare(response)
        html = Nokogiri::HTML(response.body)

        begin
          unless @url
            form_id = @details[:form_id]
            @url = html.css("##{form_id}").first['action'] if form_id
          end

          unless @payload
            input_id = @details[:input_id]
            @payload = { input_id => html.css("##{input_id}").first['value'] } if input_id
          end
        rescue NoMethodError => e
          raise Error.new("Could not find required information for next request")
        end

        self
      end

      private

      def post
        @response = self.class.post(@url, body: @payload, headers: { 'Cookie' => cookies })
        store_cookies(@response.headers['Set-Cookie'])
        @response
      end

      def cookies
        @@cookie_jar.fetch(host, CookieHash.new).to_cookie_string
      end

      def store_cookies(new_cookies)
        if new_cookies && !new_cookies.empty?
          @@cookie_jar[host] ||= CookieHash.new
          @@cookie_jar[host].add_cookies(new_cookies)
        end
      end

      def host
        @host ||= URI.parse(@url).host
      end

      def check_for_payment_response(response)
        html = Nokogiri::HTML(response.body)

        unless (payment_response_el = html.css("#paymentResponse")).empty?
          @payment_response = payment_response_el.first['value']
        end

        response
      end
    end
  end
end
