require "spec_helper"

describe Twoctwop::PaymentGateway do
  it "has a version number" do
    expect(Twoctwop::PaymentGateway::VERSION).not_to be nil
  end

  describe '#configure' do
    subject { Twoctwop::PaymentGateway.configuration }

    describe 'merchant_id' do
      context 'configured' do
        before do
          Twoctwop::PaymentGateway.configure do |config|
            config.merchant_id = 'merchant'
          end
        end

        it 'sets merchant_id' do
          expect(subject.merchant_id).to eq 'merchant'
        end
      end
    end

    describe 'secret_key' do
      context 'configured' do
        before do
          Twoctwop::PaymentGateway.configure do |config|
            config.secret_key = 'secret'
          end
        end

        it 'sets secret_key' do
          expect(subject.secret_key).to eq 'secret'
        end
      end
    end
  end
end
