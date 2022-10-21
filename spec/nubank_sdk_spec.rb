RSpec.describe NubankSdk do
  it "has a version number" do
    expect(NubankSdk::VERSION).not_to be nil
  end

  context "when validating connection" do
    it "is connected" do
      expect(Nubank::Connection.new).to be_connected
    end
  end
end
