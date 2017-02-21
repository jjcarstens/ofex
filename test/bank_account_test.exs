defmodule Ofex.BankAccountTest do
  use ExUnit.Case, async: true

  @ofx_raw File.read!("test/fixtures/banking_account.ofx")

  test "can parse banking account details" do
    %{bank_account: account} = Ofex.parse(@ofx_raw)
    %{transactions: transactions} = account
    
    assert account == %{
      account_number: "00000000012345678910",
      balance: 1000001.0,
      balance_date: ~D[2017-01-27],
      currency: "USD",
      generic_type: "CHECKING",
      positive_balance: 1000001.0,
      request_id: "0",
      routing_number: "019283745",
      status_code: "0",
      status_severity: "INFO",
      transactions: transactions,
      type: "CHECKING"
    }
  end

  test "can parse bank account transactions" do
    %{bank_account: account} = Ofex.parse(@ofx_raw)
    %{transactions: transactions} = account

    assert transactions == [
      %{
        amount: -7.0,
        check_number: "",
        fit_id: "4614806509201701231",
        generic_type: "DEBIT",
        memo: "This is where a memo goes",
        name: "This is where the name is",
        positive_amount: 7.0,
        check_number: "",
        posted_date: ~D[2017-01-23],
        type: "DEBIT"
      },
      %{
        amount: 372.07,
        check_number: "",
        fit_id: "4614806509201701201",
        generic_type: "CREDIT",
        memo: "#YOLO",
        name: "BUYING ALL THE THINGS",
        positive_amount: 372.07,
        check_number: "",
        posted_date: ~D[2017-01-20],
        type: "CREDIT"
      },
      %{
        amount: -40.0,
        check_number: "275",
        fit_id: "3113342346901135",
        generic_type: "DEBIT",
        memo: "",
        name: "CHECK 275 342857403598",
        positive_amount: 40.0,
        posted_date: ~D[2017-01-13],
        type: "CHECK"
      }
    ]
  end
end
