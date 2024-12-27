require "./parameters"
require "./program"
require "./shader"

module Glint
  module Shaders
    include Parameters

    gl_parameter language_version : String = ShadingLanguageVersion
    private gl_parameter current_program_name : Int32 = CurrentProgram

    def current_program : Program?
      name = current_program_name
      return if name == 0
      Program.new(self, name.to_u32!)
    end

    def create_shader(type : Shader::Type) : Shader
      Shader.new(self, type)
    end

    def create_shader(type : Shader::Type, source : String) : Shader
      shader = create_shader(type)
      shader.source = source
      shader.compile!
      shader
    end

    def create_program : Program
      Program.new(self)
    end

    def create_program(*shaders : Shader) : Program
      program = create_program
      program.attach(*shaders)
      program.link!
      program
    end

    def create_program(vertex : String, fragment : String) : Program
      vertex_shader = create_shader(:vertex, vertex)
      fragment_shader = create_shader(:fragment, fragment)
      create_program(vertex_shader, fragment_shader)
    end

    protected abstract def gl
  end

  class Context
    include Shaders
  end
end
