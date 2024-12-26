require "../spec_helper"

Spectator.describe Glint::Shaders do
  let gl_context = TestOpenGLScaffold.context

  describe "#language_version" do
    let version = gl_context.language_version

    it "returns the language version" do
      expect(version).to match(/4.[5-9]0/)
    end
  end

  describe "#create_shader" do
    it "creates a shader" do
      shader = gl_context.create_shader(:vertex)
      expect(shader).to be_a(Glint::Shader)
    end
  end
end
