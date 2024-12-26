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
        proc = @loader.{{call.name}}!
        proc.call({{call.args.splat}})
      end
    end

    private struct ErrorCheckingDelegate < AbstractDelegate
      protected def gl
        Delegate.new(@loader)
      end

      macro method_missing(call)
        proc = @loader.{{call.name}}!
        with_error_checking do
          proc.call({{call.args.splat}})
        end
      end
    end
  end
end
