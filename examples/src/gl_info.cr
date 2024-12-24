require "glfw"
require "glint"
require "opengl"

if LibGLFW.init == LibGLFW::Bool::False
  STDERR.puts "Failed to initialize GLFW"
  exit 1
end

LibGLFW.window_hint(LibGLFW::WindowHint::Visible, LibGLFW::Bool::False)
window = LibGLFW.create_window(640, 480, "Glint", nil, nil)
unless window
  STDERR.puts "Failed to create GLFW window"
  LibGLFW.terminate
  exit 1
end
LibGLFW.make_context_current(window)

loader = OpenGL::Loader.new do |name|
  LibGLFW.get_proc_address(name)
end

context = Glint::Context.new(Glint::Context::Delegate.new(loader))
major, minor = context.major_version, context.minor_version
puts "OpenGL version: #{major}.#{minor}"

LibGLFW.destroy_window(window)
LibGLFW.terminate
