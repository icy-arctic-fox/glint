require "opengl"

module Glint
  alias VertexAttributePrimitive = Int8 | Int16 | Int32 | UInt8 | UInt16 | UInt32 | Float32 | Float64

  enum VertexAttributeType
    Int8
    Int16
    Int32
    UInt8
    UInt16
    UInt32
    Float16
    Float32
    Float64

    def self.from(type : LibGL::Byte.class) : self
      Int8
    end

    def self.from(type : LibGL::Short.class) : self
      Int16
    end

    def self.from(type : LibGL::Int.class) : self
      Int32
    end

    def self.from(type : LibGL::UByte.class) : self
      UInt8
    end

    def self.from(type : LibGL::UShort.class) : self
      UInt16
    end

    def self.from(type : LibGL::UInt.class) : self
      UInt32
    end

    def self.from(type : LibGL::Float.class) : self
      Float32
    end

    def self.from(type : LibGL::Double.class) : self
      Float64
    end

    def self.from(type : T.class) : self forall T
      {% raise "#{T} cannot be used as a vertex attribute type" %}
    end

    def to_gl : LibGL::VertexAttribType
      case self
      in Int8    then LibGL::VertexAttribType::Byte
      in Int16   then LibGL::VertexAttribType::Short
      in Int32   then LibGL::VertexAttribType::Int
      in UInt8   then LibGL::VertexAttribType::UnsignedByte
      in UInt16  then LibGL::VertexAttribType::UnsignedShort
      in UInt32  then LibGL::VertexAttribType::UnsignedInt
      in Float16 then LibGL::VertexAttribType::HalfFloat
      in Float32 then LibGL::VertexAttribType::Float
      in Float64 then LibGL::VertexAttribType::Double
      end
    end
  end
end
