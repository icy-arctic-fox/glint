require "./parameters"
require "./program"
require "./shader"

module Glint
  module Shaders
    include Parameters

    gl_parameter language_version : String = ShadingLanguageVersion

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
