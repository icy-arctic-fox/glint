require "opengl"

module Glint
  class Context
    def initialize(@delegate : Delegate)
    end

    def major_version
      major = uninitialized LibGL::Int
      gl.get_integer_v(LibGL::GetPName::MajorVersion, pointerof(major))
      major
    end

    def minor_version
      minor = uninitialized LibGL::Int
      gl.get_integer_v(LibGL::GetPName::MinorVersion, pointerof(minor))
      minor
    end

    def gl
      @delegate
    end
  end
end

require "./context/*"
