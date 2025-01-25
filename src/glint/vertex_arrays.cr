require "./parameters"
require "./vertex_array"

module Glint
  module VertexArrays
    include Parameters

    private gl_parameter bound_vertex_array_name : UInt32 = VertexArrayBinding

    def bound_vertex_array : VertexArray?
      name = bound_vertex_array_name
      return if name == 0
      VertexArray.new(self, name)
    end

    def unbind_vertex_array : Nil
      gl.bind_vertex_array(0_u32)
    end

    def generate_vertex_array : VertexArray
      VertexArray.generate(self)
    end

    def generate_vertex_arrays(count : Int) : Indexable(VertexArray)
      VertexArray.generate(self, count)
    end

    def create_vertex_array : VertexArray
      VertexArray.create(self)
    end

    def create_vertex_arrays(count : Int) : Indexable(VertexArray)
      VertexArray.create(self, count)
    end
  end

  class Context
    include VertexArrays
  end
end
