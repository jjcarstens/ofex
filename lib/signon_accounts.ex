defmodule Ofex.SignonAccounts do
  import SweetXml

  def create(ofx_data) do
    accounts = xpath(ofx_data, ~x"//ACCTINFO"l) |> Enum.map(&parse_account/1)
    {:signon_accounts, accounts}
  end

  def parse_account(account_data) do
    account = case xpath(account_data, ~x"//CCACCTINFO"l) do
                [] -> Ofex.BankAccount.create(account_data)
                _match -> Ofex.CreditCardAccount.create(account_data)
              end
    Map.new([account])
  end
end
