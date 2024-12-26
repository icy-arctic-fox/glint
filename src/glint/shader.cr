require "opengl"
require "./context"
require "./contextual"

module Glint
  struct Shader
    include Contextual

    enum Type : LibGL::UInt
      Vertex   = LibGL::ShaderType::VertexShader
      Fragment = LibGL::ShaderType::FragmentShader

      def to_gl : LibGL::ShaderType
        LibGL::ShaderType.new(value)
      end
    end

    getter context : Context

    def initialize(@context : Context, @name : LibGL::UInt)
    end

    def self.new(context : Context, type : Type)
      name = context.gl.create_shader(type.to_gl)
      new(context, name)
    end

    def exists?
      gl.without_error_checking &.is_shader(@name) == LibGL::Boolean::True
    end
  end
end
