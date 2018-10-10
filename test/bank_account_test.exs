defmodule Ofex.BankAccountTest do
  use ExUnit.Case, async: true

  @ofx_raw File.read!("test/fixtures/banking_account.ofx")

  test "can parse banking account details" do
    {:ok, %{accounts: [account1, account2]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions1} = account1
    %{transactions: transactions2} = account2

    assert account1 == %{
      account_number: "00000000085245679130",
      name: nil,
      balance: 1000001.0,
      balance_date: ~D[2017-01-27],
      currency: "USD",
      generic_type: "CHECKING",
      positive_balance: 1000001.0,
      request_id: "0",
      routing_number: "019283745",
      status_code: "0",
      status_severity: "INFO",
      transactions: transactions1,
      transactions_end_date: nil,
      transactions_start_date: nil,
      type: "CHECKING"
    }
  
    assert account2 == %{
      account_number: "00000000012345678910",
      balance: 1000001.0, 
      balance_date: ~D[2017-01-27], 
      currency: "USD", 
      generic_type: "CHECKING", 
      name: nil,
      positive_balance: 1000001.0, 
      request_id: "0", 
      routing_number: "019283745", 
      status_code: "0", 
      status_severity: "INFO", 
      transactions: transactions2,
      transactions_end_date: ~D[2017-01-27],
      transactions_start_date: ~D[1970-01-01],
      type: "CHECKING"
    }
  end

  test "can parse bank account transactions" do
    {:ok, %{accounts: [account1, account2]}} = Ofex.parse(@ofx_raw)
    %{transactions: transactions1} = account1
    %{transactions: transactions2} = account2

    assert transactions2 == [
      %{
        amount: -7.0,
        check_number: nil,
        fit_id: "4614806509201701231",
        generic_type: "DEBIT",
        memo: "This is where a memo goes",
        name: "This is where the name is",
        positive_amount: 7.0,
        posted_date: ~D[2017-01-23],
        type: "DEBIT"
      },
      %{
        amount: 372.07,
        check_number: nil,
        fit_id: "4614806509201701201",
        generic_type: "CREDIT",
        memo: "#YOLO",
        name: "BUYING ALL THE THINGS",
        positive_amount: 372.07,
        posted_date: ~D[2017-01-20],
        type: "CREDIT"
      }
    ]

    assert transactions1 == [
      %{
        amount: -40.0,
        check_number: "275",
        fit_id: "3113342346901135",
        generic_type: "DEBIT",
        memo: nil,
        name: "CHECK 275 342857403598",
        positive_amount: 40.0,
        posted_date: ~D[2017-01-13],
        type: "CHECK"
      }
    ]
  end
end
