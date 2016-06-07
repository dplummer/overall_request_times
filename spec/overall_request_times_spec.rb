require 'spec_helper'

describe OverallRequestTimes do
  before(:each) do
    OverallRequestTimes.wipeout_registry
  end

  after(:each) do
    Timecop.return
  end

  it 'has a version number' do
    expect(OverallRequestTimes::VERSION).not_to be nil
  end

  it 'starts with an empty registry' do
    expect(OverallRequestTimes.registry).to be_a(OverallRequestTimes::Registry)
    expect(OverallRequestTimes.registry.size).to eq(0)
  end

  describe '.wipeout_registry' do
    it 'clears the registry' do
      timer = double('timer', remote_app_name: :cats)
      OverallRequestTimes.register(timer)
      expect(OverallRequestTimes.registry.size).to eq(1)
      OverallRequestTimes.wipeout_registry
      expect(OverallRequestTimes.registry.size).to eq(0)
    end
  end

  describe '.register' do
    it 'holds onto the timer by the app name' do
      timer = double('timer', remote_app_name: :cats, total: 12)
      OverallRequestTimes.register(timer)
      expect(OverallRequestTimes.registry.total_for(:cats)).to eq(12)
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

  describe '.totals' do
    it 'returns a hash of the total for each timer' do
      timer = double('timer', remote_app_name: :cats, total: 101)
      OverallRequestTimes.register(timer)
      timer = double('timer', remote_app_name: :dogs, total: 106)
      OverallRequestTimes.register(timer)

      expect(OverallRequestTimes.totals).to eq(cats: 101, dogs: 106)
    end

    it "returns no times if there are no registered timers" do
      expect(OverallRequestTimes.totals).to eq({})
    end
  end

  describe '.bm' do
    it 'benchmarks a block' do
      OverallRequestTimes.bm(:cats) do
        Timecop.travel(Time.now + 5)
      end

      OverallRequestTimes.bm(:cats) do
        Timecop.travel(Time.now + 7)
      end

      expect(OverallRequestTimes.total_for(:cats)).to be_within(0.01).of(12)
    end

    it 'records the timing even if the code explodes' do
      error = StandardError.new('blowing up')

      expect do
        OverallRequestTimes.bm(:cats) do
          Timecop.travel(Time.now + 5)
          raise error
        end
      end.to raise_error(error)

      expect(OverallRequestTimes.total_for(:cats)).to be_within(0.01).of(5)
    end
  end

  describe '.start and .stop' do
    it 'records for a app, creating one if needed' do
      OverallRequestTimes.start(:cats)
      Timecop.travel(Time.now + 5)
      OverallRequestTimes.stop(:cats)

      expect(OverallRequestTimes.total_for(:cats)).to be_within(0.01).of(5)
    end

    it "does not complain if it wasn't started" do
      expect(OverallRequestTimes.stop(:dogs)).to eq(nil)
    end

    it 'works with existing registered timers' do
      timer = OverallRequestTimes::GenericTimer.new(:cats)
      OverallRequestTimes.register(timer)

      OverallRequestTimes.start(:cats)
      Timecop.travel(Time.now + 5)
      OverallRequestTimes.stop(:cats)

      expect(timer.total).to be_within(0.01).of(5)
    end
  end

  describe '.add_duration' do
    it 'records the duration' do
      OverallRequestTimes.add_duration(:cats, 123)
      expect(OverallRequestTimes.total_for(:cats)).to be_within(0.01).of(123)
    end
  end
end
