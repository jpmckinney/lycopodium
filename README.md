# Lycopodium Finds Fingerprints

[![Build Status](https://secure.travis-ci.org/opennorth/lycopodium.png)](http://travis-ci.org/opennorth/lycopodium)
[![Dependency Status](https://gemnasium.com/opennorth/lycopodium.png)](https://gemnasium.com/opennorth/lycopodium)
[![Coverage Status](https://coveralls.io/repos/opennorth/lycopodium/badge.png?branch=master)](https://coveralls.io/r/opennorth/lycopodium)
[![Code Climate](https://codeclimate.com/github/opennorth/lycopodium.png)](https://codeclimate.com/github/opennorth/lycopodium)

Test what transformations you can make to a set of unique strings without creating collisions.

> Historically, Lycopodium powder, the spores of Lycopodium and related plants, was used as a fingerprint powder. – [Wikipedia](http://en.wikipedia.org/wiki/Fingerprint_powder#Composition)

## Usage

```ruby
require 'lycopodium'
```

First, initialize the set of unique strings:

```ruby
strings = ["foo", "f o o"]
sets = Lycopodium.new(strings)
```

Then, write a method that transforms a string in order to test, for example, whether whitespace disambiguates between the members of the set:

```ruby
meth = ->(string) do
  string.gsub(/\p{Space}/, '')
end
```

```ruby
meth = lambda do |string|
  string.gsub(/\p{Space}/, '')
end
```

Or:

```ruby
meth = proc do |string|
  string.gsub(/\p{Space}/, '')
end
```

Or:

```ruby
meth = Proc.new do |string|
  string.gsub(/\p{Space}/, '')
end
```

Or:

```ruby
def func(string)
  string.gsub(/\p{Space}/, '')
end
meth = Object.method(:func)
```

Lastly, test whether the method creates collisions between the members of the set:

```ruby
sets.test(meth)
```

In this example, an exception will be raised, because the method creates collisions:

    Lycopodium::Collision: "foo", "f o o" => "foo"

With another method that, for example, uppercases a string and creates no collisions:

```ruby
sets.test(->(string){string.upcase})
```

It will return the mapping from original to transformed string:

    {"foo"=>"FOO", "f o o"=>"F O O"}

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/lycopodium](http://github.com/opennorth/lycopodium), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2012 Open North Inc., released under the MIT license
