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

require 'relaxo/model/component'

require 'msgpack'

module Relaxo
	module Model
		class ValidationError < StandardError
			def initialize(document, errors)
				@document = document
				@errors = errors
				
				super "Failed to validate document #{@document} because: #{@errors.join(', ')}!"
			end
			
			attr :document
			attr :errors
		end
		
		class TypeError < StandardError
			def initialize(document)
				@document = document
				
				super "Expected type #{@document.class.type} but got #{@document.type}!"
			end
			
			attr :document
		end
		
		module Document
			TYPE = 'type'.freeze
			
			def self.included(child)
				child.send(:include, Component)
				child.send(:extend, ClassMethods)
			end
			
			module ClassMethods
				# Create a new document with a particular specified type.
				def create(dataset, properties = nil)
					instance = self.new(dataset, {TYPE => @type})

					if properties
						properties.each do |key, value|
							instance[key] = value
						end
					end

					instance.after_create

					return instance
				end
				
				def insert(dataset, properties)
					instance = self.create(dataset, properties)
					
					instance.save(dataset)
					
					return instance
				end
				
				# Fetch a record or create a model object from a hash of attributes.
				def fetch(dataset, id_or_attributes)
					if Hash === id_or_attributes
						# We were passed a hash of attributes:
						instance = self.new(dataset, id_or_attributes)
					else
						# We were passed a path/id string:
						data = dataset.read(id_or_attributes)
						instance = self.load(dataset, data)
					end

					instance.after_fetch

					return instance
				end
				
				def load(dataset, data)
					attributes = MessagePack.load(data)
					
					instance = self.new(dataset, attributes)
					
					instance.after_load
					
					return instance
				end
			end
			
			include Comparable
			
			def new_record?
				!persisted?
			end
			
			def persisted?
				self.id and @dataset.exist?(self.id)
			end
			
			def changed? key
				@changed.include? key.to_s
			end

			def type
				@attributes[TYPE]
			end

			def valid_type?
				self.type == self.class.type
			end

			# Update any calculations:
			def before_save
			end

			def after_save
			end

			# Duplicate the model object, and possibly change the dataset it is connected to. You will potentially have two objects referring to the same record.
			def dup(dataset = @dataset)
				clone = self.class.new(dataset, @attributes.dup)
				
				clone.after_fetch
				
				return clone
			end
			
			def dump
				MessagePack.dump(@attributes)
			end

			# Save the model object.
			def save(dataset)
				return if persisted? and @changed.empty?
				
				before_save

				if errors = self.validate
					return errors
				end
				
				self.flatten!
				
				dataset.write(self.id, self.dump)
				
				after_save
				
				return true
			end

			def save!(dataset)
				result = self.save(dataset)
				
				if result != true
					throw ValidationErrors.new(result)
				end
				
				return self
			end

			def reload(dataset)
				@dataset = dataset
			end

			def before_delete
			end

			def after_delete
			end

			def delete
				before_delete

				@dataset.delete(@attributes)

				after_delete
			end

			def after_load
			end

			def after_fetch
				raise TypeError.new(self) unless valid_type?
			end

			# Set any default values:
			def after_create
			end
			
			# Equality is done only on id
			def <=> other
				self.id <=> other.id if other
			end
			
			def empty?
				@attributes.empty?
			end
		end
	end
end
