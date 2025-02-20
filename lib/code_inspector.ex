defmodule CodeDecompiler do
  def decompile_to_string(module) when is_atom(module) do
    path = :code.which(module)
    
    case :beam_lib.chunks(path, [:abstract_code]) do
      {:ok, {_, [{:abstract_code, {:raw_abstract_v1, abstract_code}}]}} ->
        # Convert the abstract format to quoted expressions
        quoted = Enum.map(abstract_code, &abstract_code_to_quoted/1)
                |> Enum.reject(&is_nil/1)
                |> wrap_in_module(module)
        
        # Format the quoted expression into a string
        Macro.to_string(quoted)
        
      {:ok, {_, [{:abstract_code, none}]}} when none in [nil, :none] ->
        {:error, :no_abstract_code}
        
      {:error, :beam_lib, {:missing_chunk, _, _}} ->
        {:error, :no_debug_info}
        
      {:error, :beam_lib, error} ->
        {:error, {:beam_lib, error}}
        
      unexpected ->
        {:error, {:unexpected_chunk_format, unexpected}}
    end
  end

  # Helper to normalize line numbers from either integers or {line, column} tuples
  defp normalize_line(line) when is_integer(line), do: line
  defp normalize_line({line, _column}) when is_integer(line), do: line
  defp normalize_line(_), do: 0

  # Wrap the collected definitions in a module
  defp wrap_in_module(definitions, module_name) do
    quote do
      defmodule unquote(module_name) do
        unquote_splicing(definitions)
      end
    end
  end

  # Module attributes
  defp abstract_code_to_quoted({:attribute, _, :module, _}), do: nil  # Skip module attribute as we handle it in wrap_in_module
  defp abstract_code_to_quoted({:attribute, _, :export, _}), do: nil  # Skip exports
  defp abstract_code_to_quoted({:attribute, _, :compile, _}), do: nil # Skip compile attributes
  defp abstract_code_to_quoted({:attribute, line, name, value}) do
    quote line: normalize_line(line) do
      Module.put_attribute(__MODULE__, unquote(name), unquote(convert_attribute_value(value)))
    end
  end

  # Functions
  defp abstract_code_to_quoted({:function, line, name, arity, clauses}) do
    # Skip module_info functions as they're automatically generated
    case name do
      :__info__ -> nil
      :module_info -> nil
      name when is_atom(name) ->
        function_clauses = Enum.map(clauses, &clause_to_quoted/1)
        
        quote line: normalize_line(line) do
          def unquote(name)(unquote_splicing(make_vars(arity))) do
            unquote(function_clauses)
          end
        end
    end
  end

  # Function clauses
  defp clause_to_quoted({:clause, line, params, guards, body}) do
    converted_params = Enum.map(params, &pattern_to_quoted/1)
    converted_guards = Enum.map(guards, &guard_to_quoted/1)
    converted_body = Enum.map(body, &expression_to_quoted/1)
    
    case converted_guards do
      [] ->
        quote line: normalize_line(line) do
          unquote_splicing(converted_params) -> unquote_splicing(converted_body)
        end
      guards ->
        quote line: normalize_line(line) do
          unquote_splicing(converted_params) when unquote_splicing(guards) -> unquote_splicing(converted_body)
        end
    end
  end

  # Patterns (used in function heads and pattern matching)
  defp pattern_to_quoted({:match, line, pattern1, pattern2}) do
    quote line: normalize_line(line) do
      unquote(pattern_to_quoted(pattern1)) = unquote(pattern_to_quoted(pattern2))
    end
  end

  defp pattern_to_quoted({:var, line, name}) do
    quote line: normalize_line(line) do
      unquote(Macro.var(name, nil))
    end
  end
  
  defp pattern_to_quoted({:integer, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp pattern_to_quoted({:atom, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp pattern_to_quoted({:cons, line, head, tail}) do
    quote line: normalize_line(line) do
      [unquote(pattern_to_quoted(head)) | unquote(pattern_to_quoted(tail))]
    end
  end
  
  defp pattern_to_quoted({:nil, line}) do
    quote line: normalize_line(line) do
      []
    end
  end
  
  defp pattern_to_quoted({:tuple, line, elements}) do
    quoted_elements = Enum.map(elements, &pattern_to_quoted/1)
    quote line: normalize_line(line) do
      {unquote_splicing(quoted_elements)}
    end
  end
  
  defp pattern_to_quoted({:map, line, pairs}) do
    quoted_pairs = Enum.map(pairs, fn {op, k, v} -> 
      {map_op_to_quoted(op), pattern_to_quoted(k), pattern_to_quoted(v)}
    end)
    quote line: normalize_line(line) do
      %{unquote_splicing(quoted_pairs)}
    end
  end

  # Guards
  defp guard_to_quoted({:call, line, {:remote, _, {:atom, _, module}, {:atom, _, fun}}, args}) do
    quoted_args = Enum.map(args, &expression_to_quoted/1)
    quote line: normalize_line(line) do
      unquote(module).unquote(fun)(unquote_splicing(quoted_args))
    end
  end
  
  defp guard_to_quoted({:call, line, {:atom, _, fun}, args}) do
    quoted_args = Enum.map(args, &expression_to_quoted/1)
    quote line: normalize_line(line) do
      unquote(fun)(unquote_splicing(quoted_args))
    end
  end

  # Expressions (function bodies)
  # Binary expressions need to come before general constructs
  defp expression_to_quoted({:bin, line, elements}) do
    quoted_elements = Enum.map(elements, &binary_element_to_quoted/1)
    quote line: normalize_line(line) do
      <<unquote_splicing(quoted_elements)>>
    end
  end

  # Anonymous functions
  defp expression_to_quoted({:fun, line, {:clauses, clauses}}) do
    quoted_clauses = Enum.map(clauses, fn {:clause, clause_line, params, guards, body} ->
      converted_params = Enum.map(params, &pattern_to_quoted/1)
      converted_guards = Enum.map(guards, &guard_to_quoted/1)
      converted_body = Enum.map(body, &expression_to_quoted/1)
      
      case converted_guards do
        [] ->
          {:->, [line: normalize_line(clause_line)],
           [converted_params, {:__block__, [], converted_body}]}
        guards ->
          {:->, [line: normalize_line(clause_line)],
           [[{:when, [], converted_params ++ guards}], {:__block__, [], converted_body}]}
      end
    end)

    {:fn, [line: normalize_line(line)], quoted_clauses}
  end

  defp binary_element_to_quoted({:bin_element, _line, {:string, _sline, value}, :default, :default}) do
    value
  end

  defp binary_element_to_quoted({:bin_element, _line, expr, size, type}) do
    quoted_expr = expression_to_quoted(expr)
    build_bin_element(quoted_expr, size, type)
  end

  defp build_bin_element(expr, :default, :default), do: expr
  defp build_bin_element(expr, size, :default) when is_integer(size), do: quote do: unquote(expr)::size(unquote(size))
  defp build_bin_element(expr, :default, type), do: quote do: unquote(expr)::unquote(type)
  defp build_bin_element(expr, size, type), do: quote do: unquote(expr)::size(unquote(size))-unquote(type)

  # List construction
  defp expression_to_quoted({:cons, line, head, {:nil, _}}) do
    quote line: normalize_line(line) do
      [unquote(expression_to_quoted(head))]
    end
  end

  defp expression_to_quoted({:cons, line, head, tail}) do
    quote line: normalize_line(line) do
      [unquote(expression_to_quoted(head)) | unquote(expression_to_quoted(tail))]
    end
  end

  defp expression_to_quoted({:nil, line}) do
    quote line: normalize_line(line) do
      []
    end
  end

  # Other expressions
  defp expression_to_quoted({:match, line, pattern, expr}) do
    quote line: normalize_line(line) do
      unquote(pattern_to_quoted(pattern)) = unquote(expression_to_quoted(expr))
    end
  end
  
  defp expression_to_quoted({:call, line, {:remote, _, mod, fun}, args}) do
    quoted_mod = expression_to_quoted(mod)
    quoted_fun = expression_to_quoted(fun)
    quoted_args = Enum.map(args, &expression_to_quoted/1)
    
    quote line: normalize_line(line) do
      unquote(quoted_mod).unquote(quoted_fun)(unquote_splicing(quoted_args))
    end
  end
  
  defp expression_to_quoted({:call, line, {:atom, _, fun}, args}) do
    quoted_args = Enum.map(args, &expression_to_quoted/1)
    quote line: normalize_line(line) do
      unquote(fun)(unquote_splicing(quoted_args))
    end
  end
  
  defp expression_to_quoted({:case, line, expr, clauses}) do
    quoted_expr = expression_to_quoted(expr)
    quoted_clauses = Enum.map(clauses, &clause_to_quoted/1)
    
    quote line: normalize_line(line) do
      case unquote(quoted_expr) do
        unquote(quoted_clauses)
      end
    end
  end
  
  defp expression_to_quoted({:block, line, exprs}) do
    quoted_exprs = Enum.map(exprs, &expression_to_quoted/1)
    quote line: normalize_line(line) do
      unquote_splicing(quoted_exprs)
    end
  end
  
  defp expression_to_quoted({:tuple, line, elements}) do
    quoted_elements = Enum.map(elements, &expression_to_quoted/1)
    quote line: normalize_line(line) do
      {unquote_splicing(quoted_elements)}
    end
  end

  # Operator expressions
  defp expression_to_quoted({:op, line, operator, left, right}) do
    quote line: normalize_line(line) do
      unquote({operator, [], [expression_to_quoted(left), expression_to_quoted(right)]})
    end
  end

  defp expression_to_quoted({:op, line, operator, operand}) do
    quote line: normalize_line(line) do
      unquote({operator, [], [expression_to_quoted(operand)]})
    end
  end
  
  # Literals and basic terms
  defp expression_to_quoted({:atom, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp expression_to_quoted({:integer, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp expression_to_quoted({:float, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp expression_to_quoted({:string, line, value}) do
    quote line: normalize_line(line) do
      unquote(value)
    end
  end
  
  defp expression_to_quoted({:var, line, name}) do
    quote line: normalize_line(line) do
      unquote(Macro.var(name, nil))
    end
  end

  # Maps
  defp expression_to_quoted({:map, line, []}) do
    quote line: normalize_line(line) do
      %{}
    end
  end

  defp expression_to_quoted({:map, line, pairs}) do
    quoted_pairs = Enum.map(pairs, fn 
      {:map_field_assoc, _, key, value} -> 
        {:%{}, [], [{expression_to_quoted(key), expression_to_quoted(value)}]}
      {op, k, v} -> 
        {map_op_to_quoted(op), expression_to_quoted(k), expression_to_quoted(v)}
    end)
    quote line: normalize_line(line) do
      %{unquote_splicing(quoted_pairs)}
    end
  end

  # Helpers
  defp make_vars(n) when n > 0 do
    for i <- 1..n//1, do: Macro.var(:"arg#{i}", nil)
  end
  defp make_vars(_), do: []

  defp map_op_to_quoted(:exact), do: :%{}
  defp map_op_to_quoted(:assoc), do: :%{}

  defp convert_attribute_value(value) when is_atom(value) or is_integer(value) or is_float(value) or is_binary(value), do: value
  defp convert_attribute_value(value) when is_list(value), do: Enum.map(value, &convert_attribute_value/1)
  defp convert_attribute_value({a, b}), do: {convert_attribute_value(a), convert_attribute_value(b)}
  defp convert_attribute_value(other), do: other
end
