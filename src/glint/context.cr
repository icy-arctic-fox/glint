require "opengl"
require "./parameters"

module Glint
  struct Context
    include Parameters

    gl_parameter major_version : Int32 = MajorVersion
    gl_parameter minor_version : Int32 = MinorVersion

    # Use of `AbstractDelegate` is avoided to reduce dispatch overhead.
    {% if flag?(:release) && !flag?(:gl_error_checking) %}
      @delegate : Delegate
    {% else %}
      @delegate : ErrorCheckingDelegate
    {% end %}

    def initialize(@delegate)
    end

    def self.new(loader : OpenGL::Loader)
      delegate = {% if flag?(:release) && !flag?(:gl_error_checking) %}
                   Delegate.new(loader)
                 {% else %}
                   ErrorCheckingDelegate.new(loader)
                 {% end %}
      new(delegate)
    end

    def gl
      @delegate
    end
  end
end

require "./context/*"
