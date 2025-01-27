require "./vertex_attribute_type"

module Glint
  struct VertexAttributeFormat
    getter size : Int32

    getter type : VertexAttributeType

    getter? normalized : Bool

    getter offset : Int32

    def initialize(@size, @type, @normalized, @offset = 0)
    end
  end
end
