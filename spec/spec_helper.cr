require "glfw"
require "spectator"
require "../src/glint"

class TestOpenGLScaffold
  include Glint::Contextual

  class_getter! instance : self

  def self.context
    instance.context
  end

  getter context : Glint::Context
  getter window : LibGLFW::Window

  def initialize(@context, @window)
    @@instance = self
  end

  def self.new
    window = create_glfw_window
    context = create_opengl_context
    new(context, window)
  end

  private def self.create_glfw_window
    if LibGLFW.init == 0
      raise "Failed to initialize GLFW"
    end

    LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
    window = LibGLFW.create_window(640, 480, "Glint", nil, nil)
    unless window
      raise "Failed to create GLFW window"
    end
    LibGLFW.make_context_current(window)

    window
  end

  private def self.create_opengl_context
    loader = OpenGL::Loader.new do |name|
      LibGLFW.get_proc_address(name)
    end
    Glint::Context.new(loader)
  end

  def destroy
    # GLFW with Mesa (via Docker) might have an issue with termination.
    # This has caused segfaults, so explicit cleanup is skipped for Mesa.
    return if mesa?

    LibGLFW.destroy_window(@window)
    LibGLFW.terminate
  end

  private def mesa?
    c_str = gl.get_string(LibGL::StringName::Vendor)
    vendor = String.new(c_str)
    vendor == "Mesa"
  end
end

Spectator.configure do |config|
  config.before_suite do
    TestOpenGLScaffold.new
  end

  config.after_suite do
    TestOpenGLScaffold.instance.destroy
  end
end
