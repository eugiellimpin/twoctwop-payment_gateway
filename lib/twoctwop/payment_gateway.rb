require "twoctwop/payment_gateway/payload"
require "twoctwop/payment_gateway/payment_request"
require "twoctwop/payment_gateway/request_step"
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

      attr_accessor :api_version,
                    :merchant_id,
                    :secret_key,
                    :public_key,
                    :private_key,
                    :passphrase
    end

    class Response
      Error = Class.new(StandardError)

      def initialize(payment_response='')
        @payment_response = payment_response
      end

      def params
        {}.tap do |params|
          Hash.from_xml(payment_response)["PaymentResponse"].each do |key, value|
            params[key.underscore] = value unless value.blank?
          end
        end
      end

      private

      def payment_response
        col = 64
        encrypted = @payment_response.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/, "\\1\\3\n")
        encrypted = "-----BEGIN PKCS7-----\n" + encrypted + "-----END PKCS7-----"

        OpenSSL::X509::Store.new.add_cert(public_key)
        OpenSSL::PKCS7.new(encrypted).decrypt(private_key, public_key)
      end

      def public_key
        public_key = Twoctwop::PaymentGateway.configuration.public_key
        OpenSSL::X509::Certificate.new(public_key)
      rescue OpenSSL::X509::CertificateError => e
        raise Error.new("Could not create public key certificate")
      end

      def private_key
        private_key = Twoctwop::PaymentGateway.configuration.private_key
        passphrase = Twoctwop::PaymentGateway.configuration.passphrase
        OpenSSL::PKey::RSA.new(private_key, passphrase)
      rescue OpenSSL::PKey::RSAError => e
        raise Error.new("Could not create private key")
      end
    end

  end
end
