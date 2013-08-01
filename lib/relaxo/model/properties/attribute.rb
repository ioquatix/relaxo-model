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

require 'date'

module Relaxo
	module Model
		module Properties
			# Handle conversions for standard datatypes.
			class Attribute
				@@attributes = {}

				def self.for_class(klass, &block)
					@@attributes[klass] = Proc.new(&block)
				end

				def self.[] (klass, proc = nil)
					self.new(klass, &proc)
				end

				def initialize(klass, &serialization)
					@klass = klass

					if block_given?
						self.instance_eval &serialization
					else
						self.instance_eval &@@attributes[klass]
					end
				end
			end
		
			class Serialized
				def self.[] (klass, proc = nil)
					self.new(klass, &proc)
				end
				
				def initialize(klass, &serialization)
					@klass = klass
					
					raise ArgumentError.new("Klass doesn't respond to parse!") unless @klass.respond_to? :parse
				end
				
				def convert_to_primative(value)
					value.to_s
				end
				
				def convert_from_primative(database, value)
					@klass.parse(value)
				end
			end
		
			Required = Attribute
		
			class Optional
				def self.[] klass
					self.new(klass)
				end

				def initialize(klass)
					@klass = klass
				end
			
				def convert_to_primative(value)
					if value == nil || value == ''
						nil
					else
						@klass.convert_to_primative(value)
					end
				end

				def convert_from_primative(database, value)
					if value == nil || value.empty?
						nil
					else
						@klass.convert_from_primative(database, value)
					end
				end
			end
		
			class Boolean
			end
		
			Attribute.for_class(Boolean) do
				def convert_to_primative(value)
					value ? true : false
				end

				def convert_from_primative(database, value)
					[true, "on", "true"].include?(value)
				end
			end
		
			Attribute.for_class(Integer) do
				def convert_to_primative(value)
					value.to_i
				end

				def convert_from_primative(database, value)
					value.to_i
				end
			end
		
			Attribute.for_class(Float) do
				def convert_to_primative(value)
					value.to_f
				end

				def convert_from_primative(database, value)
					value.to_f
				end
			end

			Attribute.for_class(Date) do
				def convert_to_primative(value)
					value.iso8601
				end

				def convert_from_primative(database, value)
					Date.parse(value)
				end
			end

			Attribute.for_class(DateTime) do
				def convert_to_primative(value)
					value.iso8601
				end

				def convert_from_primative(database, value)
					DateTime.parse(value)
				end
			end

			Attribute.for_class(String) do
				def convert_to_primative(value)
					value.to_s
				end

				def convert_from_primative(database, value)
					value.to_s
				end
			end
		end
	end
end
