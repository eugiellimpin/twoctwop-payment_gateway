require "spec_helper"

describe Twoctwop::PaymentGateway::Configuration do
  subject { Twoctwop::PaymentGateway::Configuration.new }

  describe '#merchant_id' do
    it 'defaults to nil' do
      expect(subject.merchant_id).to be_nil
    end
  end

  describe '#merchant_id=' do
    it 'sets @merchant_id' do
      subject.merchant_id = 'merchant123'
      expect(subject.merchant_id).to eq 'merchant123'
    end
  end
end
