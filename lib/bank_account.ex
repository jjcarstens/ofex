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
  @spec create(binary) :: {:account, %{}}
  def create(ofx_data) do
    bank_account_map =
      ofx_data
      |> bank_account_attributes_list
      |> create_attribute_map

    %{account: bank_account_map}
  end

  defp bank_account_attributes_list(ofx_data) do
    [
      {:account_number, xpath(ofx_data, ~x"//ACCTID/text()"s)},
      {:balance, xpath(ofx_data, ~x"//BALAMT/text()"s)},
      {:balance_date, xpath(ofx_data, ~x"//DTASOF/text()"s)},
      {:currency, xpath(ofx_data, ~x"//CURDEF/text()"s)},
      {:generic_type, ofx_data |> xpath(~x"//ACCTTYPE/text()"s) |> generic_type_from_type},
      {:name, xpath(ofx_data, ~x"//DESC/text()"s)},
      {:positive_balance, xpath(ofx_data, ~x"//BALAMT/text()"s)},
      {:request_id, xpath(ofx_data, ~x"//TRNUID/text()"s)},
      {:routing_number, xpath(ofx_data, ~x"//BANKID/text()"s)},
      {:status_code, xpath(ofx_data, ~x"//CODE/text()"s)},
      {:status_severity, xpath(ofx_data, ~x"//SEVERITY/text()"s)},
      {:transactions, ofx_data |> xpath(~x"//BANKTRANLIST/STMTTRN"l) |> parse_transactions},
      {:transactions_end_date, xpath(ofx_data, ~x"//BANKTRANLIST/DTEND/text()"s)},
      {:transactions_start_date, xpath(ofx_data, ~x"//BANKTRANLIST/DTSTART/text()"s)},
      {:type, xpath(ofx_data, ~x"//ACCTTYPE/text()"s)}
    ]
  end

  defp generic_type_from_type("MONEYMRKT"), do: "SAVINGS"
  defp generic_type_from_type("CREDITLINE"), do: "LINE_OF_CREDIT"
  defp generic_type_from_type("CD"), do: "SAVINGS"
  defp generic_type_from_type(type), do: type

  defp parse_transactions(ofx_transactions) do
    Enum.map(ofx_transactions, &Transaction.create(&1))
  end
end
