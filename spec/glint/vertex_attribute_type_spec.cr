require "../spec_helper"

alias VertexAttributeType = Glint::VertexAttributeType

Spectator.describe VertexAttributeType do
  # A macro loop is used instead of `each` because `each` creates a union, causing a compilation error.
  {% for type in [Int8, Int16, Int32, UInt8, UInt16, UInt32, Float32, Float64] %}
    describe {{".from(#{type}.class)"}} do
      it {{"returns #{type}"}} do
        result = VertexAttributeType.from({{type}})
        expect(result).to eq(VertexAttributeType::{{type}})
      end
    end
  {% end %}

  enum_values = {
    :int8    => :byte,
    :int16   => :short,
    :int32   => :int,
    :u_int8  => :unsigned_byte,
    :u_int16 => :unsigned_short,
    :u_int32 => :unsigned_int,
    :float16 => :half_float,
    :float32 => :float,
    :float64 => :double,
  } of VertexAttributeType => LibGL::VertexAttribType

  describe "#to_gl" do
    # ameba:disable Naming/BlockParameterName
    enum_values.each do |vat, gl|
      it "converts #{vat} to #{gl}" do
        expect(vat.to_gl).to eq(gl)
      end
    end
  end
end
