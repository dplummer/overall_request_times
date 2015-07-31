require 'spec_helper'

describe OverallRequestTimes::RailsMiddleware do
  let(:error) { StandardError.new('breaking through') }
  let(:app) { ->(env) { raise error } }
  subject { described_class.new(app) }

  it 'resets the timers before calling the app' do
    expect(OverallRequestTimes).to receive(:reset!)
    expect { subject.call({}) }.to raise_error(error)
  end
end
