# Koti

アプリケーション起動時やCapistrano起動時にあらかじめ用意された設定ファイルの値をENVやグローバルな変数につめるためのもの

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'koti'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install koti

## Usage

```config/application.rb
Koti::BootLoader.new(
  ENV,
  [File.expand_path('../application.yml', __FILE__)],
  Rails.env
).invoke!

```

## Contributing

1. Fork it ( https://github.com/mosson/koti/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
