# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'model_context'

RSpec.describe Relaxo::Model::Recordset do
	include_context 'model'
	
	context "with several invoices" do
		before(:each) do
			database.commit(message: "Adding test model") do |dataset|
				@first = Invoice.insert(dataset, id: "a", name: "Software Development")
				@middle = Invoice.insert(dataset, id: "b", name: "Website Hosting")
				@last = Invoice.insert(dataset, id: "c", name: "Backup Services")
			end
		end
		
		it "should have a first and last invoice" do
			recordset = Invoice.all(database.current)
			
			expect(recordset.count).to be == 3
			expect(recordset).to_not be_empty
			
			expect(recordset.first).to be == @first
			expect(recordset.last).to be == @last
		end
	end
end
