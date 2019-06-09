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

RSpec.describe Relaxo::Model::Document do
	include_context "model"
	
	it "should create and save document" do
		model = Invoice.create(database.current, 
			name: "Software Development"
		)
		
		expect(model.persisted?).to be_falsey
		
		database.commit(message: "Adding test model") do |dataset|
			model.save(dataset)
		end
		
		expect(model.id).to_not be nil
		expect(model.persisted?).to be_truthy
	end
	
	it "should enumerate model objects" do
		database.commit(message: "Adding test model") do |dataset|
			Invoice.insert(dataset, name: "Software Development")
			Invoice.insert(dataset, name: "Website Hosting")
			Invoice.insert(dataset, name: "Backup Services")
		end
		
		expect(Invoice.all(database.current).count).to be == 3
	end
	
	it "should have valid type" do
		expect(Invoice.type).to be == "invoice"
		expect(Invoice::Transaction.type).to be == "invoice/transaction"
	end
	
	it "should have resolved type" do
		transaction = Invoice::Transaction.create(database.current, {id: 'test'})
		
		transaction.attributes[:type] = ["Invoice", "Transaction"]
		
		expect(transaction.paths.first).to be == "Invoice/Transaction/test"
	end
	
	it "should create model indexes" do
		database.commit(message: "Adding test model") do |dataset|
			invoice = Invoice.create(dataset, name: "Software Development")
			invoice.save(dataset)
			
			transaction = Invoice::Transaction.create(dataset, date: Date.today, invoice: invoice)
			transaction.save(dataset)
		end
		
		expect(Invoice.all(database.current).count).to be == 1
		expect(Invoice::Transaction.all(database.current).count).to be == 1
		
		invoice = Invoice.all(database.current).first
		expect(invoice).to_not be nil
		
		transactions = Invoice::Transaction.by_invoice(database.current, invoice: invoice)
		expect(transactions.path).to be == "invoice/transaction/by_invoice/invoice/#{invoice.id}"
		expect(transactions).to_not be_empty
		
		transaction = transactions.first
		expect(transaction.to_s).to be == "invoice/transaction/#{transaction.id}"
	end
	
	it "can edit model objects" do
		invoice = nil
		
		database.commit(message: "Adding test model") do |dataset|
			invoice = Invoice.create(dataset, name: "Software Development")
			invoice.save(dataset)
		end
		
		# Fetch the invoice from the database:
		invoice = Invoice.fetch_all(database.current, id: invoice.id)
		invoice.name = "Software Engineering"
		
		database.commit(message: "Editing test model") do |dataset|
			invoice.save(dataset)
		end
		
		invoice = Invoice.fetch_all(database.current, id: invoice.id)
		expect(invoice.name).to be == "Software Engineering"
	end
	
	it "updates indexes correctly" do
		transaction = nil
		
		database.commit(message: "Adding test model") do |dataset|
			invoice = Invoice.create(dataset, name: "Software Development")
			invoice.save(dataset)
			
			transaction = Invoice::Transaction.create(dataset, date: Date.today, invoice: invoice)
			transaction.save(dataset)
		end
		
		transactions = Invoice::Transaction.all(database.current)
		
		database.commit(message: "Adding test model") do |dataset|
			transaction.date = Date.today - 1
			transaction.save(dataset)
		end
		
		transactions = Invoice::Transaction.all(database.current)
	end
	
	it "can query by index" do
		database.commit(message: 'Adding new users.') do |changes|
			User.insert(changes, email: 'john.doe@aol.com', name: 'John Doe')
			User.insert(changes, email: 'jane.doe@aol.com', name: 'Jane Doe')
		end
		
		expect(User.fetch_all(database.current, email: 'john.doe@aol.com').name).to be == 'John Doe'
	end
	
	it "can handle indexes with reserved characters" do
		database.commit(message: "Add new user") do |changeset|
			User.insert(changeset, email: "its@complicated.com", name: "/John/James/")
		end
		
		expect(User.fetch_all(database.current, email: 'its@complicated.com').name).to be == '/John/James/'
	end
	
	it "can handle indexes with unicode" do
		database.commit(message: "Add new user") do |changeset|
			User.insert(changeset, email: "its@complicated.com", name: "こんにちは")
		end
		
		expect(User.fetch_by_name(database.current, name: "こんにちは")).to_not be nil
	end
end
