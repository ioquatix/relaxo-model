
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
