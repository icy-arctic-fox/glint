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
      Shader.new(context, name)
    end
  end
end
