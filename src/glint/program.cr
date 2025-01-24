require "opengl"
require "./context"
require "./contextual"
require "./errors"
require "./shader"
require "./type_utils"

module Glint
  private alias ProgramPName = LibGL::ProgramPropertyARB

  struct Program
    include Contextual
    include TypeUtils

    struct ShadersInterface
      include Contextual
      include Enumerable(Shader)

      getter context : Context
      private getter name : LibGL::UInt

      def initialize(@context : Context, @name : LibGL::UInt)
      end

      def <<(shader : Shader) : self
        gl.attach_shader(@name, shader.name)
        self
      end

      def each(& : Shader ->)
        names.each do |name|
          yield Shader.new(@context, name)
        end
      end

      def to_a : Array(Shader)
        names.to_a do |name|
          Shader.new(@context, name)
        end
      end

      def size
        value = uninitialized LibGL::Int
        gl.get_program_iv(@name, ProgramPName::AttachedShaders, pointerof(value))
        value
      end

      private def names
        names = Slice(LibGL::UInt).new(size, read_only: true)
        gl.get_attached_shaders(@name, size, Pointer(Int32).null, names.to_unsafe)
        names
      end
    end

    getter context : Context
    getter name : LibGL::UInt

    def initialize(@context : Context, @name : LibGL::UInt)
    end

    def self.new(context : Context)
      name = context.gl.create_program
      new(context, name)
    end

    def exists?
      gl.without_error_checking &.is_program(@name) == LibGL::Boolean::True
    end

    def delete : Nil
      gl.delete_program(@name)
    end

    def deleted?
      value = uninitialized LibGL::Int
      gl.get_program_iv(@name, ProgramPName::DeleteStatus, pointerof(value))
      from_gl_bool(value)
    end

    def attach(*shaders : Shader) : Nil
      shaders.each do |shader|
        gl.attach_shader(@name, shader.name)
      end
    end

    def detach(*shaders : Shader) : Nil
      shaders.each do |shader|
        gl.detach_shader(@name, shader.name)
      end
    end

    def shaders : ShadersInterface
      ShadersInterface.new(@context, @name)
    end

    def link : Bool
      gl.link_program(@name)
      linked?
    end

    def link! : Nil
      return if link
      raise ProgramLinkError.new(info_log)
    end

    def linked?
      value = uninitialized LibGL::Int
      gl.get_program_iv(@name, ProgramPName::LinkStatus, pointerof(value))
      from_gl_bool(value)
    end

    def info_log : String
      length = info_log_length
      String.new(length) do |buffer|
        gl.get_program_info_log(@name, length, pointerof(length), buffer)
        {length, 0}
      end
    end

    private def info_log_length
      value = uninitialized LibGL::Int
      gl.get_program_iv(@name, ProgramPName::InfoLogLength, pointerof(value))
      value
    end

    def use : Nil
      gl.use_program(@name)
    end

    def to_unsafe
      @name
    end
  end
end
