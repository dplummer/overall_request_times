require 'spec_helper'

describe OverallRequestTimes::GenericTimer do
  subject { described_class.new(:cats) }

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

  describe 'start and stop timing' do
    it 'records the time it takes to do something' do
      subject.start

      Timecop.travel(Time.now + 5)

      subject.stop

      expect(subject.total).to be_within(0.01).of(5)

      Timecop.return
    end

    it 'records nothing if never started' do
      expect(subject).to_not receive(:add)
      subject.stop
    end

    it 'can only record one thing at a time' do

      subject.start

      Timecop.travel(Time.now + 5)

      subject.start

      Timecop.travel(Time.now + 7)

      subject.stop

      expect(subject.total).to be_within(0.01).of(7)

      Timecop.return
    end
  end
end
