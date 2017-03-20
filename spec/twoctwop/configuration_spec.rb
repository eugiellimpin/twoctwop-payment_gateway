require "spec_helper"

describe Twoctwop::PaymentGateway::Configuration do
  subject { Twoctwop::PaymentGateway::Configuration.new }

  describe '#merchant_id' do
    context 'supplied' do
      it 'does not raise an exception'
    end

    context 'not supplied' do
      it 'raises an exception'
    end
  end

  describe '#secret_key' do
    context 'supplied' do
      it 'does not raise an exception'
    end

    context 'not supplied' do
      it 'raises an exception'
    end
  end
end
