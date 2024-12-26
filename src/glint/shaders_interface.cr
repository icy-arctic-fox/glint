require "./context"
require "./contextual"
require "./parameters"
require "./shader"

module Glint
  struct ShadersInterface
    include Contextual
    include Parameters

    gl_parameter language_version : String = ShadingLanguageVersion

    getter context : Context

    def initialize(@context : Context)
    end

    def create(type : Shader::Type)
      Shader.new(@context, type)
    end
  end

  Context.def_interface shaders : ShadersInterface
end
