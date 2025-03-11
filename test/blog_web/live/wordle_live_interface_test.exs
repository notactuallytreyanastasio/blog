defmodule BlogWeb.WordleLiveInterfaceTest do
  use ExUnit.Case, async: true
  
  # This test focuses on the interface of the WordleLive module
  # without testing the actual LiveView integration
  
  # Import the modules we'll test
  alias BlogWeb.WordleLive
  alias Blog.Wordle.Game
  
  test "color_class helper applies correct CSS classes" do
    # Test the static helper functions
    assert WordleLive.color_class(:correct) == "bg-green-600 border-green-600"
    assert WordleLive.color_class(:present) == "bg-yellow-500 border-yellow-500"
    assert WordleLive.color_class(:absent) == "bg-gray-600 border-gray-600"
    assert WordleLive.color_class(nil) == "border-2 border-gray-300"
  end
  
  test "keyboard_color_class helper applies correct CSS classes" do
    assert WordleLive.keyboard_color_class(:correct) == "bg-green-600 text-white"
    assert WordleLive.keyboard_color_class(:present) == "bg-yellow-500 text-white"
    assert WordleLive.keyboard_color_class(:absent) == "bg-gray-600 text-white"
    assert WordleLive.keyboard_color_class(nil) == "bg-gray-200"
  end
  
  test "keyboard_layout includes all required keys" do
    layout = WordleLive.keyboard_layout()
    
    # Test layout structure
    assert length(layout) == 3  # Three rows
    
    # Flatten the layout and check for key keys
    all_keys = List.flatten(layout)
    assert "Enter" in all_keys
    assert "Backspace" in all_keys
    
    # Check that all letters a-z are included
    for letter <- ?a..?z do
      assert <<letter::utf8>> in all_keys
    end
  end
end