require "../spec_helper"

private struct TestTypeUtils
  include Glint::TypeUtils
end

Spectator.describe Glint::TypeUtils do
  let type_utils = TestTypeUtils.new

  describe "#from_gl_bool" do
    it "returns true if the value is true" do
      value = type_utils.from_gl_bool(LibGL::Boolean::True)
      expect(value).to be_true
    end

    it "returns false if the value is false" do
      value = type_utils.from_gl_bool(LibGL::Boolean::False)
      expect(value).to be_false
    end

    it "returns true if the value is 1" do
      value = type_utils.from_gl_bool(LibGL::Int.new(1))
      expect(value).to be_true
    end

    it "returns false if the value is 0" do
      value = type_utils.from_gl_bool(LibGL::Int.new(0))
      expect(value).to be_false
    end
  end
end
