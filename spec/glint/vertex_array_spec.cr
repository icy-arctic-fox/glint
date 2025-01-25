require "../spec_helper"

alias VertexArray = Glint::VertexArray

Spectator.describe VertexArray do
  let! gl_context = TestOpenGLScaffold.context

  describe "#initialize" do
    it "sets the attributes" do
      vao = VertexArray.new(gl_context, 42)
      expect(vao).to have_attributes(
        context: gl_context,
        name: 42,
      )
    end
  end

  describe ".generate" do
    it "generates a single VAO" do
      vao = VertexArray.generate(gl_context)
      expect(vao).to have_attributes(
        context: gl_context,
        exists?: false, # NOTE: VAOs made with `generate` (`glGenVertexArrays`) will not exist until bound.
      )
    end

    it "generates multiple VAOs" do
      collection = VertexArray.generate(gl_context, 3)
      expect(collection.size).to eq(3)
      expect(collection).to all(have_attributes(
        context: gl_context,
        exists?: false, # NOTE: VAOs made with `generate` (`glGenVertexArrays`) will not exist until bound.
      ))
    end
  end

  describe ".create" do
    it "creates a single VAO" do
      vao = VertexArray.create(gl_context)
      expect(vao).to have_attributes(
        context: gl_context,
        exists?: true,
      )
    end

    it "creates multiple VAOs" do
      collection = VertexArray.create(gl_context, 3)
      expect(collection.size).to eq(3)
      expect(collection).to all(have_attributes(
        context: gl_context,
        exists?: true,
      ))
    end
  end

  describe VertexArray::Collection do
    describe "#delete" do
      it "deletes all VAOs in the collection" do
        collection = VertexArray.create(gl_context, 3)
        expect { collection.delete }.to change { collection.all? &.exists? }.from(true).to(false)
      end
    end
  end

  describe "#exists?" do
    it "returns true if the VAO exists" do
      vao = VertexArray.new(gl_context)
      expect(vao.exists?).to be_true
    end

    it "returns false if the VAO does not exist" do
      vao = VertexArray.new(gl_context, 0)
      expect(vao.exists?).to be_false
    end
  end

  describe "#delete" do
    it "deletes the VAO" do
      vao = VertexArray.new(gl_context)
      vao.delete
      expect(vao.exists?).to be_false
    end
  end

  describe "#bind" do
    it "binds the VAO" do
      vao = VertexArray.new(gl_context)
      expect { vao.bind }.to change { vao.bound? }.from(false).to(true)
    end

    it "binds the VAO for the duration of the block" do
      vao = VertexArray.new(gl_context)
      expect(vao.bound?).to be_false
      vao.bind do
        expect(vao.bound?).to be_true
      end
      expect(vao.bound?).to be_false
    end
  end

  describe "#unbind" do
    it "unbinds the VAO if it is already bound" do
      vao = VertexArray.new(gl_context)
      vao.bind
      expect { vao.unbind }.to change { vao.bound? }.from(true).to(false)
    end

    it "does not unbind another VAO" do
      vao1 = VertexArray.new(gl_context)
      vao2 = VertexArray.new(gl_context)
      vao2.bind
      expect { vao1.unbind }.not_to change { vao2.bound? }.from(true)
    end
  end

  describe "#to_unsafe" do
    it "returns the VAO name" do
      vao = VertexArray.new(gl_context)
      expect(vao.to_unsafe).to eq(vao.name)
    end
  end
end
