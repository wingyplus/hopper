defmodule Hoper.Core.Objects.BooleanTest do
  use ExUnit.Case, async: true

  import Hoper.ObjectHelpers
  alias Hoper.Core.Objects

  describe "boolean/1" do
    test "true value" do
      assert render(Objects.boolean(true)) == "true"
    end

    test "false value" do
      assert render(Objects.boolean(false)) == "false"
    end
  end
end
