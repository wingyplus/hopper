defmodule Hoper.Core.Objects.NullTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Object

  describe "nil" do
    test "renders as null keyword" do
      assert IO.iodata_to_binary(Object.to_iodata(nil)) == "null"
    end
  end
end
