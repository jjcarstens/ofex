defmodule Ofex.CreditCardAccount do
  alias Ofex.Transaction
  import Ofex.Helpers
  import SweetXml

  def create(ofx_data) do
    account = %{
      request_id: xpath(ofx_data, ~x"//TRNUID/text()"s),
      status_code: xpath(ofx_data, ~x"//CODE/text()"s),
      status_severity: xpath(ofx_data, ~x"//SEVERITY/text()"s),
      currency: xpath(ofx_data, ~x"//CURDEF/text()"s),
      account_number: xpath(ofx_data, ~x"//ACCTID/text()"s),
      name: xpath(ofx_data, ~x"//DESC/text()"s),
      transactions: xpath(ofx_data, ~x"//BANKTRANLIST/STMTTRN"l) |> parse_transactions,
      balance: xpath(ofx_data, ~x"//BALAMT/text()"s) |> string_to_float,
      positive_balance: xpath(ofx_data, ~x"//BALAMT/text()"s) |> convert_to_positive_float,
      balance_date: xpath(ofx_data, ~x"//DTASOF/text()"s) |> string_to_date,
      type: "CREDIT_CARD"
    }

    {:credit_card_account, account}
  end

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end
