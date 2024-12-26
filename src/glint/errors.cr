module Glint
  abstract class GlintError < Exception
  end

  abstract class OpenGLError < GlintError
  end

  class InvalidEnumError < OpenGLError
  end

  class InvalidValueError < OpenGLError
  end

  class InvalidOperationError < OpenGLError
  end

  class OutOfMemoryError < OpenGLError
  end

  class InvalidFramebufferOperationError < OpenGLError
  end

  class StackUnderflowError < OpenGLError
  end

  class StackOverflowError < OpenGLError
  end

  module Errors
    # Retrieves the pending OpenGL error.
    # Returns `nil` if no error has occurred.
    # After returning an error, it is cleared.
    #
    # NOTE: If multiple errors have occurred, only the first error will be returned.
    #   Subsequent errors will be ignored/dropped.
    def error : OpenGLError?
      code = gl.get_error.to_i32!
      name = LibGL::ErrorCode.new(code)
      case name
      in .no_error?                      then nil
      in .invalid_enum?                  then InvalidEnumError.new
      in .invalid_value?                 then InvalidValueError.new
      in .invalid_operation?             then InvalidOperationError.new
      in .out_of_memory?                 then OutOfMemoryError.new
      in .invalid_framebuffer_operation? then InvalidFramebufferOperationError.new
      in .stack_underflow?               then StackUnderflowError.new
      in .stack_overflow?                then StackOverflowError.new
      end
    end

    # Executes a block of code and checks for OpenGL errors.
    # Raises the first error encountered if any occur.
    # Returns the result of the block, if no errors occur.
    #
    # NOTE: Only one OpenGL function that can raise an error should be called per block.
    #   If multiple functions are called, only the first error will be raised.
    #
    # The OpenGL delegate is provided as the first argument to the block.
    # This allows for syntactic sugar like `gl.with_error_checking &.clear_color(0.0, 0.0, 0.0, 1.0)`.
    def with_error_checking(&)
      yield gl
    ensure
      error.try { |e| raise e }
    end

    # Executes a block of code without error checking.
    # Returns the result of the block.
    # This method should only be used with OpenGL functions that are known to not raise errors.
    #
    # The OpenGL delegate is provided as the first argument to the block.
    # This allows for syntactic sugar like `gl.without_error_checking &.is_shader(name)`.
    def without_error_checking(&)
      yield gl
    end

    # Returns the OpenGL delegate.
    # This delegate *must not* perform error checking,
    # otherwise it may cause infinite recursion.
    protected abstract def gl
  end
end
