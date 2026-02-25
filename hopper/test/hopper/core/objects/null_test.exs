defmodule Hopper.Core.Objects.NullTest do
  use ExUnit.Case, async: true

  import Hopper.ObjectHelpers

  describe "nil" do
    test "renders as null keyword" do
      assert render(nil) == "null"
    end
  end
end
