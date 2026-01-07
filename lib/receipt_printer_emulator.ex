defmodule ReceiptPrinterEmulator do
  @moduledoc """
  A receipt printer emulator that simulates ESC/POS printer behavior.
  Captures and processes print commands, rendering them to text/HTML output.
  """

  import Bitwise

  defstruct [
    :width,
    :current_line,
    :buffer,
    :mode,
    :font_size,
    :alignment,
    :bold,
    :underline,
    :inverse,
    :double_width,
    :double_height,
    :line_spacing,
    :barcode_height,
    :barcode_width,
    :barcode_text_position
  ]

  @default_width 48
  @esc 0x1B
  @gs 0x1D
  @lf 0x0A
  @cr 0x0D

  def new(opts \\ []) do
    %__MODULE__{
      width: Keyword.get(opts, :width, @default_width),
      current_line: "",
      buffer: [],
      mode: :normal,
      font_size: :normal,
      alignment: :left,
      bold: false,
      underline: false,
      inverse: false,
      double_width: false,
      double_height: false,
      line_spacing: 30,
      barcode_height: 162,
      barcode_width: 3,
      barcode_text_position: :below
    }
  end

  def process(printer, data) when is_binary(data) do
    process_bytes(printer, :erlang.binary_to_list(data))
  end

  def process(printer, data) when is_list(data) do
    process_bytes(printer, data)
  end

  def render(printer, format \\ :text) do
    case format do
      :text -> render_text(printer)
      :html -> render_html(printer)
      :raw -> Enum.reverse(printer.buffer)
    end
  end

  def clear(printer) do
    %{printer | buffer: [], current_line: ""}
  end

  # Private functions

  defp process_bytes(printer, []), do: printer

  defp process_bytes(printer, [@esc | rest]) do
    process_esc_command(printer, rest)
  end

  defp process_bytes(printer, [@gs | rest]) do
    process_gs_command(printer, rest)
  end

  defp process_bytes(printer, [@lf | rest]) do
    printer
    |> flush_line()
    |> process_bytes(rest)
  end

  defp process_bytes(printer, [@cr | rest]) do
    printer
    |> flush_line()
    |> process_bytes(rest)
  end

  defp process_bytes(printer, [byte | rest]) when byte >= 32 and byte <= 126 do
    char = <<byte>>
    printer = %{printer | current_line: printer.current_line <> char}
    process_bytes(printer, rest)
  end

  defp process_bytes(printer, [_ | rest]) do
    process_bytes(printer, rest)
  end

  defp process_esc_command(_printer, [?@ | rest]) do
    # Initialize printer
    new()
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?d, n | rest]) do
    # Print and feed n lines
    printer
    |> flush_line()
    |> add_blank_lines(n)
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?J, _n | rest]) do
    # Print and feed n dots
    printer
    |> flush_line()
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?a, n | rest]) do
    # Set justification
    alignment = case n do
      0 -> :left
      1 -> :center
      2 -> :right
      _ -> :left
    end
    %{printer | alignment: alignment}
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?E, n | rest]) do
    # Set emphasis (bold)
    %{printer | bold: n == 1}
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?-, n | rest]) do
    # Set underline
    %{printer | underline: n > 0}
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?!, n | rest]) do
    # Set print modes
    %{printer |
      bold: (n &&& 0x08) != 0,
      double_height: (n &&& 0x10) != 0,
      double_width: (n &&& 0x20) != 0,
      underline: (n &&& 0x80) != 0
    }
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?2 | rest]) do
    # Set default line spacing
    %{printer | line_spacing: 30}
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, [?3, n | rest]) do
    # Set line spacing
    %{printer | line_spacing: n}
    |> process_bytes(rest)
  end

  defp process_esc_command(printer, rest) do
    # Unknown ESC command, skip it
    process_bytes(printer, rest)
  end

  defp process_gs_command(printer, [?V, _m | rest]) do
    # Cut paper
    printer
    |> flush_line()
    |> add_cut_marker()
    |> process_bytes(rest)
  end

  defp process_gs_command(printer, [?B, n | rest]) do
    # Set inverse printing
    %{printer | inverse: n == 1}
    |> process_bytes(rest)
  end

  defp process_gs_command(printer, [?h, n | rest]) do
    # Set barcode height
    %{printer | barcode_height: n}
    |> process_bytes(rest)
  end

  defp process_gs_command(printer, [?w, n | rest]) do
    # Set barcode width
    %{printer | barcode_width: n}
    |> process_bytes(rest)
  end

  defp process_gs_command(printer, [?H, n | rest]) do
    # Set barcode text position
    position = case n do
      0 -> :none
      1 -> :above
      2 -> :below
      3 -> :both
      _ -> :below
    end
    %{printer | barcode_text_position: position}
    |> process_bytes(rest)
  end

  defp process_gs_command(printer, [?k, type | rest]) when type <= 6 do
    # Print barcode (format 1)
    {barcode_data, remaining} = extract_barcode_data(rest, type)
    printer
    |> add_barcode(type, barcode_data)
    |> process_bytes(remaining)
  end

  defp process_gs_command(printer, rest) do
    # Unknown GS command, skip it
    process_bytes(printer, rest)
  end

  defp flush_line(printer) do
    if printer.current_line != "" do
      formatted = format_line(printer.current_line, printer)
      %{printer | buffer: [formatted | printer.buffer], current_line: ""}
    else
      printer
    end
  end

  defp format_line(text, printer) do
    text = if printer.bold, do: "**#{text}**", else: text
    text = if printer.underline, do: "__#{text}__", else: text
    text = if printer.inverse, do: "[INV]#{text}[/INV]", else: text
    
    text = case printer.alignment do
      :center -> String.pad_leading(text, div(printer.width + String.length(text), 2))
      :right -> String.pad_leading(text, printer.width)
      _ -> text
    end
    
    if printer.double_width do
      "[2W]#{text}[/2W]"
    else
      text
    end
  end

  defp add_blank_lines(printer, 0), do: printer
  defp add_blank_lines(printer, n) do
    %{printer | buffer: ["" | printer.buffer]}
    |> add_blank_lines(n - 1)
  end

  defp add_cut_marker(printer) do
    %{printer | buffer: ["--- CUT HERE ---" | printer.buffer]}
  end

  defp add_barcode(printer, type, data) do
    barcode_text = "[BARCODE: Type=#{type}, Data=#{inspect(data)}]"
    %{printer | buffer: [barcode_text | printer.buffer]}
  end

  defp extract_barcode_data(bytes, _type) do
    # For simplicity, we'll just extract until we hit a null byte or control character
    {data, rest} = Enum.split_while(bytes, fn b -> b >= 32 end)
    {data, rest}
  end

  defp render_text(printer) do
    printer
    |> flush_line()
    |> Map.get(:buffer)
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  defp render_html(printer) do
    lines = printer
    |> flush_line()
    |> Map.get(:buffer)
    |> Enum.reverse()
    |> Enum.map(&html_escape/1)
    |> Enum.map(&format_html_line/1)
    
    """
    <div style="font-family: 'Courier New', monospace; background: white; padding: 20px; width: #{printer.width}ch; border: 1px solid #ccc;">
    #{Enum.join(lines, "<br>\n")}
    </div>
    """
  end

  defp html_escape(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
  end

  defp format_html_line(line) do
    line
    |> String.replace("**", "<strong>", global: false)
    |> String.replace("**", "</strong>", global: false)
    |> String.replace("__", "<u>", global: false)
    |> String.replace("__", "</u>", global: false)
    |> String.replace("[INV]", "<span style='background: black; color: white;'>", global: false)
    |> String.replace("[/INV]", "</span>", global: false)
    |> String.replace("[2W]", "<span style='transform: scaleX(2); display: inline-block;'>", global: false)
    |> String.replace("[/2W]", "</span>", global: false)
  end
end