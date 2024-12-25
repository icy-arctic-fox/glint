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
      expect(version).to be >= 5
    end
  end

  describe "#vendor" do
    let vendor = gl_context.vendor

    it "returns the vendor" do
      expect(vendor).to match(/Intel|NVIDIA|AMD|ATI|Mesa|Software|VMware|Radeon/i)
    end
  end

  describe "#renderer" do
    let renderer = gl_context.renderer

    it "returns the renderer" do
      expect(renderer).to match(/Intel|NVIDIA|AMD|ATI|Mesa|Software|LLVM|VMware|Radeon/i)
    end
  end

  describe "#version" do
    let version = gl_context.version

    it "returns the version" do
      expect(version).to match(/4\.[5-9]/)
    end
  end
end
