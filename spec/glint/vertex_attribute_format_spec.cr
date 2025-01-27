require "../spec_helper"

alias VertexAttributeFormat = Glint::VertexAttributeFormat

Spectator.describe VertexAttributeFormat do
  describe "#initialize" do
    it "sets the attributes" do
      format = VertexAttributeFormat.new(4, :u_int8, true, 16)
      expect(format).to have_attributes(
        size: 4,
        type: Glint::VertexAttributeType::UInt8,
        normalized?: true,
        offset: 16,
      )
    end
  end
end
