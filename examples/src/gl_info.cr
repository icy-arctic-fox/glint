require "glfw"
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

get_integer_v = loader.get_integer_v!

major = 0
minor = 0
get_integer_v.call(LibGL::GetPName::MajorVersion, pointerof(major))
get_integer_v.call(LibGL::GetPName::MinorVersion, pointerof(minor))
puts "OpenGL version: #{major}.#{minor}"

LibGLFW.destroy_window(window)
LibGLFW.terminate
