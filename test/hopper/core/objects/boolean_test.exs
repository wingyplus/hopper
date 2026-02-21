defmodule Hoper.Core.Objects.BooleanTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Objects
  alias Hoper.Core.Object

  describe "boolean/1" do
    test "true value" do
      assert IO.iodata_to_binary(Object.to_iodata(Objects.boolean(true))) == "true"
    end

    test "false value" do
      assert IO.iodata_to_binary(Object.to_iodata(Objects.boolean(false))) == "false"
    end
  end
end
