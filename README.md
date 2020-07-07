# RuboCop::GraphQL

[Rubocop](https://github.com/rubocop-hq/rubocop) extension for enforcing [graphql-ruby](https://github.com/rmosolgo/graphql-ruby) best practices.

<p align="center">
  <a href="https://evilmartians.com/?utm_source=graphql-rubocop">
    <img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
  </a>
</p>

## Installation

Install the gem:

```bash
gem install rubocop-graphql
```

If you use bundler put this in your Gemfile:

```ruby
gem 'rubocop-graphql', require: false
```

## Usage

You need to tell RuboCop to load the Rails extension. There are three ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```yaml
require: rubocop-graphql
```

Alternatively, use the following array notation when specifying multiple extensions.

```yaml
require:
  - rubocop-other-extension
  - rubocop-graphql
```

Now you can run `rubocop` and it will automatically load the RuboCop Rails cops together with the standard cops.

### Command line

```sh
rubocop --require rubocop-graphql
```

### Rake task

```ruby
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-graphql'
end
```

## The Cops

All cops are located under [`lib/rubocop/cop/graphql`](lib/rubocop/cop/graphql), and contain examples and documentation.

In your `.rubocop.yml`, you may treat the Rails cops just like any other cop. For example:

```yaml
GraphQL/ResolverMethodLength:
  Max: 3
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/DmitryTsepelev/rubocop-graphql.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
