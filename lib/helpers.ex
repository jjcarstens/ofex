defmodule Ofex.Helpers do
  def convert_to_positive_float(num) when is_float(num), do: Float.to_string(num) |> String.replace("-", "") |> string_to_float
  def convert_to_positive_float(num) when is_integer(num), do: Integer.to_string(num) |> String.replace("-", "") |> string_to_float
  def convert_to_positive_float(num) when is_bitstring(num), do: String.replace(num, "-", "") |> string_to_float
  def convert_to_positive_float(_), do: nil

  def create_attribute_map(attribute_list) when is_list(attribute_list) do
    Map.new(attribute_list, fn(attribute_tuple) -> format_attribute_value(attribute_tuple) end)
  end
  def create_attribute_map(attribute_map) when is_map(attribute_map) do
    create_attribute_map(Map.to_list(attribute_map))
  end

  defp format_attribute_value({attr, ""}), do: {attr, nil}
  defp format_attribute_value({:amount, amount_str}), do: {:amount, string_to_float(amount_str)}
  defp format_attribute_value({:positive_amount, amount_str}), do: {:positive_amount, convert_to_positive_float(amount_str)}
  defp format_attribute_value({:balance, balance_str}), do: {:balance, string_to_float(balance_str)}
  defp format_attribute_value({:balance_date, date_str}), do: {:balance_date, string_to_date(date_str)}
  defp format_attribute_value({:positive_balance, balance_str}), do: {:positive_balance, convert_to_positive_float(balance_str)}
  defp format_attribute_value({:posted_date, date_str}), do: {:posted_date, string_to_date(date_str)}
  defp format_attribute_value(attribute_tuple), do: attribute_tuple

  def string_to_date(date_str) when byte_size(date_str) == 8, do: string_to_date(date_str, "%Y%m%d")
  def string_to_date(date_str, strf_pattern \\ "%Y%m%d%H%M%S")
  def string_to_date(date_str, strf_pattern) when byte_size(date_str) > 0 do
    [cleansed_date_str] = Regex.run(~r/^[[:digit:]]{0,14}/, date_str, capture: :first)
     case Timex.parse(cleansed_date_str, strf_pattern, :strftime) do
       {:ok, naive_date} -> NaiveDateTime.to_date(naive_date)
       {:error, _reason} -> nil
     end
  end
  def string_to_date(_date_str, _strf_pattern), do: nil

  def string_to_float(nil), do: nil
  def string_to_float(""), do: nil
  def string_to_float(str) do
    [float_string] = Regex.run(~r/-{0,1}[\d,]+\.?\d*/, str)
    {float, _} = float_string |> String.replace(",","") |> Float.parse
    float
  end
end
