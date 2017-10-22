defmodule Ofex.CreditCardAccount do
  alias Ofex.Transaction
  import Ofex.Helpers
  import SweetXml

  @spec create(binary) :: %{account: %{}}
  def create(ofx_data) do
    credit_card_account_map = ofx_data
                              |> credit_card_attributes_list
                              |> create_attribute_map

    %{account: credit_card_account_map}
  end

  defp credit_card_attributes_list(ofx_data) do
    [
      {:request_id, xpath(ofx_data, ~x"//TRNUID/text()"s)},
      {:status_code, xpath(ofx_data, ~x"//CODE/text()"s)},
      {:status_severity, xpath(ofx_data, ~x"//SEVERITY/text()"s)},
      {:currency, xpath(ofx_data, ~x"//CURDEF/text()"s)},
      {:account_number, xpath(ofx_data, ~x"//ACCTID/text()"s)},
      {:name, xpath(ofx_data, ~x"//DESC/text()"s)},
      {:transactions, ofx_data |> xpath(~x"//BANKTRANLIST/STMTTRN"l) |> parse_transactions},
      {:transactions_end_date, xpath(ofx_data, ~x"//BANKTRANLIST/DTEND/text()"s)},
      {:transactions_start_date, xpath(ofx_data, ~x"//BANKTRANLIST/DTSTART/text()"s)},
      {:balance, xpath(ofx_data, ~x"//BALAMT/text()"s)},
      {:positive_balance, xpath(ofx_data, ~x"//BALAMT/text()"s)},
      {:balance_date, xpath(ofx_data, ~x"//DTASOF/text()"s)},
      {:type, "CREDIT_CARD"}
    ]
  end

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end
