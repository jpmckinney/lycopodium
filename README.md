# Lycopodium Finds Fingerprints

[![Gem Version](https://badge.fury.io/rb/lycopodium.svg)](https://badge.fury.io/rb/lycopodium)
[![Build Status](https://secure.travis-ci.org/jpmckinney/lycopodium.png)](https://travis-ci.org/jpmckinney/lycopodium)
[![Dependency Status](https://gemnasium.com/jpmckinney/lycopodium.png)](https://gemnasium.com/jpmckinney/lycopodium)
[![Coverage Status](https://coveralls.io/repos/jpmckinney/lycopodium/badge.png)](https://coveralls.io/r/jpmckinney/lycopodium)
[![Code Climate](https://codeclimate.com/github/jpmckinney/lycopodium.png)](https://codeclimate.com/github/jpmckinney/lycopodium)

Lycopodium does two things:

1. Test what transformations you can make to a set of values without creating collisions.
1. Find [unique key](http://en.wikipedia.org/wiki/Unique_key) constraints in a data table.

> Historically, Lycopodium powder, the spores of Lycopodium and related plants, was used as a fingerprint powder. – [Wikipedia](https://en.wikipedia.org/wiki/Fingerprint_powder#Composition)

## What it tries to solve

### Find a key collision method

Let's say you have an authoritative list of names: for example, a list of organization names from a [company register](https://www.ic.gc.ca/app/scr/cc/CorporationsCanada/fdrlCrpSrch.html?locale=en_CA). You want to match a messy list of names – for example, a list of government contractors published by a city – against this authoritative list.

For context, [Open Refine](http://openrefine.org/) offers [two methods to solve this problem](https://github.com/OpenRefine/OpenRefine/wiki/Clustering-In-Depth):

* Key collision methods group names that transform into the same fingerprint; transformations include lowercasing letters, removing whitespace and punctuation, sorting words, etc.

* Nearest neighbor methods group names that are close to each other, using distance functions like [Levenshtein distance](https://en.wikipedia.org/wiki/Levenshtein_distance) and [Prediction by Partial Matching](https://en.wikipedia.org/wiki/Prediction_by_Partial_Matching).

Key collision methods tend to be fast and strict, whereas nearest neighbor methods are more likely to produce false positives, especially when dealing with short strings.

If you want fast and strict reconciliation, Lycopodium lets you figure out what transformations can be applied to an authoritative list of names without creating collisions between names. Those transformations can then be safely applied to the names on the messy list to match against the authoritative list.

### Find a unique key in a data table

Let's say you have a data table: for example, the City of Toronto publishes [voting records grouped by city councillor](http://app.toronto.ca/tmmis/getAdminReport.do?function=prepareMemberVoteReport). You want to instead group the voting records by motion being voted on. However, the data table doesn't contain one, single column identifing the motion. You instead need to identify the combination of columns that identify the motion. In other words, you are looking for the data table's [unique key](http://en.wikipedia.org/wiki/Unique_key). Lycopodium does this.

## Usage

```ruby
require 'lycopodium'
```

### Find a unique key in a data table

```ruby
table = [
  ['foo', 'bar', 'baz'],
  ['foo', 'bar', 'bzz'],
  ['foo', 'zzz', 'bzz'],
]
Lycopodium.unique_key(table)
# => [1, 2]
```

The values of the second and third columns – taken together - are unique for each row in the table. In other words, you can uniquely identify a row by taking the values of its second and third columns.

### Find a key collision method

Write a method that transforms a value, for example:

```ruby
meth1 = ->(string) do
  string.gsub(/\p{Space}/, '')
end
```

Then, initialize a `Lycopodium` instance with a set of values and the method:

```ruby
set = Lycopodium.new(["foo", "f o o", " bar "], meth1)
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

It will return the mapping from original to transformed string (hence `value_to_fingerprint`):

```ruby
set.function = meth2
set.value_to_fingerprint
# => {"foo"=>"FOO", "f o o"=>"F O O", "bar"=>" BAR "}
```

We thus learn that whitespace disambiguates between members of the set, but letter case does not.

If you can't find a suitable method, you can remove all values that collide after transformation:

```ruby
set.function = meth1
set_without_collisions = set.reject_collisions
# => [" bar "]
set_without_collisions.value_to_fingerprint
# => {" bar "=>"bar"}
```

A `Lycopodium` instance otherwise behaves as an array.

### Use the key collision method 

You can now apply the method to other values…

```ruby
messy = "\tbar\n"
fingerprint = meth1.call(messy)
# => "bar"
```

… and match against your original values:

```
fingerprint_to_value = set_without_collisions.value_to_fingerprint.invert
fingerprint_to_value.fetch(fingerprint)
# => " bar "
```

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

Copyright (c) 2013 James McKinney, released under the MIT license
