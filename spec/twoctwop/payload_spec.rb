require "spec_helper"
require "base64"
require "nokogiri"

describe Twoctwop::PaymentGateway::Payload do
  subject { Twoctwop::PaymentGateway::Payload.new }

  describe '#initialize' do
    it 'raises an error when merchant id or version are not configured'
  end

  describe '#parameters' do
    it 'returns a non-empty Hash'

    it 'returns a compact Hash' do
      empty_values = subject.parameters.values.select do |v|
        v.nil? || v.strip.empty?
      end
      expect(empty_values).to be_empty
    end

    it 'contains all required parameters'
  end

  describe '#payload' do
    it 'returns an valid XML' do
      expect(Nokogiri::XML(subject.payload).errors).to be_empty
    end

    it 'returns an XML with PaymentRequest as the top-level tag'

    it 'returns an XML string that contains all passed parameters'
  end

  describe '#generate' do
    before do
      allow(subject).to receive(:payload).and_return 'Test'
    end

    it 'returns a Base64 strictly encoded string' do
      expect(Base64.strict_decode64(subject.generate)).to eq 'Test'
    end
  end
end
