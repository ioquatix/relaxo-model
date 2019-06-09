# Copyright, 2012, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'relaxo/model/base'

module Relaxo
	module Model
		class SerializationError < RuntimeError
		end
		
		# Represents an underlying object with changes which can be persisted.
		module Component
			def self.included(child)
				# $stderr.puts "#{self} included -> #{child} extend Base"
				child.send(:extend, Base)
			end
			
			def initialize(dataset, object = nil, changed = {}, **attributes)
				@dataset = dataset
				
				# The object from the dataset:
				@object = object
				
				# Underlying attributes from the dataset:
				@attributes = attributes
				
				# Contains non-primitve attributes and changes:
				@changed = changed
			end
			
			# The dataset this document is currently bound to:
			attr :dataset
			
			# The attributes specified/loaded from the dataset:
			attr :attributes
			
			# Attributes that have been changed or de-serialized from the dataset:
			attr :changed
			
			def reload
				@changed.clear
				self.load_object
			end
			
			def clear(key)
				@changed.delete(key)
				@attributes.delete(key)
			end

			def assign(primative_attributes, only = :all)
				enumerator = primative_attributes

				if only == :all
					enumerator = enumerator.select{|key, value| self.class.properties.include? key.to_sym}
				elsif only.respond_to? :include?
					enumerator = enumerator.select{|key, value| only.include? key.to_sym}
				end

				enumerator.each do |key, value|
					key = key.to_sym

					klass = self.class.properties[key]

					if klass
						# This might raise a validation error
						value = klass.convert_from_primative(@dataset, value)
					end

					self[key] = value
				end
				
				return self
			end

			def [] name
				if self.class.properties.include? name
					self.send(name)
				else
					raise KeyError.new(name)
				end
			end

			def []= name, value
				if self.class.properties.include? name
					self.send("#{name}=", value)
				else
					raise KeyError.new(name)
				end
			end

			def validate
				# Do nothing :)
			end
			
			def to_hash
				@attributes
			end
			
			def load_object
				if @object
					attributes = MessagePack.load(@object.data, symbolize_keys: true)
					
					# We prefer existing @attributes over ones loaded from data. This allows the API to load from an object, but specify new attributes.
					@attributes = attributes.merge(@attributes)
				end
			end
			
			protected
			
			# Flatten all changes and return a serialized version of the object.
			def dump
				flatten!
				
				MessagePack.dump(@attributes)
			end
			
			# Moves values from `@changed` into `@attributes`.
			def flatten!
				self.class.properties.each do |key, klass|
					begin
						if @changed.include?(key)
							if klass
								@attributes[key] = klass.convert_to_primative(@changed.delete(key))
							else
								@attributes[key] = @changed.delete(key)
							end
						elsif !@attributes.include?(key) and klass.respond_to?(:default)
							@attributes[key] = klass.default
						end
					rescue
						raise SerializationError, "Failed to flatten #{key.inspect} of type #{klass.inspect}!"
					end
				end

				# Non-specific properties:
				@changed.each do |key, value|
					@attributes[key] = value
				end

				@changed = {}
			end
		end
	end
end
