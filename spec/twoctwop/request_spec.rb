require "spec_helper"

describe Twoctwop::PaymentGateway::Request do
  subject { Twoctwop::PaymentGateway::Request.new }

  describe '#initialize' do
    context 'no parameters passed' do
      it 'assigns @parameters to an empty Hash' do
        expect(subject.instance_variable_get(:@parameters)).to be_a Hash
        expect(subject.instance_variable_get(:@parameters)).to be_empty
      end
    end

    context 'parameters passed is not a Hash' do
      subject { Twoctwop::PaymentGateway::Request.new(parameters: []) }

      it 'raises an ArgumentError' do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context 'parameters passed is a non-empty Hash' do
      let(:parameters) do
        {
          unique_transaction_code: '123',
          desc: 'Peach-Mango Pie'
        }
      end

      subject { Twoctwop::PaymentGateway::Request.new(parameters: parameters) }

      it 'assigns @parameters correctly' do
        expect(subject.instance_variable_get(:@parameters)).to eq parameters
      end
    end
  end

  describe '#execute' do
    it 'returns a Twoctwop::PaymentGateway::Response' do
      expect(subject.execute).to be_a Twoctwop::PaymentGateway::Response
    end
  end

  describe '#steps' do
    it 'returns an non-empty Array' do
      expect(subject.send(:steps)).to be_an Array
      expect(subject.send(:steps)).not_to be_empty
    end

    it 'returns an Array of Twoctwop::PaymentGateway::RequestStep'
  end
end
