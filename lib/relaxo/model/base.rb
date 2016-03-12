# Copyright (c) 2012 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'relaxo/model/recordset'

module Relaxo
	module Model
		module Base
			def self.extended(child)
				# $stderr.puts "#{self} extended -> #{child} (setup Base)"
				child.instance_variable_set(:@properties, {})
				child.instance_variable_set(:@relationships, {})

				default_type = child.name.split('::').last.gsub(/(.)([A-Z])/,'\1_\2').downcase!
				child.instance_variable_set(:@type, default_type)
			end

			def metaclass
				class << self; self; end
			end

			attr :type
			attr :properties
			attr :relationships

			DEFAULT_VIEW_OPTIONS = {:include_docs => true}

			def view(name, path, *args)
				options = Hash === args.last ? args.pop : DEFAULT_VIEW_OPTIONS
				klass = args.pop || options[:class]

				self.metaclass.send(:define_method, name) do |database, query = {}|
					records = database.view(path, query.merge(options))
					Recordset.new(database, records, klass)
				end
			end

			DEFAULT_RELATIONSHIP_OPTIONS = {
				:key => lambda {|object, query| query[:key] = object.id},
				:include_docs => true
			}

			def relationship(name, path, *args, &block)
				options = Hash === args.last ? args.pop : DEFAULT_RELATIONSHIP_OPTIONS
				klass = block || args.pop || options[:class]

				@relationships[name] = options

				# This reduction returns a single result, so just provide the first row directly:
				reduction = options.delete(:reduction)

				options = options.dup

				update_key_function(options, :key)
				update_key_function(options, :startkey)
				update_key_function(options, :endkey)

				self.send(:define_method, name) do |query = {}|
					query = query.merge(options)

					[:key, :startkey, :endkey].each do |name|
						if options[name].respond_to? :call
							options[name].call(self, query)
						end
					end

					recordset = Recordset.new(@database, @database.view(path, query), klass)

					if reduction == :first
						recordset.first
					else
						recordset
					end
				end
			end

			def property(name, klass = nil)
				name = name.to_s

				@properties[name] = klass

				self.send(:define_method, name) do
					if @changed.include? name
						return @changed[name]
					elsif @attributes.include? name
						if klass
							value = @attributes[name]

							@changed[name] = klass.convert_from_primative(@database, value)
						else
							@changed[name] = @attributes[name]
						end
					else
						nil
					end
				end

				self.send(:define_method, "#{name}=") do |value|
					@changed[name] = value
				end
				
				self.send(:define_method, "#{name}?") do
					value = self.send(name)
					
					if value.nil? or !value
						false
					elsif value.respond_to? :empty?
						!value.empty?
					else
						true
					end
				end
			end
			
			private

			# Used for generating key functions for relationships - subject to change so private for now.
			def update_key_function(options, name)
				key = options[name]
				
				if key == :self
					options[name] = lambda do |object, query|
						query[name] = object.id
					end
				elsif Array === key
					index = key.index(:self)
					
					options[name] = lambda do |object, query|
						query[name] = key.dup
						query[name][index] = object.id
					end
				end
			end
		end
	end
end
