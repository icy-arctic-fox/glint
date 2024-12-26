require "../spec_helper"

Spectator.describe Glint::ShadersInterface do
  let shaders = TestOpenGLScaffold.context.shaders

  it "references the correct context" do
    expect(shaders.context).to be(TestOpenGLScaffold.context)
  end

  describe "#language_version" do
    let version = shaders.language_version

    it "returns the language version" do
      expect(version).to match(/4.[5-9]0/)
    end
  end

  describe "#create" do
    it "creates a shader" do
      shader = shaders.create(:vertex)
      expect(shader).to be_a(Glint::Shader)
    end
  end
end
