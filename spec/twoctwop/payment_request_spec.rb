require "spec_helper"

describe Twoctwop::PaymentGateway::PaymentRequest do
  subject { Twoctwop::PaymentGateway::PaymentRequest.new }

  describe '#initialize' do
    context 'no payload passed' do
      it 'assigns @payload to an empty string' do
        expect(subject.instance_variable_get(:@payload)).to eq ''
      end
    end

    context 'payload passed is not a String' do
      subject { Twoctwop::PaymentGateway::PaymentRequest.new(payload: 1) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'payload passed is a non-empty String' do
      let(:payload) { 'payload' }

      subject { Twoctwop::PaymentGateway::PaymentRequest.new(payload) }

      it 'assigns @payload correctly' do
        expect(subject.instance_variable_get(:@payload)).to eq payload
      end
    end
  end
end
