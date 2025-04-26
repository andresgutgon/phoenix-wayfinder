defmodule WayfinderTest do
  use ExUnit.Case
  doctest Wayfinder

  test "greets the world" do
    assert Wayfinder.hello() == :world
  end
end
