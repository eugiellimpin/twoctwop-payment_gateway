module Twoctwop
  module PaymentGateway
    class PaymentRequest
      # TODO: move to configuration
      TWOCWOP_ENDPOINT     = 'https://demo2.2c2p.com/2C2PFrontEnd'
      ONETWOTHREE_ENDPOINT = 'http://uat.satuduatiga.co.id'

      def initialize(payload='')
        raise ArgumentError.new("Payload must be a string!") unless payload.is_a? String
        @payload = payload
      end

      def execute
        step = next_step

        while step
          response = step.execute

          break if step.has_payment_response?
          break if steps.empty?

          step = next_step.prepare(response)
        end

        step.try(:payment_response)
      end

      private

      def next_step
        steps.shift
      end

      def steps
        [
          { url: "#{TWOCWOP_ENDPOINT}/SecurePayment/PaymentAuth.aspx", payload: { "paymentRequest" => @payload } },
          { details: { form_id:  'paymentRequestForm', input_id: 'paymentRequest' } },
        ].map { |options| Twoctwop::PaymentGateway::RequestStep.new(options) }
      end
    end

    class OnetwothreePaymentRequest < PaymentRequest

      private

      def steps
        @steps ||= super + [
          { details: { form_id:  'ReqForm123', input_id: 'OneTwoThreeReq' } },
          { url: "#{ONETWOTHREE_ENDPOINT}/Payment/paywith123.aspx", payload: { "btnGoBack" => '' } },
          { details: { form_id:  'PostForm', input_id: 'OneTwoThreeRes' } }
        ].map { |options| Twoctwop::PaymentGateway::RequestStep.new(options) }
      end
    end
  end
end
