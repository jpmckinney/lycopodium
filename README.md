# Lycopodium Finds Fingerprints

[![Gem Version](https://badge.fury.io/rb/lycopodium.svg)](http://badge.fury.io/rb/lycopodium)
[![Build Status](https://secure.travis-ci.org/opennorth/lycopodium.png)](http://travis-ci.org/opennorth/lycopodium)
[![Dependency Status](https://gemnasium.com/opennorth/lycopodium.png)](https://gemnasium.com/opennorth/lycopodium)
[![Coverage Status](https://coveralls.io/repos/opennorth/lycopodium/badge.png?branch=master)](https://coveralls.io/r/opennorth/lycopodium)
[![Code Climate](https://codeclimate.com/github/opennorth/lycopodium.png)](https://codeclimate.com/github/opennorth/lycopodium)

Test what transformations you can make to a set of values without creating collisions.

> Historically, Lycopodium powder, the spores of Lycopodium and related plants, was used as a fingerprint powder. – [Wikipedia](http://en.wikipedia.org/wiki/Fingerprint_powder#Composition)

## What it tries to solve

Let's say you have an authoritative list of names: for example, a list of organization names from a [company register](https://www.ic.gc.ca/app/scr/cc/CorporationsCanada/fdrlCrpSrch.html?locale=en_CA). You want to match a messy list of names – for example, a list of government contractors published by a city – against this authoritative list.

For context, [Open Refine](http://openrefine.org/) offers [two methods to solve this problem](https://github.com/OpenRefine/OpenRefine/wiki/Clustering-In-Depth):

* Key collision methods group together names that transform into the same fingerprint; transformations include lowercasing letters, removing whitespace and punctuation, sorting words, etc.

* Nearest neighbor methods group together names that are close to each other, using distance functions like [Levenshtein distance](http://en.wikipedia.org/wiki/Levenshtein_distance) and [Prediction by Partial Matching](http://en.wikipedia.org/wiki/Prediction_by_Partial_Matching).

Key collision methods tend to be fast and strict.

If your use case requires fast and strict reconciliation, Lycopodium lets you figure out what transformations can be applied to a list of names without creating collisions between names. Those transformations can then be safely applied to the names on the messy list to match against the authoritative list.

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

### Method definition

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

## Related projects

* [Nomenklatura](http://nomenklatura.okfnlabs.org/) is a web service to maintain a canonical list of entities and to match messy input against it, either via the user interface or via Open Refine reconciliation.
* [dedupe](https://github.com/open-city/dedupe) is a Python library to determine when two records are about the same thing.
* [name-cleaver](https://github.com/sunlightlabs/name-cleaver) is a Python library to parse and standardize the names of people and organizations.

## Bugs? Questions?

This project's main repository is on GitHub: [http://github.com/opennorth/lycopodium](http://github.com/opennorth/lycopodium), where your contributions, forks, bug reports, feature requests, and feedback are greatly welcomed.

Copyright (c) 2013 Open North Inc., released under the MIT license
