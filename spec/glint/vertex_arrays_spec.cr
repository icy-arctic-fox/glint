require "../spec_helper"

Spectator.describe Glint::VertexArrays do
  let! gl_context = TestOpenGLScaffold.context

  describe "#bound_vertex_array" do
    it "returns nil if there is no VAO bound" do
      gl_context.unbind_vertex_array
      expect(gl_context.bound_vertex_array).to be_nil
    end

    it "returns the bound VAO" do
      vao = gl_context.create_vertex_array
      vao.bind
      expect(gl_context.bound_vertex_array).to be(vao)
    end
  end

  describe "#unbind_vertex_array" do
    it "unbinds a VAO" do
      vao = gl_context.create_vertex_array
      vao.bind
      expect { gl_context.unbind_vertex_array }.to change { vao.bound? }.to(false)
    end
  end

  describe "#generate_vertex_array" do
    it "generates a single VAO" do
      vao = gl_context.generate_vertex_array
      expect(vao).to have_attributes(
        context: gl_context,
        exists?: false, # NOTE: VAOs made with `generate` (`glGenVertexArrays`) will not exist until bound.
      )
    end
  end

  describe "#generate_vertex_arrays" do
    it "generates multiple VAOs" do
      collection = gl_context.generate_vertex_arrays(3)
      expect(collection.size).to eq(3)
      expect(collection).to all(have_attributes(
        context: gl_context,
        exists?: false, # NOTE: VAOs made with `generate` (`glGenVertexArrays`) will not exist until bound.
      ))
    end
  end

  describe "#create_vertex_array" do
    it "creates a single VAO" do
      vao = gl_context.create_vertex_array
      expect(vao).to have_attributes(
        context: gl_context,
        exists?: true,
      )
    end
  end

  describe "#create_vertex_arrays" do
    it "creates multiple VAOs" do
      collection = gl_context.create_vertex_arrays(3)
      expect(collection.size).to eq(3)
      expect(collection).to all(have_attributes(
        context: gl_context,
        exists?: true,
      ))
    end
  end
end
