require "./context"
require "./contextual"
require "./parameters"

module Glint
  struct ShadersInterface
    include Contextual
    include Parameters

    gl_parameter language_version : String = ShadingLanguageVersion

    getter context : Context

    def initialize(@context : Context)
    end
  end

  Context.def_interface shaders : ShadersInterface
end