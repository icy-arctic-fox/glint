module Glint
  # Provides macros for retrieving OpenGL parameters.
  module Parameters
    # Creates a getter-like method that retrieves an OpenGL parameter.
    #
    # The syntax for this macro is:
    # ```
    # gl_parameter name : Type = pname
    # ```
    # where `name` is the name of the method, `Type` is the return type, and `pname` is the parameter name.
    # The corresponding OpenGL `glGet` procedure called is based on `Type`.
    #
    # For example:
    # ```
    # gl_parameter major_version : Int32 = MajorVersion
    # ```
    # will create a method named `major_version` that returns an `Int32`.
    # The OpenGL parameter name is `LibGL::GetPName::MajorVersion`.
    # Notice that the `LibGL::GetPName` and `LibGL::StringName` prefixes are omitted.
    # The `glGet` procedure used would be `glGetIntegerv`.
    #
    # The supported types are `Int32`, `Int64`, `Float32`, `Float64`, `Bool`, and `String`.
    # `UInt32` and `UInt64` are supported by casting from `Int32` and `Int64` respectively (unchecked cast).
    #
    # The boolean type `Bool` adds a question mark to the method name.
    # For example, `gl_parameter blend : Bool = Blend` will create a method named `blend?`.
    #
    # See: https://registry.khronos.org/OpenGL-Refpages/gl4/html/glGet.xhtml
    macro gl_parameter(param)
      {%
        raise "Invalid OpenGL parameter declaration, \
          syntax for `gl_parameter` is `gl_parameter name : Type = pname`" if !param.is_a?(TypeDeclaration)
        raise "Invalid OpenGL parameter declaration, \
          the parameter name must be assigned to the method name." if !param.value

        param_type = param.type.resolve
        gl_type = param_type
        gl_proc = if param_type == Int32 || param_type == UInt32
                    gl_type = Int32
                    "get_integer_v"
                  elsif param_type == Int64 || param_type == UInt64
                    gl_type = Int64
                    "get_integer64_v"
                  elsif param_type == Float32
                    "get_float_v"
                  elsif param_type == Float64
                    "get_double_v"
                  elsif param_type == Bool
                    "get_boolean_v"
                  elsif param_type == String
                    "get_string"
                  else
                    raise "Invalid OpenGL parameter declaration, \
                      the parameter type must be one of: \
                      `Int32`, `UInt32`, `Int64`, `UInt64`, `Float32`, `Float64`, `Bool`, or `String`, \
                      but got #{param_type}."
                  end
      %}
      def {{param_type == Bool ? param.var + '?' : param.var}} : {{param.type}}
        {% if param_type == String %}
          pname = LibGL::StringName::{{param.value}}
          c_str = gl.{{gl_proc.id}}(pname)
          String.new(c_str)
        {% elsif param_type == Bool %}
          pname = LibGL::GetPName::{{param.value}}
          value = uninitialized LibGL::Boolean
          gl.{{gl_proc.id}}(pname, pointerof(value))
          value == LibGL::Boolean::True
        {% else %}
          pname = LibGL::GetPName::{{param.value}}
          value = uninitialized {{gl_type}}
          gl.{{gl_proc.id}}(pname, pointerof(value))
          {% if param_type == UInt32 || param_type == UInt64 %}
            value.to_unsigned!
          {% else %}
            value
          {% end %}
        {% end %}
      end
    end

    # Returns the OpenGL delegate.
    # This delegate is used to call OpenGL functions to retrieve parameters.
    protected abstract def gl
  end

  # Provides macros for retrieving OpenGL buffer parameters.
  module BufferParameters
    # Creates a getter-like method that retrieves an OpenGL parameter for buffer objects.
    #
    # The syntax for this macro is:
    # ```
    # gl_buffer_parameter name : Type = pname
    # ```
    # where `name` is the name of the method, `Type` is the return type, and `pname` is the parameter name.
    # The corresponding OpenGL `glGetBufferParameter` procedure called is based on `Type`.
    #
    # For example:
    # ```
    # gl_buffer_parameter size : Int32 = BufferSize
    # ```
    # will create a method named `size` that returns an `Int32`.
    # The OpenGL parameter name is `LibGL::BufferPNameARB::BufferSize`.
    # Notice that the `LibGL::BufferPNameARB` prefix is omitted.
    # The `glGetBufferParameter` procedure used would be `glGetNamedBufferParameteriv`.
    #
    # The supported types are `Int32`, `Int64`, and `Bool`.
    # `UInt32` and `UInt64` are supported by casting from `Int32` and `Int64` respectively (unchecked cast).
    #
    # The boolean type `Bool` adds a question mark to the method name.
    # For example, `gl_buffer_parameter mapped : Bool = Mapped` will create a method named `mapped?`.
    #
    # See: https://registry.khronos.org/OpenGL-Refpages/gl4/html/glGetBufferParameter.xhtml
    macro gl_buffer_parameter(param)
      {%
        raise "Invalid OpenGL parameter declaration, \
          syntax for `gl_buffer_parameter` is `gl_buffer_parameter name : Type = pname`" if !param.is_a?(TypeDeclaration)
        raise "Invalid OpenGL parameter declaration, \
          the parameter name must be assigned to the method name." if !param.value

        param_type = param.type.resolve
        gl_type = param_type
        gl_proc = if param_type == Int32 || param_type == UInt32 || param_type == Bool
                    gl_type = Int32
                    "get_named_buffer_parameter_iv"
                  elsif param_type == Int64 || param_type == UInt64
                    gl_type = Int64
                    "get_named_buffer_parameter_i64v"
                  else
                    raise "Invalid OpenGL parameter declaration, \
                      the parameter type must be one of: \
                      `Int32`, `UInt32`, `Int64`, `UInt64`, or `Bool`, \
                      but got #{param_type}."
                  end
      %}
      def {{param_type == Bool ? param.var + '?' : param.var}} : {{param.type}}
        {% if param_type == Bool %}
          pname = LibGL::BufferPNameARB::{{param.value}}
          value = uninitialized LibGL::Boolean
          gl.{{gl_proc.id}}(name, pname, pointerof(value))
          value == LibGL::Boolean::True
        {% else %}
          pname = LibGL::BufferPNameARB::{{param.value}}
          value = uninitialized {{gl_type}}
          gl.{{gl_proc.id}}(name, pname, pointerof(value))
          {% if param_type == UInt32 || param_type == UInt64 %}
            value.to_unsigned!
          {% else %}
            value
          {% end %}
        {% end %}
      end
    end

    # Name of the buffer object, which is a unique integer provided by OpenGL.
    abstract def name : LibGL::UInt

    # Returns the OpenGL delegate.
    # This delegate is used to call OpenGL functions to retrieve parameters.
    protected abstract def gl
  end
end
