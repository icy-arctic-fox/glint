require "opengl"
require "./context"
require "./contextual"
require "./parameters"
require "./type_utils"

module Glint
  struct VertexArrayObject
    include Contextual
    include Parameters
    include TypeUtils

    struct Collection
      include Indexable(VertexArrayObject)

      protected def initialize(@context : Context, size : Int, & : Pointer(LibGL::UInt) ->)
        names = Pointer(LibGL::UInt).malloc(size)
        yield names
        @names = Slice(LibGL::UInt).new(names, size, read_only: true)
      end

      def size
        @names.size
      end

      def unsafe_fetch(index : Int)
        name = @names.unsafe_fetch(index)
        VertexArrayObject.new(@context, name)
      end

      def delete : Nil
        @context.gl.delete_vertex_arrays(@names.size, @names.to_unsafe)
      end
    end

    getter context : Context
    getter name : LibGL::UInt

    def initialize(@context : Context, @name : LibGL::UInt)
    end

    def self.new(context : Context)
      vao = context.gl.create_vertex_arrays do |create_vertex_arrays|
        name = uninitialized LibGL::UInt
        create_vertex_arrays.call(1, pointerof(name))
        new(context, name)
      end
      vao || generate(context)
    end

    def self.generate(context : Context) : self
      name = uninitialized LibGL::UInt
      context.gl.gen_vertex_arrays(1, pointerof(name))
      new(context, name)
    end

    def self.generate(context : Context, count : Int) : Indexable(self)
      Collection.new(context, count) do |names|
        context.gl.gen_vertex_arrays(count, names)
      end
    end

    def self.create(context : Context) : self
      vao = context.gl.create_vertex_arrays do |create_vertex_arrays|
        name = uninitialized LibGL::UInt
        create_vertex_arrays.call(1, pointerof(name))
        new(context, name)
      end
      return vao if vao

      # Emulate `glCreateVertexArrays` by binding.
      # OpenGL marks a name as used, but not existing when `glGenVertexArrays` is used.
      # Binding the VAO ensures the underlying resources are created.
      generate(context).bind &.itself
    end

    def self.create(context : Context, count : Int) : Indexable(self)
      collection = context.gl.create_vertex_arrays do |create_vertex_arrays|
        Collection.new(context, count) do |names|
          create_vertex_arrays.call(count, names)
        end
      end
      return collection if collection

      # Emulate `glCreateVertexArrays` by binding.
      # OpenGL marks a name as used, but not existing when `glGenVertexArrays` is used.
      # Binding the VAO ensures the underlying resources are created.
      collection = generate(context, count)
      collection.each &.bind
      collection
    end

    def exists?
      value = gl.is_vertex_array(@name)
      from_gl_bool(value)
    end

    def delete : Nil
      gl.delete_vertex_arrays(1, pointerof(@name))
    end

    private gl_parameter bound_name : UInt32 = VertexArrayBinding

    def bind : Nil
      gl.bind_vertex_array(@name)
    end

    def bound?
      bound_name == @name
    end

    def unbind : Nil
      gl.bind_vertex_array(0_u32) if bound?
    end

    def bind(& : self -> _)
      previously_bound = bound_name
      begin
        bind
        yield self
      ensure
        gl.bind_vertex_array(previously_bound)
      end
    end

    def to_unsafe
      @name
    end
  end
end
