defmodule Ofex.Helpers do
  def convert_to_positive_float(num) when is_float(num), do: Float.to_string(num) |> String.replace("-", "") |> string_to_float
  def convert_to_positive_float(num) when is_integer(num), do: Integer.to_string(num) |> String.replace("-", "") |> string_to_float
  def convert_to_positive_float(num) when is_bitstring(num), do: String.replace(num, "-", "") |> string_to_float
  def convert_to_positive_float(_), do: nil

  def string_to_date(nil), do: nil
  def string_to_date(date_str) do
     case Timex.parse(date_str, "%Y%m%d%I%M%S", :strftime) do
       {:ok, naive_date} -> NaiveDateTime.to_date(naive_date)
       {:error, _reason} -> nil
     end
  end

  def string_to_float(nil), do: nil
  def string_to_float(""), do: nil
  def string_to_float(str) do
    [float_string] = Regex.run(~r/-{0,1}[\d,]+\.?\d*/, str)
    {float, _} = float_string |> String.replace(",","") |> Float.parse
    float
  end
end
