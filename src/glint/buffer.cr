require "opengl"
require "./context"
require "./contextual"
require "./parameters"
require "./type_utils"

module Glint
  abstract struct UntypedBuffer
    module Constructors
      def generate_uninitialized(context : Context) : self
        name = uninitialized LibGL::UInt
        context.gl.gen_buffers(1, pointerof(name))
        new(context, name)
      end

      def generate_uninitialized(context : Context, count : Int) : Indexable(self)
        Buffer::Collection(self).new(context, count) do |names|
          context.gl.gen_buffers(count, names)
        end
      end

      def create_uninitialized(context : Context) : self
        buffer = context.gl.create_buffers do |create_buffers|
          name = uninitialized LibGL::UInt
          create_buffers.call(1, pointerof(name))
          new(context, name)
        end
        buffer || generate(context)
      end

      def create_uninitialized(context : Context, count : Int) : Indexable(self)
        collection = context.gl.create_buffers do |create_buffers|
          Buffer::Collection(self).new(context, count) do |names|
            create_buffers.call(count, names)
          end
        end
        collection || generate(context, count)
      end
    end

    include BufferParameters
    include Contextual
    include TypeUtils

    getter context : Context
    getter name : LibGL::UInt

    gl_buffer_parameter static : Bool = BufferImmutableStorage
    gl_buffer_parameter mapped : Bool = BufferMapped
    gl_buffer_parameter size : Int64 = BufferSize

    def initialize(@context : Context, @name : LibGL::UInt)
    end

    def exists?
      value = gl.is_buffer(@name)
      from_gl_bool(value)
    end

    def delete : Nil
      gl.delete_buffers(1, pointerof(@name))
    end

    def bytesize
      size
    end

    def bind(target : BufferBindingTarget | BufferBindingTarget::Enum) : Nil
      gl.bind_buffer(target.to_gl, @name)
    end

    def bound?(target : BufferBindingTarget)
      target.buffer == self
    end

    def bound?(target : BufferBindingTarget::Enum)
      bound?(BufferBindingTarget.new(@context, target))
    end

    def unbind(target : BufferBindingTarget | BufferBindingTarget::Enum) : Nil
      gl.bind_buffer(target.to_gl, 0) if bound?(target)
    end

    def bind(target : BufferBindingTarget, & : self, BufferBindingTarget ->)
      target.bind { |binding_target| yield self, binding_target }
    end

    def bind(target : BufferBindingTarget::Enum, & : self ->)
      bind(BufferBindingTarget.new(@context, target)) do |buffer, binding_target|
        yield buffer, binding_target
      end
    end

    def map(access : Buffer::Access) : Bytes
      pointer = gl.map_named_buffer(@name, access.to_gl)
      Bytes.new(pointer, size)
    end

    def map(access : Buffer::MapAccess, start : Int, count : Int) : Bytes
      start, count = Indexable.normalize_start_and_count(start, count, size)
      pointer = gl.map_named_buffer_range(@name, start, count, access.to_gl)
      Bytes.new(pointer, count)
    end

    def map(access : Buffer::MapAccess, range : Range) : Bytes
      start, count = Indexable.range_to_index_and_count(range, size)
      pointer = gl.map_named_buffer_range(@name, start, count, access.to_gl)
      Bytes.new(pointer, count)
    end

    def unmap : Bool
      value = gl.unmap_named_buffer(@name)
      from_gl_bool(value)
    end

    def map(access : Buffer::Access, & : Bytes ->) : Bool
      bytes = map(access)
      begin
        yield bytes
      ensure
        return unmap
      end
    end

    def map(access : Buffer::MapAccess, start : Int, size : Int, & : Bytes ->) : Bool
      bytes = map(access, start, size)
      begin
        yield bytes
      ensure
        return unmap
      end
    end

    def map(access : Buffer::MapAccess, range : Range, & : Bytes ->) : Bool
      bytes = map(access, range)
      begin
        yield bytes
      ensure
        return unmap
      end
    end

    def clear : Nil
      gl.clear_named_buffer_data(@name,
        LibGL::SizedInternalFormat::R32UI,
        LibGL::PixelFormat::Red,
        LibGL::PixelType::UnsignedInt,
        Pointer(UInt8).null)
    end

    def data : Bytes
      bytes = Bytes.new(size)
      gl.get_named_buffer_sub_data(@name, 0, bytes.size, bytes.to_unsafe)
      bytes
    end

    def [](index : Int) : UInt8
      index = normalize_index(index)
      unsafe_fetch(index)
    end

    def [](start : Int, count : Int) : Bytes
      start, count = Indexable.normalize_start_and_count(start, count, size)
      unsafe_fetch(start, count)
    end

    def [](range : Range) : Bytes
      start, count = Indexable.range_to_index_and_count(range, size)
      unsafe_fetch(start, count)
    end

    def unsafe_fetch(index : Int) : UInt8
      value = uninitialized UInt8
      gl.get_named_buffer_sub_data(@name, index, 1, pointerof(value))
      value
    end

    def unsafe_fetch(start : Int, count : Int) : Bytes
      bytes = Bytes.new(count)
      gl.get_named_buffer_sub_data(@name, start, count, bytes.to_unsafe)
      bytes
    end

    def []=(index : Int, value : UInt8)
      index = normalize_index(index)
      unsafe_put(index, value)
    end

    def []=(start : Int, bytes : Bytes)
      start, count = Indexable.normalize_start_and_count(start, bytes.size, size)
      unsafe_put(start, count, bytes.to_unsafe)
    end

    def unsafe_put(index : Int, value : UInt8)
      gl.named_buffer_sub_data(@name, index, 1, pointerof(value))
    end

    def unsafe_put(start : Int, count : Int, pointer : UInt8*)
      gl.named_buffer_sub_data(@name, start, count, pointer)
    end

    private def normalize_index(index : Int) : Int
      if index < 0
        index += size
        raise IndexError.new if index < 0
      elsif index >= size
        raise IndexError.new
      end
      index
    end

    def to_unsafe
      @name
    end
  end

  struct Buffer < UntypedBuffer
    @[Flags]
    enum Access
      Read
      Write
      ReadWrite = Read | Write

      def to_gl
        case self
        in .read_write? then LibGL::BufferAccessARB::ReadWrite
        in .read?       then LibGL::BufferAccessARB::ReadOnly
        in .write?      then LibGL::BufferAccessARB::WriteOnly
        end
      end
    end

    @[Flags]
    enum MapAccess : UInt32
      {% begin %}
        Read             = {{LibGL::MapBufferAccessMask::MapRead}}
        Write            = {{LibGL::MapBufferAccessMask::MapWrite}}
        InvalidateRange  = {{LibGL::MapBufferAccessMask::MapInvalidateRange}}
        InvalidateBuffer = {{LibGL::MapBufferAccessMask::MapInvalidateBuffer}}
        FlushExplicit    = {{LibGL::MapBufferAccessMask::MapFlushExplicit}}
        Unsynchronized   = {{LibGL::MapBufferAccessMask::MapUnsynchronized}}
        Persistent       = {{LibGL::MapBufferAccessMask::MapPersistent}}
        Coherent         = {{LibGL::MapBufferAccessMask::MapCoherent}}
        ReadWrite        = Read | Write
      {% end %}

      def to_gl
        LibGL::MapBufferAccessMask.new(value)
      end
    end

    struct Collection(B)
      include Indexable(B)

      protected def initialize(@context : Context, size : Int, & : Pointer(LibGL::UInt) ->)
        {% raise "B must be an UntypedBuffer" unless B < UntypedBuffer %}
        names = Pointer(LibGL::UInt).malloc(size)
        yield names
        @names = Slice(LibGL::UInt).new(names, size, read_only: true)
      end

      def size
        @names.size
      end

      def unsafe_fetch(index : Int)
        name = @names.unsafe_fetch(index)
        B.new(@context, name)
      end

      def delete : Nil
        @context.gl.delete_buffers(@names.size, @names.to_unsafe)
      end
    end

    extend UntypedBuffer::Constructors

    def self.new(context : Context, size : Int, usage : Usage)
      buffer = create_uninitialized(context)
      buffer.reallocate(size, usage)
      buffer
    end

    def self.new(context : Context, bytes : Bytes, usage : Usage)
      buffer = create_uninitialized(context)
      buffer.reallocate(bytes, usage)
      buffer
    end

    def reallocate_uninitialized(size : Int, usage : Usage) : Nil
      gl.named_buffer_data(@name, size, Pointer(UInt8).null, usage.to_gl)
    end

    def reallocate(size : Int, usage : Usage) : Nil
      reallocate_uninitialized(size, usage)
      clear
    end

    def reallocate(bytes : Bytes, usage : Usage) : Nil
      gl.named_buffer_data(@name, bytes.size, bytes.to_unsafe, usage.to_gl)
    end

    def data=(bytes : Bytes)
      reallocate(bytes, usage)
    end
  end

  struct StaticBuffer < UntypedBuffer
    extend UntypedBuffer::Constructors
  end
end
