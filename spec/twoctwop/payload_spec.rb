require "spec_helper"
require "base64"
require "nokogiri"

describe Twoctwop::PaymentGateway::Payload do
  subject { Twoctwop::PaymentGateway::Payload.new }

  describe '#initialize' do
    it 'raises an error when merchant id or version are not configured'
  end

  describe '#parameters' do
    before do
      allow(Twoctwop::PaymentGateway.configuration).to receive(:api_version).and_return('1')
      allow(Twoctwop::PaymentGateway.configuration).to receive(:merchant_id).and_return('2')
      subject.instance_variable_set(:@unique_transaction_code, '')
    end

    it 'returns a non-empty Hash' do
      expect(subject.parameters).not_to be_empty
    end

    it 'returns a compact Hash' do
      empty_values = subject.parameters.values.select do |v|
        v.nil? || v.strip.empty?
      end
      expect(empty_values).to be_empty
    end

    it 'contains all required parameters'
  end

  describe '#xml_payload' do
    let(:payload) { Twoctwop::PaymentGateway::Payload.new }
    let(:parameters) do
      {
                      version:  "1.0",
                   merchantId:  "999",
        uniqueTransactionCode:  "abc123",
                         desc:  "Awesome Product"
      }
    end

    before do
      allow(payload).to receive(:parameters).and_return(parameters)
      allow(Twoctwop::PaymentGateway.configuration).to receive(:secret_key).and_return('secret')
    end

    subject do
      Nokogiri::XML(payload.send(:xml_payload))
    end

    it 'returns a valid XML' do
      expect(subject.errors).to be_empty
    end

    it 'returns an XML with PaymentRequest as the root node' do
      # <PaymentRequest>
      #   ...
      # </PaymentRequest>
      expect(subject.xpath("/PaymentRequest").length).to eq 1
    end

    it 'returns an XML string that contains all passed parameters' do
      # <PaymentRequest>
      #   <version>1.0</version>
      #   <merchantId>999</merchantId>
      #   <uniqueTransactionCode>abc123</uniqueTransactionCode>
      #   <desc>Awesome Product</desc>
      # </PaymentRequest>
      parameters.each do |parameter, value|
        expect(subject.at_xpath("/PaymentRequest/#{parameter}").text).to eq value
      end
    end

    it 'returns an XML with "secureHash" as the last node' do
      expect(subject.xpath('/PaymentRequest/*').last.name).to eq 'secureHash'
    end

    it 'embeds request parameters hashed value into secureHash node' do
      expect(subject.xpath('/PaymentRequest/secureHash').text).to eq payload.send(:secure_hash)
    end
  end

  describe '#generate' do
    before do
      allow(subject).to receive(:xml_payload).and_return 'Test'
    end

    it 'returns a Base64 strictly encoded string' do
      expect(Base64.strict_decode64(subject.generate)).to eq 'Test'
    end
  end

  describe 'secure_hash' do
    let(:parameters) do
      {
                      version:  "1.0",
                   merchantId:  "999",
        uniqueTransactionCode:  "abc123",
                         desc:  "Awesome Product"
      }
    end
    let(:digestible) { parameters.values.join }
    let(:secret_key) { 'secret' }

    before do
      allow(subject).to receive(:parameters).and_return(parameters)
      allow(Twoctwop::PaymentGateway.configuration).to receive(:secret_key).and_return(secret_key)
      allow(OpenSSL::HMAC).to receive(:hexdigest)
        .with(OpenSSL::Digest.new('SHA1'), secret_key, digestible)
        .and_return('digested')
    end

    it 'digests the parameters' do
      expect(subject.send(:secure_hash)).to eq('digested')
    end
  end
end