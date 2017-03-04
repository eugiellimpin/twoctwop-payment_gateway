require "twoctwop/payment_gateway/version"

module Twoctwop
  module PaymentGateway
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuraiton ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    class Configuration
      attr_accessor :merchant_id
    end

    class Request
      def merchant_id
        Twoctwop::PaymentGateway.configuration.merchant_id
      end
    end
  end
end
