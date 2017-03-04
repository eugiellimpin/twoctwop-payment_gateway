require "spec_helper"

describe Twoctwop::PaymentGateway do
  it "has a version number" do
    expect(Twoctwop::PaymentGateway::VERSION).not_to be nil
  end

  describe '#configure' do
    subject { Twoctwop::PaymentGateway::Request.new }

    describe 'merchant_id' do
      context 'configured' do
        before do
          Twoctwop::PaymentGateway.configure do |config|
            config.merchant_id = 'merchant123'
          end
        end

        it 'sets merchant_id' do
          expect(subject.merchant_id).to eq 'merchant123'
        end

        it 'does not raise an error'
      end

      context 'not configured' do
        it 'raises an error'
      end
    end
  end
end
