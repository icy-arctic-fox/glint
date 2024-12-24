require "opengl"
require "./parameters"

module Glint
  class Context
    include Parameters

    gl_parameter major_version : Int32 = MajorVersion
    gl_parameter minor_version : Int32 = MinorVersion

    def initialize(@delegate : Delegate)
    end

    def gl
      @delegate
    end
  end
end

require "./context/*"
