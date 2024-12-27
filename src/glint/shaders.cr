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

    def create_program : Program
      Program.new(self)
    end

    protected abstract def gl
  end

  class Context
    include Shaders
  end
end
