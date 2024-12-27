require "opengl"

module Glint
  module TypeUtils
    def from_gl_bool(value : LibGL::Boolean) : Bool
      value != LibGL::Boolean::False
    end

    def from_gl_bool(value : LibGL::Int) : Bool
      value != LibGL::Boolean::False.value
    end

    def to_gl_bool(value : Bool) : LibGL::Boolean
      value ? LibGL::Boolean::True : LibGL::Boolean::False
    end
  end
end
