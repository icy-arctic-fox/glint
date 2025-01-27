require "../spec_helper"

alias VertexFormat = Glint::VertexFormat

private struct TestVertex1
  getter unused = 0

  @[Glint::VertexAttribute]
  getter used = 0
end

private record TestVertexColor1,
  red = 0_u8,
  green = 0_u8,
  blue = 0_u8,
  alpha = 0_u8

private struct TestVertex2
  @[Glint::VertexAttribute]
  getter position = {0.0, 0.0, 0.0}

  @[Glint::VertexAttribute]
  getter color = TestVertexColor1.new

  @[Glint::VertexAttribute]
  getter texture = StaticArray(Float32, 2).new(0)
end

@[Glint::VertexAttribute(size: 4, type: UInt8, normalized: true)]
private record TestVertexColor2,
  red = 0_u8,
  green = 0_u8,
  blue = 0_u8,
  alpha = 0_u8

private struct TestVertex3
  @[Glint::VertexAttribute]
  getter color = TestVertexColor2.new
end

private struct TestVertex4
  @[Glint::VertexAttribute(size: 4, type: UInt8, normalized: true)]
  getter color = TestVertexColor1.new
end

Spectator.describe VertexFormat do
  describe ".from" do
    it "ignores variables without annotations" do
      format = VertexFormat.from(TestVertex1)
      expect(format.size).to eq(1)
      expect(format[0]).to have_attributes(
        size: 1,
        type: Glint::VertexAttributeType::Int32,
        normalized?: true,
        offset: 4,
      )
    end

    it "detects variables with annotations" do
      format = VertexFormat.from(TestVertex2)
      expect(format.size).to eq(6)
    end

    it "supports tuples" do
      format = VertexFormat.from(TestVertex2)
      expect(format[0]).to have_attributes(
        size: 3,
        type: Glint::VertexAttributeType::Float64,
        offset: 0,
      )
    end

    it "supports structs" do
      format = VertexFormat.from(TestVertex2)
      4.times do |i|
        expect(format[i + 1]).to have_attributes(
          size: 1,
          type: Glint::VertexAttributeType::UInt8,
          offset: 24 + i,
        )
      end
    end

    it "supports static arrays" do
      format = VertexFormat.from(TestVertex2)
      expect(format[5]).to have_attributes(
        size: 2,
        type: Glint::VertexAttributeType::Float32,
        offset: 28,
      )
    end

    it "uses values from type type's VertexAttribute annotation" do
      format = VertexFormat.from(TestVertexColor2)
      expect(format.size).to eq(1)
      expect(format[0]).to have_attributes(
        size: 4,
        type: Glint::VertexAttributeType::UInt8,
        normalized?: true,
        offset: 0,
      )
    end

    it "uses values from type type's VertexAttribute annotation when nested" do
      format = VertexFormat.from(TestVertex3)
      expect(format.size).to eq(1)
      expect(format[0]).to have_attributes(
        size: 4,
        type: Glint::VertexAttributeType::UInt8,
        normalized?: true,
        offset: 0,
      )
    end

    it "uses the values from the variable's VertexAttribute annotation" do
      format = VertexFormat.from(TestVertex4)
      expect(format.size).to eq(1)
      expect(format[0]).to have_attributes(
        size: 4,
        type: Glint::VertexAttributeType::UInt8,
        normalized?: true,
        offset: 0,
      )
    end
  end
end
