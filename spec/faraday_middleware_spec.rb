require 'spec_helper'

describe OverallRequestTimes::FaradayMiddleware do
  class TestAppWithOnComplete
    attr_accessor :response_env, :do_this_before_complete

    def call(_request_env)
      self
    end

    def on_complete(&block)
      do_this_before_complete.call if do_this_before_complete
      block.call(response_env)
      self
    end
  end

  let(:app) { TestAppWithOnComplete.new }
  let(:remote_app_name) { :cats }
  let(:env) { {} }

  subject { described_class.new(app, remote_app_name) }

  it 'starts with a total of zero' do
    expect(subject.total).to eq(0)
  end

  it 'knows its name' do
    expect(subject.remote_app_name).to eq(:cats)
  end

  it 'can add some time' do
    subject.add(10)
    expect(subject.total).to eq(10)
  end

  it 'can be reset' do
    subject.add(10)
    subject.reset!
    expect(subject.total).to eq(0)
  end

  it 'registers itself with the registry' do
    allow(OverallRequestTimes).to receive(:register)
    subject
    expect(OverallRequestTimes).to have_received(:register).with(subject)
  end

  describe '#call' do
    it 'calls the app' do
      expect(app).to receive(:call).with(env).and_return(app)
      subject.call(env)
    end

    it 'records the time it takes before the call completes' do
      app.do_this_before_complete = -> {
        Timecop.travel(Time.now + 5)
      }

      subject.call(env)

      expect(subject.total).to be_within(0.01).of(5)

      Timecop.return
    end

    it 'increments the counter on the number of calls made' do
      app.do_this_before_complete = -> {
        1 + 1
      }

      subject.call(env)
      subject.call(env)
      subject.call(env)

      expect(subject.call_count).to eq(3)
    end
  end
end
