require "opengl"
require "../errors"

module Glint
  class Context
    private abstract struct AbstractDelegate
      include Errors

      def initialize(@loader : OpenGL::Loader)
      end
    end

    private struct Delegate < AbstractDelegate
      protected def gl
        self
      end

      macro method_missing(call)
        {% if call.block || call.block_arg %}
          proc = @loader.{{call.name}}
          yield proc if proc
        {% else %}
          proc = @loader.{{call.name}}!
          proc.call({{call.args.splat}})
        {% end %}
      end
    end

    private struct ErrorCheckingDelegate < AbstractDelegate
      protected def gl
        Delegate.new(@loader)
      end

      private def wrap_gl_function(proc : P) : P forall P
        {% begin %}
          # Workaround for: https://github.com/crystal-lang/crystal/issues/15373
          {% args = P.type_vars[0].type_vars.map_with_index { |_, i| "arg#{i}".id }.splat %}
          P.new do |{{args}}|
            with_error_checking do
              proc.call({{args}})
            end
          end
        {% end %}
      end

      macro method_missing(call)
        {% if call.block || call.block_arg %}
          proc = @loader.{{call.name}}
          yield wrap_gl_function(proc) if proc
        {% else %}
          proc = @loader.{{call.name}}!
          with_error_checking do
            proc.call({{call.args.splat}})
          end
        {% end %}
      end
    end
  end
end
