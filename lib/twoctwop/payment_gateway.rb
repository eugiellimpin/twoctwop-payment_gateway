require "twoctwop/payment_gateway/version"
require "builder"

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
    # - merchant_id
    # - twoctwop endpoint
    # - onetwothree endpoint
    # - passphrase
    # - private key
    # - version

      attr_accessor :merchant_id
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

    class Payload
    # - generate a hash(?)
    # - generate XML payload
    # - return Base64 encoded string of the payload
      REQUIRED_PARAMETERS = %w[
        version
        merchantID
        uniqueTransactionCode
        desc
        amt
        currencyCode
        paymentChannel
        cardholderName
        cardholderEmail
        agentCode
        channelCode
        mobileNo
      ].freeze

      def initialize(parameters={})
      end

      def parameters
        {
          # TODO: get api_version and merchant_id from Configuration
          version:                @api_version,
          merchantID:             @merchant_id,
          uniqueTransactionCode:  @unique_transaction_code,
          desc:                   @product_description,
          amt:                    @amount,
          currencyCode:           @currency_code,
          paymentChannel:         @payment_channel,
          cardholderName:         @payer_name,
          cardholderEmail:        @payer_email,
          userDefined1:           @user_defined_1,
          userDefined2:           @user_defined_2,
          agentCode:              @agent_code,
          channelCode:            @channel_code,
          mobileNo:               @payer_mobile_number
        }.reject { |_, v| v.nil? || v.strip.empty? }
      end

      def payload
        Builder::XmlMarkup.new.PaymentRequest do |xml|
          parameters.each do |key, value|
            xml.tag!(key, value)
          end

          # TODO: use correct hash value
          xml.tag!('secureHash', "ABCD123")
        end
      end

      def generate
        Base64.strict_encode64(payload)
      end
    end
  end
end
