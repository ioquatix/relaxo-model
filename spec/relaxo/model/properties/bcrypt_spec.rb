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

require_relative '../model_context'

RSpec.describe Relaxo::Model::Properties do
	context BCrypt::Password do
		include_context "model"
		
		it "can set password string" do
			database.commit(message: "Add new user") do |changeset|
				User.insert(changeset, email: "its@complicated.com", name: "Bob", password: "foobar")
			end
			
			bob = User.fetch_by_name(database.current, name: "Bob")
			expect(bob).to_not be nil
			
			expect(bob.password == "foobar").to be_truthy
		end
		
		it "can set password instance" do
			database.commit(message: "Add new user") do |changeset|
				User.insert(changeset, email: "its@complicated.com", name: "Bob", password: BCrypt::Password.create("foobar"))
			end
			
			bob = User.fetch_by_name(database.current, name: "Bob")
			expect(bob).to_not be nil
			
			expect(bob.password == "foobar").to be_truthy
		end
		
		it "can assign password string" do
			database.commit(message: "Add new user") do |changeset|
				user = User.insert(changeset, email: "its@complicated.com", name: "Bob")
				
				user.assign(password: "foobar")
				
				user.save(changeset)
			end
			
			bob = User.fetch_by_name(database.current, name: "Bob")
			expect(bob).to_not be nil
			
			expect(bob.password == "foobar").to be_truthy
		end
		
		it "can assign password hash" do
			password = BCrypt::Password.create("foobar")
			
			database.commit(message: "Add new user") do |changeset|
				user = User.insert(changeset, email: "its@complicated.com", name: "Bob")
				
				user.assign(password: password.to_s)
				
				user.save(changeset)
			end
			
			bob = User.fetch_by_name(database.current, name: "Bob")
			expect(bob).to_not be nil
			
			expect(bob.password == "foobar").to be_truthy
		end
	end
end
