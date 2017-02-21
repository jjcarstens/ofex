defmodule Ofex.Helperstest do
  use ExUnit.Case, async: true

  test "convert_to_positive_float" do
    # Negative floats
    assert Ofex.Helpers.convert_to_positive_float(-1234.56) == 1234.56
    # Negative Integer
    assert Ofex.Helpers.convert_to_positive_float(-1234) == 1234.0
    # Strings
    assert Ofex.Helpers.convert_to_positive_float("-1234.56") == 1234.56
  end

  test "convert_to_positive_float returns nil when unable to convert" do
    assert Ofex.Helpers.convert_to_positive_float(fn(x) -> x end) == nil
  end

  test "string_to_date parses ofx dates" do
    assert Ofex.Helpers.string_to_date("20160303120000") == ~D[2016-03-03]
  end

  test "string_to_date returns nil when unable to parse" do
    assert Ofex.Helpers.string_to_date(nil) == nil
    assert Ofex.Helpers.string_to_date("bad_date") == nil
  end

  test "string_to_float can parse positive and negative values" do
    assert Ofex.Helpers.string_to_float("-1234") == -1234.0
    assert Ofex.Helpers.string_to_float("-1234.56") == -1234.56
  end

  test "string_to_float can parse integer strings" do
    assert Ofex.Helpers.string_to_float("1234") == 1234.0
  end

  test "string_to_float returns nil when unable to parse" do
    assert Ofex.Helpers.string_to_float(nil) == nil
    assert Ofex.Helpers.string_to_float("") == nil
  end
end
