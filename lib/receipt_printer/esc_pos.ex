defmodule ReceiptPrinter.EscPos do
  @moduledoc """
  ESC/POS command builder for receipt printers.
  Provides functions to generate properly formatted ESC/POS commands.
  """

  @esc <<0x1B>>
  @gs <<0x1D>>
  @lf <<0x0A>>
  @cr <<0x0D>>
  @fs <<0x1C>>
  @can <<0x18>>

  # Text formatting commands
  def init(), do: @esc <> "@"
  
  def bold(true), do: @esc <> "E" <> <<1>>
  def bold(false), do: @esc <> "E" <> <<0>>
  
  def underline(:single), do: @esc <> "-" <> <<1>>
  def underline(:double), do: @esc <> "-" <> <<2>>
  def underline(false), do: @esc <> "-" <> <<0>>
  
  def align(:left), do: @esc <> "a" <> <<0>>
  def align(:center), do: @esc <> "a" <> <<1>>
  def align(:right), do: @esc <> "a" <> <<2>>
  
  def font_size(:normal), do: @gs <> "!" <> <<0x00>>
  def font_size(:double_width), do: @gs <> "!" <> <<0x10>>
  def font_size(:double_height), do: @gs <> "!" <> <<0x01>>
  def font_size(:double), do: @gs <> "!" <> <<0x11>>
  def font_size(:quad), do: @gs <> "!" <> <<0x33>>
  
  def inverse(true), do: @gs <> "B" <> <<1>>
  def inverse(false), do: @gs <> "B" <> <<0>>
  
  # Line and spacing commands
  def line_feed(), do: @lf
  def line_feed(n) when is_integer(n), do: @esc <> "d" <> <<n>>
  
  def line_spacing(n) when is_integer(n), do: @esc <> "3" <> <<n>>
  def default_line_spacing(), do: @esc <> "2"
  
  # Cut commands
  def cut(:full), do: @gs <> "V" <> <<0>>
  def cut(:partial), do: @gs <> "V" <> <<1>>
  def cut(:full_feed, n), do: @gs <> "V" <> <<65>> <> <<n>>
  def cut(:partial_feed, n), do: @gs <> "V" <> <<66>> <> <<n>>
  
  # Barcode commands
  def barcode_height(n) when n >= 1 and n <= 255, do: @gs <> "h" <> <<n>>
  def barcode_width(n) when n >= 2 and n <= 6, do: @gs <> "w" <> <<n>>
  
  def barcode_text_position(:none), do: @gs <> "H" <> <<0>>
  def barcode_text_position(:above), do: @gs <> "H" <> <<1>>
  def barcode_text_position(:below), do: @gs <> "H" <> <<2>>
  def barcode_text_position(:both), do: @gs <> "H" <> <<3>>
  
  def barcode(:upc_a, data) when byte_size(data) == 11 or byte_size(data) == 12 do
    @gs <> "k" <> <<0>> <> data <> <<0>>
  end
  
  def barcode(:upc_e, data) when byte_size(data) == 6 or byte_size(data) == 7 or byte_size(data) == 8 do
    @gs <> "k" <> <<1>> <> data <> <<0>>
  end
  
  def barcode(:ean13, data) when byte_size(data) == 12 or byte_size(data) == 13 do
    @gs <> "k" <> <<2>> <> data <> <<0>>
  end
  
  def barcode(:ean8, data) when byte_size(data) == 7 or byte_size(data) == 8 do
    @gs <> "k" <> <<3>> <> data <> <<0>>
  end
  
  def barcode(:code39, data) do
    @gs <> "k" <> <<4>> <> data <> <<0>>
  end
  
  def barcode(:itf, data) do
    @gs <> "k" <> <<5>> <> data <> <<0>>
  end
  
  def barcode(:codabar, data) do
    @gs <> "k" <> <<6>> <> data <> <<0>>
  end
  
  def barcode(:code128, data) do
    len = byte_size(data)
    @gs <> "k" <> <<73>> <> <<len>> <> data
  end
  
  # QR Code commands
  def qr_code(data, opts \\ []) do
    size = Keyword.get(opts, :size, 3)
    correction = Keyword.get(opts, :correction, :l)
    
    correction_level = case correction do
      :l -> 48  # 7% correction
      :m -> 49  # 15% correction
      :q -> 50  # 25% correction
      :h -> 51  # 30% correction
      _ -> 48
    end
    
    data_len = byte_size(data)
    pl = rem(data_len, 256)
    ph = div(data_len, 256)
    
    # QR code commands sequence
    @gs <> "(k" <> <<3, 0, 49, 67>> <> <<size>> <>  # Model and size
    @gs <> "(k" <> <<3, 0, 49, 69>> <> <<correction_level>> <>  # Error correction
    @gs <> "(k" <> <<pl + 3, ph, 49, 80, 48>> <> data <>  # Store data
    @gs <> "(k" <> <<3, 0, 49, 81, 48>>  # Print QR code
  end
  
  # Image commands (simplified - actual implementation would need image processing)
  def image(width, height, data) do
    @gs <> "v0" <> <<0>> <>
    <<rem(width, 256)>> <> <<div(width, 256)>> <>
    <<rem(height, 256)>> <> <<div(height, 256)>> <>
    data
  end
  
  # Drawer kick command
  def cash_drawer_kick(pin \\ 0, on_time \\ 50, off_time \\ 50) do
    @esc <> "p" <> <<pin>> <> <<on_time>> <> <<off_time>>
  end
  
  # Helper functions
  def text(string), do: string
  
  def build(commands) when is_list(commands) do
    Enum.join(commands, "")
  end
end