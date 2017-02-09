
require 'relaxo/model'

class Invoice
	class Transaction; end
	
	include Relaxo::Model
	
	property :id, UUID
	property :number
	property :name
	
	property :date, Attribute[Date]
	
	view :all, [:type], index: [:id]
	
	def transactions
		Invoice::Transaction.by_invoice(@dataset, invoice: self)
	end
end

class Invoice::Transaction
	include Relaxo::Model
	
	property :id, UUID
	property :invoice, BelongsTo[Invoice]
	property :date, Attribute[Date]
	
	view :all, [:type], index: [:id]
	
	view :by_invoice, ['by_invoice', :invoice], index: [[:date, :id]]
end

RSpec.describe Relaxo::Model::Document do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	let(:document_path) {'test/document.json'}
	
	before(:each) {FileUtils.rm_rf(database_path)}
	
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
		
		transactions = Invoice::Transaction.by_invoice(database.current, invoice: invoice)
		expect(transactions).to_not be_empty
	end
end
