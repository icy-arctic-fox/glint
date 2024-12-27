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

    context "with source as an argument" do
      let vertex_shader_source = <<-GLSL
      void main() {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
      }
      GLSL

      it "creates a shader from the source" do
        shader = gl_context.create_shader(:vertex, vertex_shader_source)
        expect(shader.source).to eq(vertex_shader_source)
      end

      it "compiles the shader" do
        shader = gl_context.create_shader(:vertex, vertex_shader_source)
        expect(shader.compiled?).to be_true
      end

      it "raises an error if the shader fails to compile" do
        expect { gl_context.create_shader(:vertex, "invalid") }.to raise_error(Glint::ShaderCompilationError)
      end
    end
  end

  describe "#create_program" do
    it "creates a program" do
      program = gl_context.create_program
      expect(program.exists?).to be_true
    end

    context "with shaders as arguments" do
      let vertex_shader = gl_context.create_shader(:vertex)
      let fragment_shader = gl_context.create_shader(:fragment)

      before do
        vertex_shader.source = <<-GLSL
        void main() {
          gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
        }
        GLSL

        vertex_shader.compile!
        fragment_shader.source = <<-GLSL
        void main() {
          gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
        }
        GLSL
        fragment_shader.compile!
      end

      it "creates a program from the shaders", skip: "Spectator does not support `contain_exactly`" do
        program = gl_context.create_program(vertex_shader, fragment_shader)
        expect(program.shaders).to contain_exactly(vertex_shader, fragment_shader)
      end

      it "links the program" do
        program = gl_context.create_program(vertex_shader, fragment_shader)
        expect(program.linked?).to be_true
      end

      it "raises an error if the program fails to link" do
        shader = gl_context.create_shader(:vertex)
        expect { gl_context.create_program(shader) }.to raise_error(Glint::ProgramLinkError)
      end
    end

    context "with shader sources as arguments" do
      let vertex_shader_source = <<-GLSL
      void main() {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
      }
      GLSL

      let fragment_shader_source = <<-GLSL
      void main() {
        gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
      }
      GLSL

      it "creates a program with the shader sources" do
        program = gl_context.create_program(vertex_shader_source, fragment_shader_source)
        expect(program.linked?).to be_true
      end

      it "raises an error if a shader fails to compile" do
        expect do
          gl_context.create_program("invalid", "invalid")
        end.to raise_error(Glint::ShaderCompilationError)
      end

      it "raises an error if the program fails to link" do
        # Missing `main()` in the vertex shader will cause the program to fail to link.
        vertex_shader_source = <<-GLSL
        #version 450 core
        out vec4 color;
        out vec4 tint;
        GLSL
        expect do
          gl_context.create_program(vertex_shader_source, fragment_shader_source)
        end.to raise_error(Glint::ProgramLinkError)
      end
    end
  end
end
