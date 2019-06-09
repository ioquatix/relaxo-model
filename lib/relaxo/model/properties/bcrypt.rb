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

require 'bcrypt'

module Relaxo
	module Model
		module Properties
			Attribute.for_class(BCrypt::Password) do
				def convert_to_primative(value)
					unless value.is_a? BCrypt::Password
						value = BCrypt::Password.create(value)
					end
					
					[value.salt, value.checksum]
				end

				def convert_from_primative(dataset, value)
					if value.is_a? Array
						# The password is given by an array containing the salt and checksum:
						BCrypt::Password.new(value.join)
					elsif BCrypt::Password.valid_hash?(value)
						BCrypt::Password.new(value)
					else
						# Try to create a password from the supplied value:
						BCrypt::Password.create(value)
					end
				end
			end
		end
	end
end
