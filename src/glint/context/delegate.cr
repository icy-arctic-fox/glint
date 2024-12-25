require "opengl"
require "../errors"

module Glint
  struct Context
    abstract struct AbstractDelegate
      include Errors

      def initialize(@loader : OpenGL::Loader)
      end
    end

    struct Delegate < AbstractDelegate
      def gl
        self
      end

      macro method_missing(call)
        proc = @loader.{{call.name}}!
        proc.call({{call.args.splat}})
      end
    end

    struct ErrorCheckingDelegate < AbstractDelegate
      def gl
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
