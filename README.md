# OverallRequestTimes

[![Build Status](https://travis-ci.org/dplummer/overall_request_times.svg?branch=master)](https://travis-ci.org/dplummer/overall_request_times)

A library for recording the total time spent each request on the HTTP request
for a given service. Useful if you use several HTTP backends in each request
and want to log the total time spent in each in your Rails log, like the db
time.

Includes a [Faraday](https://github.com/lostisland/faraday) middleware and
generic implimentation.

## Threadsafety

It's got mutexes, so it might be threadsafe. No guarantees.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'overall_request_times'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install overall_request_times

## Usage

```ruby
RemoteService.connection do |conn|
  conn.use OverallRequestTimes::FaradayMiddleware, :remote_service_name
end
```

or just

```ruby
OverallRequestTimes.bm(:remote_service_name) do
  # remote service call
end
```

or

```ruby
OverallRequestTimes.start(:remote_service_name)
# this takes a while, maybe moving to a different method?
OverallRequestTimes.stop(:remote_service_name)
```

Then to extract the totals to log:

```ruby
OverallRequestTimes.total_for(:remote_service_name)
```

And reset the totals at the start of your request cycle:

```ruby
OverallRequestTimes.reset!
```

If you're using Rails, the reset call isn't needed, since there's a Railtie
that adds a middleware to do that.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake rspec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/faraday_overall_request_times.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).
