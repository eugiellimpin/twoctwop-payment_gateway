require "nokogiri"

module Twoctwop
  module PaymentGateway
    class RequestStep
      Error = Class.new(StandardError)

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

      def post
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
