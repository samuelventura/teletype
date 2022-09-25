defmodule VtTest do
  use ExUnit.Case
  alias Teletype.Vt

  test "vt basic check" do
    {:error, {"", 255}} = Vt.ch(2)
  end
end
