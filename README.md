# Lycopodium Finds Fingerprints

[![Build Status](https://secure.travis-ci.org/opennorth/lycopodium.png)](http://travis-ci.org/opennorth/lycopodium)
[![Dependency Status](https://gemnasium.com/opennorth/lycopodium.png)](https://gemnasium.com/opennorth/lycopodium)
[![Coverage Status](https://coveralls.io/repos/opennorth/lycopodium/badge.png?branch=master)](https://coveralls.io/r/opennorth/lycopodium)
[![Code Climate](https://codeclimate.com/github/opennorth/lycopodium.png)](https://codeclimate.com/github/opennorth/lycopodium)

Test what transformations you can make to a set of values without creating collisions.

> Historically, Lycopodium powder, the spores of Lycopodium and related plants, was used as a fingerprint powder. – [Wikipedia](http://en.wikipedia.org/wiki/Fingerprint_powder#Composition)

## Usage

```ruby
require 'lycopodium'
```

First, write a method that transforms a value, for example:

```ruby
meth1 = ->(string) do
  string.gsub(/\p{Space}/, '')
end
```

Then, initialize a `Lycopodium` instance with a set of values and the transformation method:

```ruby
set = Lycopodium.new(["foo", "f o o"], meth1)
```

Lastly, test whether the method creates collisions between the members of the set:

```ruby
set.value_to_fingerprint
```

In this example, an exception will be raised, because the method creates collisions:

    Lycopodium::Collision: "foo", "f o o" => "foo"

With another method that, for example, uppercases a string and creates no collisions:

```ruby
meth2 = ->(string) do
  string.upcase
end
```

It will return the mapping from original to transformed string:

    {"foo" => "FOO", "f o o" => "F O O"}

We thus learn that whitespace disambiguates between members of the set, but letter case does not.

To remove all members of the set that collide after transformation, run:

```ruby
set_without_collisions = set.reject_collisions
```

A `Lycopodium` instance otherwise behaves as an array.

## Method definition

Besides the `->` syntax above, you can define the same method as:

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

Or even:

```ruby
def func(string)
  string.gsub(/\p{Space}/, '')
end
meth = Object.method(:func)
```

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/lycopodium](http://github.com/opennorth/lycopodium), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
