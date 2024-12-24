require "../spec_helper"

Spectator.describe Glint::Context do
  describe "#major_version" do
    let version = gl_context.major_version

    it "returns the major version" do
      expect(version).to eq(4)
    end
  end

  describe "#minor_version" do
    let version = gl_context.minor_version

    it "returns the minor version" do
      expect(version).to eq(6)
    end
  end
end
