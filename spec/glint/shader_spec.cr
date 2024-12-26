require "../spec_helper"

alias Shader = Glint::Shader

Spectator.describe Shader do
  let gl_context = TestOpenGLScaffold.context

  describe "#exists?" do
    it "returns true if the shader exists" do
      shader = Shader.new(gl_context, :vertex)
      expect(shader.exists?).to be_true
    end

    it "returns false if the shader does not exist" do
      shader = Shader.new(gl_context, 0)
      expect(shader.exists?).to be_false
    end
  end
end
