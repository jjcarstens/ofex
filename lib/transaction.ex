defmodule Ofex.Transaction do
  import Ofex.Helpers
  import SweetXml

  def create(ofx_data) do
    ofx_data
    |> transaction_attributes_list
    |> create_attribute_map
  end

  defp transaction_attributes_list(ofx_data) do
    [
      {:type, xpath(ofx_data, ~x"TRNTYPE/text()"s)},
      {:generic_type, xpath(ofx_data, ~x"TRNAMT/text()"s) |> generic_type_from_amount},
      {:posted_date, xpath(ofx_data, ~x"DTPOSTED/text()"s)},
      {:amount, xpath(ofx_data, ~x"TRNAMT/text()"s)},
      {:positive_amount, xpath(ofx_data, ~x"TRNAMT/text()"s)},
      {:fit_id, xpath(ofx_data, ~x"FITID/text()"s)},
      {:name, xpath(ofx_data, ~x"NAME/text()"s)},
      {:memo, xpath(ofx_data, ~x"MEMO/text()"s)},
      {:check_number, xpath(ofx_data, ~x"CHECKNUM/text()"s)}
    ]
  end

  defp generic_type_from_amount("-" <> _amount), do: "DEBIT"
  defp generic_type_from_amount(_amount), do: "CREDIT"
end
