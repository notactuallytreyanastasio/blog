defmodule ReceiptPrinter.ReceiptBuilder do
  @moduledoc """
  High-level receipt builder with common templates and formatting helpers.
  """
  
  alias ReceiptPrinter.EscPos
  
  defstruct [
    :commands,
    :width
  ]
  
  def new(opts \\ []) do
    %__MODULE__{
      commands: [],
      width: Keyword.get(opts, :width, 48)
    }
  end
  
  # Basic text operations
  
  def text(builder, text) do
    add_command(builder, EscPos.text(text))
  end
  
  def line(builder, text \\ "") do
    builder
    |> text(text)
    |> line_feed()
  end
  
  def line_feed(builder, n \\ 1) do
    command = if n == 1 do
      EscPos.line_feed()
    else
      EscPos.line_feed(n)
    end
    add_command(builder, command)
  end
  
  def blank_lines(builder, n) do
    line_feed(builder, n)
  end
  
  # Text formatting
  
  def bold(builder, text) do
    builder
    |> add_command(EscPos.bold(true))
    |> text(text)
    |> add_command(EscPos.bold(false))
  end
  
  def underline(builder, text, style \\ :single) do
    builder
    |> add_command(EscPos.underline(style))
    |> text(text)
    |> add_command(EscPos.underline(false))
  end
  
  def inverse(builder, text) do
    builder
    |> add_command(EscPos.inverse(true))
    |> text(text)
    |> add_command(EscPos.inverse(false))
  end
  
  def size(builder, text, size) do
    builder
    |> add_command(EscPos.font_size(size))
    |> text(text)
    |> add_command(EscPos.font_size(:normal))
  end
  
  # Alignment
  
  def left(builder, text) do
    builder
    |> add_command(EscPos.align(:left))
    |> text(text)
  end
  
  def center(builder, text) do
    builder
    |> add_command(EscPos.align(:center))
    |> text(text)
    |> add_command(EscPos.align(:left))
  end
  
  def right(builder, text) do
    builder
    |> add_command(EscPos.align(:right))
    |> text(text)
    |> add_command(EscPos.align(:left))
  end
  
  # Complex formatting
  
  def header(builder, text) do
    builder
    |> add_command(EscPos.align(:center))
    |> add_command(EscPos.font_size(:double))
    |> add_command(EscPos.bold(true))
    |> line(text)
    |> add_command(EscPos.bold(false))
    |> add_command(EscPos.font_size(:normal))
    |> add_command(EscPos.align(:left))
  end
  
  def subheader(builder, text) do
    builder
    |> add_command(EscPos.align(:center))
    |> add_command(EscPos.bold(true))
    |> line(text)
    |> add_command(EscPos.bold(false))
    |> add_command(EscPos.align(:left))
  end
  
  def separator(builder, char \\ "-") do
    line(builder, String.duplicate(char, builder.width))
  end
  
  def double_separator(builder) do
    line(builder, String.duplicate("=", builder.width))
  end
  
  # Table formatting
  
  def table_row(builder, columns, widths \\ nil) do
    formatted = format_columns(columns, widths || calculate_widths(columns, builder.width))
    line(builder, formatted)
  end
  
  def item_line(builder, description, price, quantity \\ nil) do
    if quantity do
      # With quantity: "2x Item name     $10.00"
      desc = "#{quantity}x #{description}"
      spaces = builder.width - String.length(desc) - String.length(price)
      line(builder, desc <> String.duplicate(" ", max(spaces, 1)) <> price)
    else
      # Without quantity: "Item name        $10.00"
      spaces = builder.width - String.length(description) - String.length(price)
      line(builder, description <> String.duplicate(" ", max(spaces, 1)) <> price)
    end
  end
  
  def total_line(builder, label, amount, style \\ :normal) do
    spaces = builder.width - String.length(label) - String.length(amount)
    formatted = label <> String.duplicate(" ", max(spaces, 1)) <> amount
    
    case style do
      :bold ->
        builder
        |> add_command(EscPos.bold(true))
        |> line(formatted)
        |> add_command(EscPos.bold(false))
      :double ->
        builder
        |> add_command(EscPos.font_size(:double_height))
        |> add_command(EscPos.bold(true))
        |> line(formatted)
        |> add_command(EscPos.bold(false))
        |> add_command(EscPos.font_size(:normal))
      _ ->
        line(builder, formatted)
    end
  end
  
  # Barcodes and QR codes
  
  def barcode(builder, type, data, opts \\ []) do
    builder = if height = Keyword.get(opts, :height) do
      add_command(builder, EscPos.barcode_height(height))
    else
      builder
    end
    
    builder = if width = Keyword.get(opts, :width) do
      add_command(builder, EscPos.barcode_width(width))
    else
      builder
    end
    
    builder = if position = Keyword.get(opts, :text_position) do
      add_command(builder, EscPos.barcode_text_position(position))
    else
      builder
    end
    
    add_command(builder, EscPos.barcode(type, data))
  end
  
  def qr_code(builder, data, opts \\ []) do
    builder
    |> add_command(EscPos.align(:center))
    |> add_command(EscPos.qr_code(data, opts))
    |> add_command(EscPos.align(:left))
  end
  
  # Paper operations
  
  def cut(builder, type \\ :partial, feed_lines \\ 3) do
    builder
    |> blank_lines(feed_lines)
    |> add_command(EscPos.cut(type))
  end
  
  def init_printer(builder) do
    add_command(builder, EscPos.init())
  end
  
  # Cash drawer
  
  def open_drawer(builder) do
    add_command(builder, EscPos.cash_drawer_kick())
  end
  
  # Build and output
  
  def build(builder) do
    builder.commands
    |> Enum.reverse()
    |> EscPos.build()
  end
  
  def to_binary(builder) do
    build(builder)
  end
  
  # Private functions
  
  defp add_command(builder, command) do
    %{builder | commands: [command | builder.commands]}
  end
  
  defp format_columns(columns, widths) do
    columns
    |> Enum.zip(widths)
    |> Enum.map(fn {text, width} ->
      String.pad_trailing(String.slice(text || "", 0, width), width)
    end)
    |> Enum.join("")
  end
  
  defp calculate_widths(columns, total_width) do
    count = length(columns)
    width_per_column = div(total_width, count)
    List.duplicate(width_per_column, count)
  end
end