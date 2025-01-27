require "./vertex_attribute_format"
require "./vertex_attribute_type"
require "./vertex_attribute"

module Glint
  class VertexFormat
    include Indexable(VertexAttributeFormat)

    def initialize(@attributes : Array(VertexAttributeFormat))
    end

    def size
      @attributes.size
    end

    def unsafe_fetch(index : Int)
      @attributes.unsafe_fetch(index)
    end

    def self.from(type : T.class) : self forall T
      {% if T.annotation(VertexAttribute) %}
        from_annotated(type)
      {% else %}
        attributes = [] of VertexAttributeFormat
        {% for ivar in T.instance_vars %}
          {% if anno = ivar.annotation(VertexAttribute) %}
            %offset{ivar} = offsetof(T, @{{ivar}})
            {% if anno[:size] && anno[:type] %}
              %size{ivar} = {{anno[:size]}}
              %type{ivar} = VertexAttributeType.from({{anno[:type]}})
              %normalized{ivar} = {{anno[:normalized] || false}}
              attributes << VertexAttributeFormat.new(%size{ivar}, %type{ivar}, %normalized{ivar}, %offset{ivar})
            {% else %}
              %type{ivar} = typeof(T.allocate.@{{ivar}})
              append(%type{ivar}, %offset{ivar}, attributes)
            {% end %}
          {% end %}
        {% end %}
        new(attributes)
      {% end %}
    end

    private def self.from_annotated(type : T.class) : self forall T
      {% begin %}
        {% anno = T.annotation(VertexAttribute) %}
        size = {{anno[:size] || raise("VertexAttribute annotation on #{T} is missing required 'size' argument")}}
        component_type = VertexAttributeType.from({{anno[:type] || raise("VertexAttribute annotation on #{T} is missing required 'type' argument")}})
        normalized = {{anno[:normalized] || false}}
        new([VertexAttributeFormat.new(size, component_type, normalized)])
      {% end %}
    end

    private def self.append(type : VertexAttributePrimitive.class, offset, attributes) : Nil
      component_type = VertexAttributeType.from(type)
      attributes << VertexAttributeFormat.new(1, component_type, true, offset)
    end

    private def self.append(type : StaticArray(T, N).class, offset, attributes) : Nil forall T, N
      component_type = VertexAttributeType.from(T)
      attributes << VertexAttributeFormat.new(N, component_type, true, offset)
    end

    private def self.append(type : Tuple(*T).class, offset, attributes) : Nil forall T
      {% unless T.type_vars.all? { |t| t == T.type_vars[0] }
           raise "All generic types of a Tuple must be the same when used in a vertex attribute (got #{T})"
         end %}
      component_type = VertexAttributeType.from(T[0])
      attributes << VertexAttributeFormat.new(type.types.size, component_type, true, offset)
    end

    private def self.append(type : T.class, offset, attributes) : Nil forall T
      {% raise "#{T} cannot be used for a vertex attribute" if T.class? || T.module? %}
      {% if anno = T.annotation(VertexAttribute) %}
        size = {{anno[:size] || raise("VertexAttribute annotation on #{T} is missing required 'size' argument")}}
        component_type = VertexAttributeType.from({{anno[:type] || raise("VertexAttribute annotation on #{T} is missing required 'type' argument")}})
        normalized = {{anno[:normalized] || false}}
        attributes << VertexAttributeFormat.new(size, component_type, normalized)
      {% elsif T.struct? %}
        {% for ivar in T.instance_vars %}
          %type{ivar} = typeof(T.allocate.@{{ivar}})
          append(%type{ivar}, offsetof(T, @{{ivar}}) + offset, attributes)
        {% end %}
      {% else %}
        {% raise "#{T} is missing a VertexAttribute annotation" %}
      {% end %}
    end
  end
end
