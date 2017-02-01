
require 'relaxo/model'

class TestModel
	include Relaxo::Model
	
	property :id, UUID
	property :name
end

RSpec.describe Relaxo::Model::Document do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	let(:document_path) {'test/document.json'}
	let(:sample_json) {'[1, 2, 3]'}
	
	before(:each) {FileUtils.rm_rf(database_path)}
	
	it "should create and save document" do
		model = TestModel.create(database.current, 
			name: "Samuel Williams"
		)
		
		database.transaction("Adding test model") do |dataset|
			model.save(dataset)
		end
		
		model.reload(database.current)
		
		expect(model.id).to_not be nil
		expect(model.persisted?).to be_truthy
	end
end
