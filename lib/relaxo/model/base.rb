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

require_relative 'recordset'

module Relaxo
	module Model
		module Base
			Key = Struct.new(:prefix, :index) do
				def resolve(key_path, model)
					key_path.collect do |component|
						case component
						when Symbol
							model.send(component)
						when Array
							resolve(component, model).join('-')
						when Proc
							model.instance_exec(&component)
						else
							component.to_s
						end
					end
				end
				
				def object_path(model)
					resolve(self.prefix + self.index, model).join('/')
				end
				
				def prefix_path(model)
					resolve(self.prefix, model).join('/')
				end
			end
			
			def self.extended(child)
				# $stderr.puts "#{self} extended -> #{child} (setup Base)"
				child.instance_variable_set(:@properties, {})
				child.instance_variable_set(:@relationships, {})
				child.instance_variable_set(:@keys, {})
				
				default_type = child.name.split('::').last.gsub(/(.)([A-Z])/,'\1_\2').downcase!
				child.instance_variable_set(:@type, default_type)
			end

			attr :type

			def metaclass
				class << self; self; end
			end

			attr :type
			attr :properties
			attr :relationships
			attr :keys
			
			def view(name, path = nil, klass: self, index: nil)
				key = Key.new(path, index)
				
				if index
					@keys[name] = key
				end
				
				self.metaclass.send(:define_method, name) do |dataset|
					Recordset.new(dataset, key.prefix_path(self), klass)
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

							@changed[name] = klass.convert_from_primative(dataset, value)
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
		end
	end
end
