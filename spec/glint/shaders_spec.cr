require "../spec_helper"

Spectator.describe Glint::Shaders do
  let gl_context = TestOpenGLScaffold.context

  describe "#language_version" do
    let version = gl_context.language_version

    it "returns the language version" do
      expect(version).to match(/4.[5-9]0/)
    end
  end

  describe "#current_program" do
    it "returns nil if there is no current program" do
      program = Glint::Program.new(gl_context, 0)
      program.use
      expect(gl_context.current_program).to be_nil
    end

    it "returns the current program" do
      program = gl_context.create_program
      program.link
      program.use
      expect(gl_context.current_program).to be(program)
    end
  end

  describe "#create_shader" do
    it "creates a shader" do
      shader = gl_context.create_shader(:vertex)
      expect(shader.exists?).to be_true
    end
  end

  describe "#create_program" do
    it "creates a program" do
      program = gl_context.create_program
      expect(program.exists?).to be_true
    end
  end
end
