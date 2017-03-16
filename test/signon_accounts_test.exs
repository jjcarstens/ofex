defmodule Ofex.SignonAccountsTest do
  use ExUnit.Case, async: true

  test "can parse banking and credit card accounts from a signon response" do
    ofx_raw = File.read!("test/fixtures/signon_accounts.ofx")
    %{signon_accounts: [%{bank_account: bank_account}, %{credit_card_account: credit_card_account}]} = Ofex.parse(ofx_raw)

    assert bank_account.name == "MY CHECKING ACCOUNT"
    assert credit_card_account.name == "Signature Visa"
  end
end
