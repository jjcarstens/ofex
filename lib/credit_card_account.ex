defmodule Ofex.CreditCardAccount do
  alias Ofex.Transaction
  import Ofex.Helpers
  import SweetXml

  def create(ofx_data) do
    account = xpath(ofx_data, ~x"CCSTMTTRNRS",
                request_id: ~x"./TRNUID/text()"s,
                status_code: ~x"./STATUS/CODE/text()"s,
                status_severity: ~x"./STATUS/SEVERITY/text()"s,
                currency: ~x"./CCSTMTRS/CURDEF/text()"s,
                account_number: ~x"./CCSTMTRS/CCACCTFROM/ACCTID/text()"s,
                transactions: ~x"./CCSTMTRS/BANKTRANLIST/STMTTRN"l |> transform_by(&parse_transactions(&1)),
                balance: ~x"./CCSTMTRS/LEDGERBAL/BALAMT/text()"f,
                positive_balance: ~x"./CCSTMTRS/LEDGERBAL/BALAMT/text()"s |> transform_by(&string_to_float/1),
                balance_date: ~x"./CCSTMTRS/LEDGERBAL/DTASOF/text()"s,
              ) |> Map.put(:type, "CREDIT_CARD")
    {:credit_card_account, account}
  end

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end
