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

  describe '#post' do
    let(:cookies)  { { type: 'chocolate chip' } }
    let(:headers)  { { 'Cookie' => 'type=chocolate chip' } }
    let(:payload)  { { pay: 'load' } }
    let(:step)     { Twoctwop::PaymentGateway::RequestStep.new(url: 'http://www.example.com/', payload: payload) }
    let(:response) { double("Response", body: '<html/>', headers: { 'Set-Cookie' => { id: '1'} }) }

    before do
      step.send(:store_cookies, cookies)
      # it uses stored cookies for step's @url
      allow(Twoctwop::PaymentGateway::RequestStep).to receive(:post).with(anything, body: payload, headers: headers).and_return(response)
    end

    after(:each) do
      Twoctwop::PaymentGateway::RequestStep.class_variable_set(:@@cookie_jar, {})
    end

    it "returns the request's response" do
      expect(step.send(:post)).to eq response
    end

    it 'saves response cookies' do
      expect(step).to receive(:store_cookies)
      step.send(:post)
    end
  end

  describe '#cookies' do
    let(:step) { Twoctwop::PaymentGateway::RequestStep.new(url: 'http://www.example.com/foo/bar/1') }
    let(:cookies) { HTTParty::CookieHash.new.add_cookies({ foo: 'foo' }) }
    let(:other_cookies) { HTTParty::CookieHash.new.add_cookies({ bar: 'bar' }) }

    after(:each) do
      Twoctwop::PaymentGateway::RequestStep.class_variable_set(:@@cookie_jar, {})
    end

    context 'there are cookies for host' do
      before do
        Twoctwop::PaymentGateway::RequestStep.class_variable_set(:@@cookie_jar, {
          'www.example.com' => cookies,
          'www.other-example.com' => other_cookies
        })
      end

      it 'returns the right cookies' do
        expect(step.send(:cookies)).to eq cookies.to_cookie_string
      end
    end

    context 'there are no cookies for host' do
      before do
        Twoctwop::PaymentGateway::RequestStep.class_variable_set(:@@cookie_jar, {
          'www.other-example.com' => other_cookies
        })
      end

      it 'returns an empty string' do
        expect(step.send(:cookies)).to be_empty
      end
    end
  end

  describe '#store_cookies' do
    let(:step) { Twoctwop::PaymentGateway::RequestStep.new(url: 'http://www.example.com/foo/bar/1') }
    let(:host) { step.send(:host) }

    after(:each) do
      Twoctwop::PaymentGateway::RequestStep.class_variable_set(:@@cookie_jar, {})
    end

    context 'there are new cookies to store' do
      let(:new_cookies) { { flavor: 'chocolate' } }

      it 'adds the new cookies to the correct host' do
        step.send(:store_cookies, new_cookies)
        expect(Twoctwop::PaymentGateway::RequestStep.class_variable_get(:@@cookie_jar)[host].to_hash).to eq new_cookies
      end
    end

    context 'there are no new cookies to store' do
      it 'does nothing' do
        step.send(:store_cookies, {})
        expect(Twoctwop::PaymentGateway::RequestStep.class_variable_get(:@@cookie_jar)).to be_empty
      end
    end
  end

  describe '#host' do
    subject { Twoctwop::PaymentGateway::RequestStep.new(url: 'http://www.example.com/foo/bar/1') }

    it "returns the host part of the step's URL" do
      expect(subject.send(:host)).to eq 'www.example.com'
    end
  end
end
