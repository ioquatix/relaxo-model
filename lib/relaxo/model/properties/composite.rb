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

module Relaxo
	module Model
		module Properties
			
			class Polymorphic
				def self.[] *klasses
					self.new(klasses)
				end
				
				def initialize(klasses)
					@klasses = klasses
					@lookup = nil
				end
				
				def lookup(type)
					unless @lookup
						@lookup = {}
						
						@klasses.each do |klass|
							@lookup[klass.type] = klass
						end
					end
					
					@lookup[type]
				end
				
				def convert_to_primative(object)
					unless object.saved?
						object.save
					end

					[object.type, object.id]
				end

				def convert_from_primative(dataset, reference)
					# Legacy support for old polymorphic types - to remove.
					if Array === reference
						type, id = reference
					else
						id = reference
					end
					
					attributes = dataset.get(id).to_hash
					
					klass = lookup(attributes['type'])
					
					klass.fetch(dataset, attributes)
				end
			end

			class BelongsTo
				def self.[] *klasses
					if klasses.size == 1
						self.new(klasses[0])
					else
						Polymorphic.new(klasses)
					end
				end
			
				def initialize(klass)
					@klass = klass
				end

				def convert_to_primative(object)
					unless object.saved?
						object.save
					end

					object.id
				end

				def convert_from_primative(dataset, id)
					@klass.fetch(dataset, id)
				end
			end
		
			class HasOne < BelongsTo
			end
		
			class HasMany < HasOne
				def convert_to_primative(value)
					value.each do |document|
						document.save unless document.saved?
					end
				
					value.collect{|document| document.id}
				end

				def convert_from_primative(dataset, value)
					value.collect{|id| @klass.fetch(dataset, id)}
				end
			end
			
			# Returns the raw value, typically used for reductions:
			module ValueOf
				def self.new(dataset, value)
					value
				end
			end
			
			class ArrayOf
				def self.[] klass
					self.new(klass)
				end
				
				def initialize(klass)
					@klass = Attribute.new(klass)
				end

				def convert_to_primative(value)
					value.collect do |item|
						@klass.convert_to_primative(item)
					end
				end

				def convert_from_primative(dataset, value)
					value.collect do |item|
						@klass.convert_from_primative(dataset, item)
					end
				end
			end
		end
	end
end
