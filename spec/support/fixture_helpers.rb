def fixture_file_path(filename)
	File.join(__dir__, "../fixtures/#{filename}")
end

def read_fixture_file(filename)
  File.read fixture_file_path(filename)
end