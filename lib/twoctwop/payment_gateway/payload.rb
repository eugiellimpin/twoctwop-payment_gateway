require "builder"

module Twoctwop
  module PaymentGateway
    class Payload
      def initialize(parameters={})
        @agent_code              = parameters[:agent_code]
        @amount                  = parameters[:amount]
        @channel_code            = parameters[:channel_code]
        @currency_code           = parameters[:currency_code]
        @payer_email             = parameters[:payer_email]
        @payer_mobile_number     = parameters[:payer_mobile_number]
        @payer_name              = parameters[:payer_name]
        @payment_channel         = parameters[:payment_channel]
        @product_description     = parameters[:product_description]
        @unique_transaction_code = parameters[:unique_transaction_code]
        @user_defined1           = parameters[:user_defined1]
        @user_defined2           = parameters[:user_defined2]
      end

      def parameters
        {
          version:                Twoctwop::PaymentGateway.configuration.api_version,
          merchantID:             Twoctwop::PaymentGateway.configuration.merchant_id,
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

      def generate
        Base64.strict_encode64(xml_payload)
      end

      private

      def xml_payload
        Builder::XmlMarkup.new.PaymentRequest do |xml|
          parameters.each do |key, value|
            xml.tag!(key, value)
          end

          xml.tag!('secureHash', secure_hash)
        end
      end

      def secure_hash
        value = parameters.values.join
        key = Twoctwop::PaymentGateway.configuration.secret_key
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('SHA1'), key, value)
      end
    end
  end
end
