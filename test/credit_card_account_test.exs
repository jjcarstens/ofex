defmodule Ofex.CreditCardAccountTest do
  use ExUnit.Case, async: true

  @ofx_raw File.read!("test/fixtures/credit_card_response.ofx")

  test "can parse credit card account details" do
    {:ok, %{accounts: [account]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions} = account

    assert account == %{
      account_number: "000012345678910",
      name: "",
      balance: -304.0,
      balance_date: ~D[2017-02-06],
      currency: "USD",
      positive_balance: 304.0,
      request_id: "0",
      status_code: "0",
      status_severity: "INFO",
      transactions: transactions,
      type: "CREDIT_CARD"
    }
  end

  test "can parse credit card transactions" do
    {:ok, %{accounts: [account]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions} = account

    assert transactions == [
      %{
        amount: 87.4,
        check_number: "",
        fit_id: "4489153042781763450170106002711",
        generic_type: "CREDIT",
        memo: "",
        name: "ONLINE BANKING PAYMENT PAYPOINT",
        positive_amount: 87.4,
        check_number: "",
        posted_date: ~D[2017-01-06],
        type: "CREDIT"
      },
      %{
        amount: -137.87,
        check_number: "",
        fit_id: "448915304272642016122920161229002531",
        generic_type: "DEBIT",
        memo: "",
        name: "CRAZY FUN EVENT CENTER",
        positive_amount: 137.87,
        check_number: "",
        posted_date: ~D[2016-12-29],
        type: "DEBIT"
      },
      %{
        amount: 105.51,
        check_number: "",
        fit_id: "44891530427817642016120987561209002711",
        generic_type: "CREDIT",
        memo: "",
        name: "ONLINE BANKING PAYMENT PAYPOINT",
        positive_amount: 105.51,
        check_number: "",
        posted_date: ~D[2016-12-09],
        type: "CREDIT"
      }
    ]
  end
end
