require "glfw"
require "spectator"
require "../src/glint"

CONTEXT_STORE = [] of {Glint::Context, LibGLFW::Window}

def gl_context
  context = CONTEXT_STORE.first?.try &.[0]?
  context.not_nil!("OpenGL context not initialized")
end

private def create_context
  if LibGLFW.init == 0
    raise "Failed to initialize GLFW"
  end

  LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
  window = LibGLFW.create_window(640, 480, "Glint", nil, nil)
  unless window
    raise "Failed to create GLFW window"
  end
  LibGLFW.make_context_current(window)

  loader = OpenGL::Loader.new do |name|
    LibGLFW.get_proc_address(name)
  end

  delegate = Glint::Context::Delegate.new(loader)
  context = Glint::Context.new(delegate)

  {context, window}
end

private def destroy_context(window)
  LibGLFW.destroy_window(window)
  LibGLFW.terminate
end

Spectator.configure do |config|
  config.before_suite do
    CONTEXT_STORE << create_context
  end

  config.after_suite do
    _, window = CONTEXT_STORE.pop
    destroy_context(window)
  end
end
