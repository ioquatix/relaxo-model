
require 'relaxo/model'

class Aggregate
	include Relaxo::Model
	
	property :id, UUID
	property :array_value
	property :hash_value
end

RSpec.describe Relaxo::Model::Document do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	let(:document_path) {'test/document.json'}
	
	before(:each) {FileUtils.rm_rf(database_path)}
	
	it "should create and save document" do
		model = Aggregate.create(database.current,
			array_value: [1, 2, 3],
			hash_value: {x: 10, y: 20}
		)
		
		database.commit(message: "Adding test model") do |dataset|
			model.save(dataset)
		end
		
		# Force all attributes to be reloaded from the object store:
		model.reload
		
		expect(model.array_value).to be_kind_of Array
		expect(model.hash_value).to be_kind_of Hash
	end
end
