require "../spec_helper"

alias Program = Glint::Program

Spectator.describe Program do
  let gl_context = TestOpenGLScaffold.context

  let vertex_shader = Glint::Shader.new(gl_context, :vertex)
  let fragment_shader = Glint::Shader.new(gl_context, :fragment)

  before do
    vertex_shader.source = <<-GLSL
    void main() {
      gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
    }
    GLSL

    fragment_shader.source = <<-GLSL
    void main() {
      gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
    GLSL

    vertex_shader.compile!
    fragment_shader.compile!
  end

  after do
    vertex_shader.delete
    fragment_shader.delete
  end

  describe "#initialize" do
    it "sets the attributes" do
      program = Program.new(gl_context)
      expect(program).to have_attributes(
        context: gl_context,
        name: program.name,
      )
    end
  end

  describe "#exists?" do
    it "returns true if the program exists" do
      program = Program.new(gl_context)
      expect(program.exists?).to be_true
    end

    it "returns false if the program does not exist" do
      program = Program.new(gl_context, 0)
      expect(program.exists?).to be_false
    end
  end

  describe "#delete" do
    it "deletes the program" do
      program = Program.new(gl_context)
      program.delete
      expect(program.exists?).to be_false
    end
  end

  describe "#link" do
    it "links the program" do
      program = Program.new(gl_context)
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link
      expect(program.linked?).to be_true
    end
  end

  describe "#link!" do
    it "links the program" do
      program = Program.new(gl_context)
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      expect { program.link! }.not_to raise_error
    end

    it "raises an error if the program fails to link" do
      shader = Glint::Shader.new(gl_context, :vertex)
      program = Program.new(gl_context)
      program.attach(shader) # Not compiled, will fail to link.
      expect { program.link! }.to raise_error(Glint::ProgramLinkError)
    end
  end

  describe "#linked?" do
    it "returns true if the program is linked" do
      program = Program.new(gl_context)
      program.attach(vertex_shader)
      program.attach(fragment_shader)
      program.link
      expect(program.linked?).to be_true
    end

    it "returns false if the program is not linked" do
      program = Program.new(gl_context)
      expect(program.linked?).to be_false
    end
  end

  describe "#info_log" do
    it "returns the program info log" do
      shader = Glint::Shader.new(gl_context, :vertex)
      program = Program.new(gl_context)
      program.attach(shader) # Not compiled, will fail to link.
      program.link
      expect(program.info_log).not_to be_empty
    end
  end

  describe "#to_unsafe" do
    it "returns the program name" do
      program = Program.new(gl_context)
      expect(program.to_unsafe).to eq(program.name)
    end
  end
end