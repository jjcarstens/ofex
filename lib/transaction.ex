defmodule Ofex.Transaction do
  import Ofex.Helpers
  import SweetXml

  def create(ofx_data) do
    xpath(ofx_data, ~x".",
      type: ~x"TRNTYPE/text()"s,
      generic_type: ~x"TRNAMT/text()"s |> transform_by(&generic_type_from_amount/1),
      posted_date: ~x"DTPOSTED/text()"s |> transform_by(&string_to_date/1),
      amount: ~x"TRNAMT/text()"s |> transform_by(&string_to_float/1),
      positive_amount: ~x"TRNAMT/text()"s |> transform_by(&convert_to_positive_float/1),
      fit_id: ~x"FITID/text()"s,
      name: ~x"NAME/text()"s,
      memo: ~x"MEMO/text()"s,
      check_number: ~x"./CHECKNUM/text()"s
    )
  end

  defp generic_type_from_amount("-" <> _amount), do: "DEBIT"
  defp generic_type_from_amount(_amount), do: "CREDIT"
end
