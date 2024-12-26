require "./context"
require "./contextual"
require "./parameters"

module Glint
  struct ShadersInterface
    include Contextual
    include Parameters

    getter context : Context

    def initialize(@context : Context)
    end

    gl_parameter language_version : String = ShadingLanguageVersion
  end

  Context.def_interface shaders : ShadersInterface
end
