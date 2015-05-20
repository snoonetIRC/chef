require 'serverspec'

set :backend, :exec

describe "InspIRCd Daemon" do
    binfile = '/home/snoonet/inspircd/bin/inspircd'
    it "has produced a compiled binary" do
        expect(file(binfile)).to be_file
        expect(file(binfile)).to be_executable
    end
end
