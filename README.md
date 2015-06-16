# TTNT: Test This, Not That!

[![Build Status](https://travis-ci.org/Genki-S/ttnt.svg?branch=master)](https://travis-ci.org/Genki-S/ttnt)

Developing under [Google Summer of Code 2015](http://www.google-melange.com/gsoc/homepage/google/gsoc2015) with mentoring organization [Ruby on Rails](http://rubyonrails.org/).

Full proposal of this project is [here](https://github.com/Genki-S/gsoc2015/blob/master/proposal.md) (might be obsolete in some ways, read this README about this project itself rather than the proposal).

## Goal of this project

[rails/rails](https://github.com/rails/rails) has a problem that CI builds take hours to finish. This project aims to solve that problem by making it possible to run only tests related to changes introduced in target commits/branches/PRs.

### Approach

The idea is based on [Aaron Patterson](https://twitter.com/tenderlove)'s article ["Predicting Test Failures"](http://tenderlovemaking.com/2015/02/13/predicting-test-failues.html). This program uses differences in code between base commit (say, the latest commit of master branch) and target commit (say, HEAD of your feature branch) to calculate which test cases are affected by that change.

## Terminology

- test-to-code mapping
    - mapping which maps test (file name) to code (file name and line number) executed on that test run for a given commit
    - this will be used to determine tests that are affected by changes in code
- base commit
    - the commit to which the tests you should run will be calculated (e.g. the latest commit of master branch)
    - this commit should have test-to-code mapping
- target commit
    - the commit on which you want to select tests you should run (e.g. HEAD of your feature branch)
    - this commit does not have to have test-to-code mapping

## Current Status

This project is still in an early stage and we are experimenting the best approach to solve the problem.

Currently, this program does:

- Generate test-to-code mapping for a given commit
- Given base commit and target commit, output test files you should run

Limitations:

- Test selection algorithm is not perfect yet (it may produce false-positives and false-negatives)
- Only supports git
- Only supports MiniTest
- Only select test files, not fine-grained test cases
- And a lot more!

## Roadmap

Roadmap is under construction.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ttnt'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ttnt

### Define rake tasks

You can define TTNT rake tasks by following steps:

1. `require 'ttnt/testtask'`
2. Define `TTNT::TestTask` when defining `Rake::TestTask`

Your `Rakefile` will look like this:

```
require 'rake/testtask'
require 'ttnt/testtask'

Rake::TestTask.new { |t|
  t.name = 'my_test_name'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  TTNT::TestTask.new(t)
}
```

This will define 2 rake tasks `ttnt:my_test_name:anchor` and `ttnt:my_test_name:run`.
Usage for those tasks are described later in this document.

## Requirements

Developed and only tested under ruby version 2.2.1.

## Usage

### Produce test-to-code mapping for a given commit

If you defined TTNT rake task as described above, you can run following command to produce test-to-code mapping:

```
$ rake ttnt:test:anchor
```

### Select tests

If you defined TTNT rake task as described above, you can run following command to run selected tests.

```
$ rake ttnt:test:run
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Genki-S/ttnt. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

Please don't hesitate to [open a issue](https://github.com/Genki-S/ttnt/issues/new) to share your ideas for me! Any comment will be valuable especially in this early development stage.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

