require "../spec_helper"

alias Shader = Glint::Shader

VALID_SHADER_SOURCE = <<-GLSL
void main() {
  gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
}
GLSL

INVALID_SHADER_SOURCE = <<-GLSL
void main() {
  gl_Position = vec3(0.0, 0.0, 0.0);
}
GLSL

Spectator.describe Shader do
  let gl_context = TestOpenGLScaffold.context

  describe "#initialize" do
    it "sets the attributes" do
      shader = Shader.new(gl_context, 42)
      expect(shader).to have_attributes(
        context: gl_context,
        name: 42,
      )
    end
  end

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

  describe "#delete" do
    it "deletes the shader" do
      shader = Shader.new(gl_context, :vertex)
      shader.delete
      expect(shader.exists?).to be_false
    end
  end

  describe "#deleted?" do
    it "returns true if the shader is deleted" do
      # To get into a deleted state, the shader must be in use when deleted.
      shader = Shader.new(gl_context, :vertex)
      program = Glint::Program.new(gl_context)
      program.attach(shader)
      shader.delete
      expect(shader.deleted?).to be_true
    end
  end

  describe "#type" do
    Shader::Type.each do |type|
      it "returns the shader type #{type}" do
        shader = Shader.new(gl_context, type)
        expect(shader.type).to eq(type)
      end
    end
  end

  describe "#source=" do
    it "sets the shader source" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = VALID_SHADER_SOURCE
      expect(shader.source).to eq(VALID_SHADER_SOURCE)
    end

    it "accepts multiple strings" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = VALID_SHADER_SOURCE.lines(false)
      expect(shader.source).to eq(VALID_SHADER_SOURCE)
    end
  end

  describe "#compile" do
    it "compiles the shader" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = VALID_SHADER_SOURCE
      expect(shader.compile).to be_true
    end
  end

  describe "#compile!" do
    it "compiles the shader" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = VALID_SHADER_SOURCE
      expect { shader.compile! }.not_to raise_error
    end

    it "raises an error if the shader fails to compile" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = INVALID_SHADER_SOURCE
      expect { shader.compile! }.to raise_error(Glint::ShaderCompilationError)
    end
  end

  describe "#compiled?" do
    it "returns true if the shader is compiled" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = VALID_SHADER_SOURCE
      shader.compile
      expect(shader.compiled?).to be_true
    end

    it "returns false if the shader is not compiled" do
      shader = Shader.new(gl_context, :vertex)
      expect(shader.compiled?).to be_false
    end
  end

  describe "#info_log" do
    it "returns the shader info log" do
      shader = Shader.new(gl_context, :vertex)
      shader.source = INVALID_SHADER_SOURCE
      shader.compile
      expect(shader.info_log).not_to be_empty
    end
  end

  describe "#to_unsafe" do
    it "returns the shader name" do
      shader = Shader.new(gl_context, :vertex)
      expect(shader.to_unsafe).to eq(shader.name)
    end
  end
end
