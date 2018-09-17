defmodule OfexTest do
  use ExUnit.Case, async: true
  doctest Ofex

  test "validates data is OFX with parse" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    {:ok, %{signon: signon, accounts: accounts}} = Ofex.parse(ofx_raw)
    assert is_list(accounts)
    assert is_map(signon)
  end

  test "does not validate OFX data with parse!" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    %{signon: signon, accounts: accounts} = Ofex.parse!(ofx_raw)
    assert is_list(accounts)
    assert is_map(signon)
  end

  test "parse returns an error tuple if data provided is binary but not OFX" do
    assert {:error, error} = Ofex.parse("You ain't getting past me!")
    assert error == %Ofex.InvalidData{data: "You ain't getting past me!", message: "data provided cannot be parsed. May not be OFX format"}
  end

  test "parse returns an error tuple if data to parse is not the correct type" do
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(1000)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(true)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(%{})
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse([])
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(fn(x) -> x end)
  end

  test "can parse data with missing closing tags" do
    ofx_raw = File.read!("test/fixtures/missing_closing_tags.ofx")
    {:ok, %{signon: _signon}} = Ofex.parse(ofx_raw)
  end

  test "can parse! data with missing closing tags" do
    ofx_raw = File.read!("test/fixtures/missing_closing_tags.ofx")
    %{signon: _signon} = Ofex.parse!(ofx_raw)
  end

  test "can parse QFX data" do
    ofx_raw = File.read!("test/fixtures/bank_account.qfx")
    {:ok, %{accounts: [_bank_account]}} = Ofex.parse(ofx_raw)
  end

  test "can parse! QFX data" do
    ofx_raw = File.read!("test/fixtures/bank_account.qfx")
    %{accounts: [_bank_account]} = Ofex.parse!(ofx_raw)
  end

  test "can parse file with unsafe &" do
    ofx_raw = File.read!("test/fixtures/unsafe_ampersand.ofx")
    {:ok, %{signon: signon}} = Ofex.parse(ofx_raw)
    assert signon.financial_institution == "Whip & Whirl"
  end
end
