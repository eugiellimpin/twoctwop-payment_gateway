require "twoctwop/payment_gateway/version"

module Twoctwop
  module PaymentGateway
    class << self
      attr_accessor :configuration
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    class Configuration
    # - merchant_id
    # - twoctwop endpoint
    # - onetwothree endpoint
    # - passphrase
    # - private key
    # - version

      attr_accessor :merchant_id, :secret_key
    end

    class Request
    # - accept a payload
    # - create request steps
    # - execute request steps
    # - return Response

      def merchant_id
        Twoctwop::PaymentGateway.configuration.merchant_id
      end
    end

    # RequestStep
    #

    # Response
    # - decrypts paymentResponse
    # - transform XML paymentResponse to a Hash with snake case keys

  end
end
