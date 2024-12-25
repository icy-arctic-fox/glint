require "./context"

module Glint
  # A mix-in for types that utilize an OpenGL context.
  # This module exposes a `gl` method that returns the OpenGL delegate,
  # which can be used to call OpenGL functions.
  private module Contextual
    # Returns the OpenGL context this object is associated with.
    abstract def context : Context

    # Returns the OpenGL delegate.
    # This can be used to call OpenGL functions in the context of the current object.
    protected def gl
      context.gl
    end
  end
end
