module Twoctwop
  module PaymentGateway
    class Request
    # - create request steps
    # - execute request steps
    # - return Response
      def initialize(parameters: {})
        unless parameters.is_a? Hash
          raise ArgumentError.new("Parameters must be a Hash!")
        end

        @parameters = parameters
      end

      def execute
        Response.new
      end

      private

      def steps
        ['a']
      end

    end
  end
end
