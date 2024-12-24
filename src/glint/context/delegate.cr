require "opengl"

module Glint
  class Context::Delegate
    def initialize(@loader : OpenGL::Loader)
    end

    macro method_missing(call)
      proc = @loader.{{call.name}}!
      proc.call({{call.args.splat}})
    end
  end
end
