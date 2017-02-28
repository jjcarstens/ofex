defmodule OfexTest do
  use ExUnit.Case, async: true
  doctest Ofex

  test "validates data is OFX" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    parsed = Ofex.parse(ofx_raw)
    assert is_map(parsed) == true
  end

  test "returns an error if data provided is binary but not OFX" do
    assert {:error, error} = Ofex.parse("You ain't getting past me!")
    assert error == %Ofex.InvalidData{data: "You ain't getting past me!", message: "data provided cannot be parsed. May not be OFX format"}
  end

  test "returns an error if data to parse is not the correct type" do
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(1000)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(true)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(%{})
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse([])
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(fn(x) -> x end)
  end

  test "can parse data with missing closing tags" do
    ofx_raw = File.read!("test/fixtures/missing_closing_tags.ofx")
    parsed = Ofex.parse(ofx_raw)
    assert Map.has_key?(parsed, :signon)
  end

  test "can parse QFX data" do
    ofx_raw = File.read!("test/fixtures/bank_account.qfx")
    parsed = Ofex.parse(ofx_raw)
    assert Map.has_key?(parsed, :bank_account)
    assert Map.has_key?(parsed, :signon)
  end
end
