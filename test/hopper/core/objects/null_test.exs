defmodule Hoper.Core.Objects.NullTest do
  use ExUnit.Case, async: true

  alias Hoper.Core.Objects
  alias Hoper.Core.Object

  describe "null/0" do
    test "renders as null keyword" do
      assert IO.iodata_to_binary(Object.to_iodata(Objects.null())) == "null"
    end
  end
end
