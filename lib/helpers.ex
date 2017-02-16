defmodule Ofex.Helpers do
  defp add_decimal_if_needed(str) do
    case String.contains?(str, ".") do
      true -> str
      false -> "#{str}.0"
    end
  end

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
    [float_string] = Regex.run(~r/[\d,]+\.?\d*/, str)
    float_string |> add_decimal_if_needed |> String.replace(",","") |> String.to_float
  end
end
