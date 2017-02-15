defmodule OfexTest do
  use ExUnit.Case, async: true
  doctest Ofex

  test "can parse checking accounts" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    result = Ofex.parse(ofx_raw)
    assert result == %{
      bank_account: %{
        account_number: "00000000012345678910",
        balance: 1000001.0,
        balance_date: "20170127120000",
        currency: "USD",
        positive_balance: 1000001.0,
        request_id: "0",
        routing_number: "019283745",
        status_code: "0",
        status_severity: "INFO",
        transactions: [
          %{
            amount: -7.0,
            description: "This is where the description is",
            fit_id: "4614806509201701231",
            generic_type: "DEBIT",
            memo: "This is where a memo goes",
            positive_amount: 7.0,
            posted_on: "20170123120000",
            type: "DEBIT"
          },
          %{
            amount: 372.07,
            description: "BUYING ALL THE THINGS",
            fit_id: "4614806509201701201",
            generic_type: "CREDIT",
            memo: "#YOLO",
            positive_amount: 372.07,
            posted_on: "20170120120000",
            type: "CREDIT"
          }
        ],
        type: "CHECKING"
      },
      signon: %{
        financial_institution: "Galactic CU",
        language: "ENG",
        status_code: "0",
        status_severity: "INFO"
      }
    }
  end
end
