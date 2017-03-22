require "spec_helper"

describe Twoctwop::PaymentGateway::RequestStep do
  describe '#initialize' do
    let(:url)     { 'http://www.example.com' }
    let(:payload) { { some: 'stuff'} }
    let(:details) { { dem: 'details' } }

    subject do
      Twoctwop::PaymentGateway::RequestStep.new({
        url: url,
        payload: payload,
        details: details
      })
    end

    it 'assigns @url' do
      expect(subject.instance_variable_get(:@url)).to eq url
    end

    it 'assigns @payload' do
      expect(subject.instance_variable_get(:@payload)).to eq payload
    end

    it 'assigns @details' do
      expect(subject.instance_variable_get(:@details)).to eq details
    end
  end

  describe '#execute' do
    let(:response) { double("Response") }

    before do
      allow(subject).to receive(:post).and_return(response)
      allow(subject).to receive(:check_for_payment_response).with(response)
    end

    it 'calls #post' do
      expect(subject).to receive(:post)
      subject.execute
    end

    it 'calls #check_for_payment_response' do
      expect(subject).to receive(:check_for_payment_response).with(response)
      subject.execute
    end
  end

  describe '#prepare' do
    let(:html) do
      %Q(
        <form id="form_id" action="http://www.example.com" method="post">
          <input type="text" id="nextRequestPayload" value="1234567890" >
        </form>
      )
    end
    let(:response) { double("Response", body: html) }

    context 'response contains required information for next request' do
      subject { Twoctwop::PaymentGateway::RequestStep.new(details: { form_id: 'form_id', input_id: 'nextRequestPayload' }).prepare(response) }

      it 'assigns @url' do
        expect(subject.url).to eq "http://www.example.com"
      end

      it 'assigns @payload' do
        expect(subject.payload).to eq({ "nextRequestPayload" => "1234567890" })
      end

      it 'does not raise an exception' do
        expect { subject }.not_to raise_error
      end
    end

    context 'response contains required information for next request' do
      let(:html) { '<span>Life is hard</span>' }
      let(:response) { double("Response", body: html) }

      subject { Twoctwop::PaymentGateway::RequestStep.new(details: { form_id: 'form_id', input_id: 'nextRequestPayload' }).prepare(response) }

      it 'raises an exception' do
        expect { subject }.to raise_error(Twoctwop::PaymentGateway::RequestStep::Error)
      end
    end

    describe 'return value' do
      subject { Twoctwop::PaymentGateway::RequestStep.new(url: 'http://www.example.com/', payload: { pay: 'load' }) }

      it 'returns itself' do
        expect(subject.prepare(response)).to eq subject
      end
    end
  end

  describe '#check_for_payment_response' do
    let(:response) { double("Response", body: '<html/>') }

    subject { Twoctwop::PaymentGateway::RequestStep.new }

    context 'when response contains payment response' do
      let(:response) { double("Response", body: '<input id="paymentResponse" value="123" />') }

      it 'assigns @payment_response' do
        subject.send(:check_for_payment_response, response)
        expect(subject.payment_response).to eq "123"
      end
    end

    context 'when response does not contain payment response' do
      let(:response) { double("Response", body: '<input id="fakeResponse" value="123" />') }

      it 'does not assign @payment_response' do
        subject.send(:check_for_payment_response, response)
        expect(subject.payment_response).to be_nil
      end
    end

    it 'returns the original response' do
      expect(subject.send(:check_for_payment_response, response)).to eq response
    end
  end

end
