# Copyright (c) 2013 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
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

module Relaxo
	module Model
		module Component
			ATTACHMENTS = '_attachments'
			DEFAULT_ATTACHMENT_CONTENT_TYPE = 'application/octet-stream'
			
			# Attach a file to the document with a given path.
			def attach(path, data, options = {})
				options[:content_type] ||= DEFAULT_ATTACHMENT_CONTENT_TYPE
				
				@database.attach(@attributes, path, data, options)
			end
			
			# Get all attachments, optionally filtering with a particular prefix path.
			def attachments(prefix = nil)
				all_attachments = (@attributes[ATTACHMENTS] || [])
				
				if prefix
					all_attachments.select{|name, attachment| name.start_with? prefix}
				else
					all_attachments
				end
			end
		end
	end
end
