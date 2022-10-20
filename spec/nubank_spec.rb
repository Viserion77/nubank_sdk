RSpec.describe Nubank do
  it "has a version number" do
    expect(Nubank::VERSION).not_to be nil
  end

  context "when validating connection" do
    it "is connected" do
      expect(Nubank::Connection.new).to be_connected
    end
  end
end
