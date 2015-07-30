require 'spec_helper'

describe OverallRequestTimes do
  before(:each) do
    OverallRequestTimes.wipeout_registry
  end

  it 'has a version number' do
    expect(OverallRequestTimes::VERSION).not_to be nil
  end

  it 'starts with an empty registry' do
    expect(OverallRequestTimes.registry).to eq({})
  end

  describe '.wipeout_registry' do
    it 'clears the registry' do
      expect(OverallRequestTimes.registry).to eq({})
      timer = double('timer', remote_app_name: :cats)
      OverallRequestTimes.register(timer)
      expect(OverallRequestTimes.registry).to eq(cats: timer)
      OverallRequestTimes.wipeout_registry
      expect(OverallRequestTimes.registry).to eq({})
    end
  end

  describe '.register' do
    it 'holds onto the timer by the app name' do
      timer = double('timer', remote_app_name: :cats)
      OverallRequestTimes.register(timer)
      expect(OverallRequestTimes.registry[:cats]).to eq(timer)
    end
  end

  describe '.reset!' do
    it 'resets each timer' do
      timer = double('timer', remote_app_name: :cats, reset!: nil)
      OverallRequestTimes.register(timer)
      expect(timer).to receive(:reset!)
      OverallRequestTimes.reset!
    end
  end

  describe '.total_for' do
    it 'gets the total from timer' do
      timer = double('timer', remote_app_name: :cats, total: 101)
      OverallRequestTimes.register(timer)
      expect(OverallRequestTimes.total_for(:cats)).to eq(101)
    end

    it "returns zero if there's no timer by that name" do
      expect(OverallRequestTimes.total_for(:nope)).to eq(0)
    end
  end
end
