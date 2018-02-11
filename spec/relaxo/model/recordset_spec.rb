
require_relative 'model_context'

RSpec.describe Relaxo::Model::Recordset do
	include_context 'model'
	
	context "with several invoices" do
		before(:each) do
			database.commit(message: "Adding test model") do |dataset|
				@first = Invoice.insert(dataset, name: "Software Development")
				@middle = Invoice.insert(dataset, name: "Website Hosting")
				@last = Invoice.insert(dataset, name: "Backup Services")
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
