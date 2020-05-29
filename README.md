# Relaxo Model

Relaxo Model provides a framework for business logic on top of [Relaxo](https://github.com/ioquatix/relaxo), a document data store built on top of git. While it supports some traditional relational style patterns, it is primary focus is to model business processes and logic at the document level.

[![Development Status](https://github.com/ioquatix/relaxo/workflows/Development/badge.svg)](https://github.com/ioquatix/relaxo/actions?workflow=Development)

## Basic Usage

Here is a simple example of a traditional ORM style model:

```ruby
require 'relaxo/model'

database = Relaxo.connect("test")

trees = [
	{:name => 'Hinoki', :planted => Date.parse("2013/11/17")},
	{:name => 'Keyaki', :planted => Date.parse("2016/9/24")}
]

class Tree
	include Relaxo::Model
	
	property :id, UUID
	property :name
	property :planted, Attribute[Date]
	
	view :all, [:type], index: [:id]
end

database.commit(message: "Create trees") do |changeset|
	trees.each do |tree|
		Tree.insert(changeset, tree)
	end
end

database.current do |dataset|
	Tree.all(dataset).each do |tree|
		puts "A #{tree.name} was planted on #{tree.planted.to_s}."

		# Expected output:
		# A Hinoki was planted on 2013-11-17.
		# A Keyaki was planted on 2016-09-24.
	end
end
```

### Non-UUID Primary Key

```ruby
#!/usr/bin/env ruby

gem 'relaxo'

require 'relaxo/model'

database = Relaxo.connect("test")

trees = [
	{:name => 'Hinoki', :planted => Date.parse("2013/11/17")},
	{:name => 'Keyaki', :planted => Date.parse("2016/9/24")}
]

class Tree
	include Relaxo::Model

	property :name
	property :planted, Attribute[Date]

	view :all, [:type], index: [:name]
end

database.commit(message: "Create trees") do |changeset|
	trees.each do |tree|
		Tree.insert(changeset, tree)
	end
end

database.current do |dataset|
	trees.each do |tree|
		object = Tree.fetch_all(dataset, name: tree[:name])
		puts object
	end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2017, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
