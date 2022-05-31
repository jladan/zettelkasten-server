defmodule KastenTest do
  use ExUnit.Case
  doctest Kasten

  test "greets the world" do
    assert Kasten.hello() == :world
  end
end
