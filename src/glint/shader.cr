require "opengl"
require "./context"
require "./contextual"
require "./errors"
require "./type_utils"

module Glint
  struct Shader
    include Contextual
    include TypeUtils

    enum Type : LibGL::UInt
      Vertex   = LibGL::ShaderType::VertexShader
      Fragment = LibGL::ShaderType::FragmentShader

      def to_gl : LibGL::ShaderType
        LibGL::ShaderType.new(value)
      end
    end

    getter context : Context
    getter name : LibGL::UInt

    def initialize(@context : Context, @name : LibGL::UInt)
    end

    def self.new(context : Context, type : Type)
      name = context.gl.create_shader(type.to_gl)
      new(context, name)
    end

    def exists?
      gl.without_error_checking &.is_shader(@name) == LibGL::Boolean::True
    end

    def delete
      gl.delete_shader(@name)
    end

    def deleted?
      value = uninitialized LibGL::Int
      gl.get_shader_iv(@name, LibGL::ShaderParameterName::DeleteStatus, pointerof(value))
      from_gl_bool(value)
    end

    def type : Type
      value = uninitialized LibGL::Int
      gl.get_shader_iv(@name, LibGL::ShaderParameterName::ShaderType, pointerof(value))
      Type.new(value.to_u32!)
    end

    def source : String
      length = source_length
      String.new(length) do |buffer|
        gl.get_shader_source(@name, length, pointerof(length), buffer)
        {length, 0}
      end
    end

    private def source_length
      value = uninitialized LibGL::Int
      gl.get_shader_iv(@name, LibGL::ShaderParameterName::ShaderSourceLength, pointerof(value))
      value
    end

    def source=(source : String)
      pointer = source.to_unsafe
      null = Pointer(Int32).null
      gl.shader_source(@name, 1, pointerof(pointer), null)
    end

    def source=(sources : Enumerable(String))
      pointers = sources.map &.to_unsafe
      null = Pointer(Int32).null
      gl.shader_source(@name, pointers.size, pointers.to_unsafe, null)
    end

    def compile : Bool
      gl.compile_shader(@name)
      compiled?
    end

    def compile!
      return if compile
      raise ShaderCompilationError.new(info_log)
    end

    def compiled?
      value = uninitialized LibGL::Int
      gl.get_shader_iv(@name, LibGL::ShaderParameterName::CompileStatus, pointerof(value))
      from_gl_bool(value)
    end

    def info_log
      length = info_log_length
      String.new(length) do |buffer|
        gl.get_shader_info_log(@name, length, pointerof(length), buffer)
        {length, 0}
      end
    end

    private def info_log_length
      value = uninitialized LibGL::Int
      gl.get_shader_iv(@name, LibGL::ShaderParameterName::InfoLogLength, pointerof(value))
      value
    end

    def to_unsafe
      @name
    end
  end
end
