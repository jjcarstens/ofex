defmodule Ofex.BankAccount do
  alias Ofex.Transaction
  import Ofex.Helpers
  import SweetXml

  @doc """
  Parses `BANKMSGSRSV1` message set for bank account data.

  * `:account_number`
  * `:balance`
  * `:balance_date` `Date` representation (i.e. `~D[2017-01-27]`)
  * `:currency` 3 letter ISO-4217 currency identifier
  * `:generic_type` simple representation of the type (i.e. `MONEYMRKT` generic is `SAVINGS`)
  * `:positive_balance` some cases may strictly require a positive balance amount
  * `:request_id`
  * `:routing_number`
  * `:status_code`
  * `:status_severity`
  * `:transactions` parsed transactions formatted with `Ofex.Transaction`
  * `:type`

  Sample `BANKMSGSRSV1` message set:
  ```xml
  <!-- <BANKMSGSRSV1> --> <!-- Top tag parsed out previously -->
      <STMTTRNRS>
          <TRNUID>0</TRNUID>
          <STATUS>
              <CODE>0</CODE>
              <SEVERITY>INFO</SEVERITY>
          </STATUS>
          <STMTRS>
              <CURDEF>USD</CURDEF>
              <BANKACCTFROM>
                  <BANKID>019283745</BANKID>
                  <ACCTID>00000000012345678910</ACCTID>
                  <ACCTTYPE>CHECKING</ACCTTYPE>
              </BANKACCTFROM>
              <BANKTRANLIST>
                  <DTSTART>19700101120000</DTSTART>
                  <DTEND>20170127120000</DTEND>
                  <STMTTRN>
                      <TRNTYPE>DEBIT</TRNTYPE>
                      <DTPOSTED>20170123120000</DTPOSTED>
                      <DTUSER>20170123120000</DTUSER>
                      <TRNAMT>-7.0</TRNAMT>
                      <FITID>0192947576930</FITID>
                      <NAME>This is where the name is</NAME>
                      <MEMO>This is where a memo goes</MEMO>
                  </STMTTRN>
                  <STMTTRN>
                      <TRNTYPE>CREDIT</TRNTYPE>
                      <DTPOSTED>20170120120000</DTPOSTED>
                      <DTUSER>20170120120000</DTUSER>
                      <TRNAMT>372.07</TRNAMT>
                      <FITID>019274659302</FITID>
                      <NAME>BUYING ALL THE THINGS</NAME>
                      <MEMO>#YOLO</MEMO>
                  </STMTTRN>
                  <STMTTRN>
                      <TRNTYPE>CHECK</TRNTYPE>
                      <DTPOSTED>20170113120000</DTPOSTED>
                      <DTUSER>20170113120000</DTUSER>
                      <TRNAMT>-40.0</TRNAMT>
                      <FITID>8373020273630</FITID>
                      <CHECKNUM>275</CHECKNUM>
                      <NAME>CHECK 275 8383933737</NAME>
                  </STMTTRN>
              </BANKTRANLIST>
              <LEDGERBAL>
                  <BALAMT>1000001.00</BALAMT>
                  <DTASOF>20170127120000</DTASOF>
              </LEDGERBAL>
          </STMTRS>
      </STMTTRNRS>
  <!-- </BANKMSGSRSV1> -->
  ```
  """
  @spec create(binary) :: {:bank_account, %{}}
  def create(ofx_data) do
    account = xpath(ofx_data, ~x"STMTTRNRS",
                request_id: ~x"./TRNUID/text()"s,
                status_code: ~x"./STATUS/CODE/text()"s,
                status_severity: ~x"./STATUS/SEVERITY/text()"s,
                currency: ~x"./STMTRS/CURDEF/text()"s,
                routing_number: ~x"./STMTRS/BANKACCTFROM/BANKID/text()"s,
                account_number: ~x"./STMTRS/BANKACCTFROM/ACCTID/text()"s,
                type: ~x"./STMTRS/BANKACCTFROM/ACCTTYPE/text()"s,
                generic_type: ~x"./STMTRS/BANKACCTFROM/ACCTTYPE/text()"s |> transform_by(&generic_type_from_type/1),
                transactions: ~x"./STMTRS/BANKTRANLIST/STMTTRN"l |> transform_by(&parse_transactions/1),
                balance: ~x"./STMTRS/LEDGERBAL/BALAMT/text()"s |> transform_by(&string_to_float/1),
                positive_balance: ~x"./STMTRS/LEDGERBAL/BALAMT/text()"s |> transform_by(&convert_to_positive_float/1),
                balance_date: ~x"./STMTRS/LEDGERBAL/DTASOF/text()"s |> transform_by(&string_to_date/1),
              )
    {:bank_account, account}
  end

  defp generic_type_from_type("MONEYMRKT"), do: "SAVINGS"
  defp generic_type_from_type("CREDITLINE"), do: "LINE_OF_CREDIT"
  defp generic_type_from_type("CD"), do: "SAVINGS"
  defp generic_type_from_type(type), do: type

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end
