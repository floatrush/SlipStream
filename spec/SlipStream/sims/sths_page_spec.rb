require 'support/fixture_helpers'

RSpec.describe Sims::SthsPage do
	subject { Sims::SthsPage }
	let(:sample_url)	{ "does_not_matter.html" }
	let(:valid_game) { read_fixture_file("sample_game.html") }
	let(:invalid_game_no_body) { read_fixture_file("invalid_game_no_body.html") }
	let(:invalid_game_no_head) { read_fixture_file("invalid_game_no_head.html") }

	it "can open the sample Sths Page" do
		expect_any_instance_of(subject).to receive(:open).with(sample_url).and_return(valid_game)
		
		object_under_test = subject.new(sample_url)
	end

	it "validates that the game has a Body" do
		expect_any_instance_of(subject).to receive(:open).with(sample_url).and_return(invalid_game_no_body)
		
		expect{subject.new(sample_url)}.to raise_error ArgumentError
	end

	it "validates that the game has a Head" do
		expect_any_instance_of(subject).to receive(:open).with(sample_url).and_return(invalid_game_no_head)
		
		expect{subject.new(sample_url)}.to raise_error ArgumentError
	end
end