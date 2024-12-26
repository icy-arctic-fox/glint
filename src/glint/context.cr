require "opengl"
require "./parameters"

module Glint
  class Context
    include Parameters

    gl_parameter major_version : Int32 = MajorVersion
    gl_parameter minor_version : Int32 = MinorVersion
    gl_parameter vendor : String = Vendor
    gl_parameter renderer : String = Renderer
    gl_parameter version : String = Version

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

    # Returns the OpenGL delegate.
    # This is used to call OpenGL functions within this context.
    protected def gl
      @delegate
    end

    macro def_interface(interface, &block)
      {%
        raise "Invalid context interface declaration, \
        syntax for `Context.def_interface` is `Context.def_interface name : Type`" if !interface.is_a?(TypeDeclaration)
      %}
      module ::Glint
        class Context
          getter {{interface.var}} : {{interface.type}} do
            {% if block %}
              {% unless block.args.empty? %}{{block.args.first}} = self{% end %}
              {{block.body}}
            {% else %}
              {{interface.type}}.new(self)
            {% end %}
          end
        end
      end
    end
  end
end

require "./context/*"
