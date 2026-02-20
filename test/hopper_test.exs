defmodule HopperTest do
  use ExUnit.Case
  doctest Hopper

  test "greets the world" do
    assert Hopper.hello() == :world
  end
end
