require "./parameters"
require "./shader"

module Glint
  module Shaders
    include Parameters

    gl_parameter language_version : String = ShadingLanguageVersion

    def create_shader(type : Shader::Type)
      Shader.new(self, type)
    end

    protected abstract def gl
  end

  class Context
    include Shaders
  end
end
