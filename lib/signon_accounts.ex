defmodule Ofex.SignonAccounts do
  import SweetXml

  @spec create(binary) :: [%{account: %{}}]
  def create(ofx_data) do
    xpath(ofx_data, ~x"//ACCTINFO"l) |> Enum.map(&parse_account/1)
  end

  defp parse_account(account_data) do
    case xpath(account_data, ~x"//CCACCTINFO"l) do
      [] -> Ofex.BankAccount.create(account_data)
      _match -> Ofex.CreditCardAccount.create(account_data)
    end
  end
end
