defmodule Ofex.CreditCardAccountTest do
  use ExUnit.Case, async: true

  @ofx_raw File.read!("test/fixtures/credit_card_response.ofx")

  test "can parse credit card account details" do
    {:ok, %{accounts: [account1, account2]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions1} = account1
    %{transactions: transactions2} = account2

    assert account1 == %{
      account_number: "456712345678910",
      name: nil,
      balance: -304.0,
      balance_date: ~D[2017-02-06],
      currency: "USD",
      positive_balance: 304.0,
      request_id: "0",
      status_code: "0",
      status_severity: "INFO",
      transactions: transactions1,
      transactions_end_date: ~D[2017-02-06],
      transactions_start_date: ~D[1970-01-01],
      type: "CREDIT_CARD"
    }

    assert account2 == %{
      account_number: "000012345678910",
      name: nil,
      balance: -304.0,
      balance_date: ~D[2017-02-06],
      currency: "USD",
      positive_balance: 304.0,
      request_id: "0",
      status_code: "0",
      status_severity: "INFO",
      transactions: transactions2,
      transactions_end_date: ~D[2017-02-06],
      transactions_start_date: ~D[1970-01-01],
      type: "CREDIT_CARD"
    }
  end

  test "can parse credit card transactions" do
    {:ok, %{accounts: [account1, account2]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions1} = account1
    %{transactions: transactions2} = account2

    assert transactions2 == [
      %{
        amount: 87.4,
        check_number: nil,
        fit_id: "4489153042781763450170106002711",
        generic_type: "CREDIT",
        memo: nil,
        name: "ONLINE BANKING PAYMENT PAYPOINT",
        positive_amount: 87.4,
        posted_date: ~D[2017-01-06],
        type: "CREDIT"
      },
      %{
        amount: -137.87,
        check_number: nil,
        fit_id: "448915304272642016122920161229002531",
        generic_type: "DEBIT",
        memo: nil,
        name: "CRAZY FUN EVENT CENTER",
        positive_amount: 137.87,
        posted_date: ~D[2016-12-29],
        type: "DEBIT"
      }
    ]

    assert transactions1 == [
      %{
        amount: 105.51,
        check_number: nil,
        fit_id: "44891530427817642016120987561209002711",
        generic_type: "CREDIT",
        memo: nil,
        name: "ONLINE BANKING PAYMENT PAYPOINT",
        positive_amount: 105.51,
        posted_date: ~D[2016-12-09],
        type: "CREDIT"
      }
    ]
  end
end
