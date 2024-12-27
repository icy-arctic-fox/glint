require "opengl"
require "./context"
require "./contextual"
require "./errors"
require "./type_utils"

module Glint
  private alias ProgramPName = LibGL::ProgramPropertyARB

  struct Program
    include Contextual
    include TypeUtils

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

    def delete
      gl.delete_program(@name)
    end

    def deleted?
      value = uninitialized LibGL::Int
      gl.get_program_iv(@name, ProgramPName::DeleteStatus, pointerof(value))
      from_gl_bool(value)
    end

    def attach(shader : Shader) : Nil
      gl.attach_shader(@name, shader.name)
    end

    def <<(shader : Shader) : self
      attach(shader)
      self
    end

    def link : Bool
      gl.link_program(@name)
      linked?
    end

    def link!
      return if link
      raise ProgramLinkError.new(info_log)
    end

    def linked?
      value = uninitialized LibGL::Int
      gl.get_program_iv(@name, ProgramPName::LinkStatus, pointerof(value))
      from_gl_bool(value)
    end

    def info_log
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

    def to_unsafe
      @name
    end
  end
end
