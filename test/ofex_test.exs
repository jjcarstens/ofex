defmodule OfexTest do
  use ExUnit.Case, async: true
  doctest Ofex

  test "can parse banking accounts" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    result = Ofex.parse(ofx_raw)
    assert result == %{
      bank_account: %{
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
        transactions: [
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

  test "can parse credit card accounts" do
    ofx_raw = File.read!("test/fixtures/credit_card_response.ofx")
    result = Ofex.parse(ofx_raw)

    assert result == %{
      credit_card_account: %{
        account_number: "000012345678910",
        balance: -304.0,
        balance_date: ~D[2017-02-06],
        currency: "USD",
        positive_balance: 304.0,
        request_id: "0",
        status_code: "0",
        status_severity: "INFO",
        transactions: [
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
        ],
        type: "CREDIT_CARD"
      },
      signon: %{
        financial_institution: "PNC",
        language: "ENG",
        status_code: "0",
        status_severity: "INFO"
      }
    }
  end

  test "validates data is OFX" do
    ofx_raw = File.read!("test/fixtures/banking_account.ofx")
    parsed = Ofex.parse(ofx_raw)
    assert is_map(parsed) == true
  end

  test "returns an error if data provided is binary but not OFX" do
    assert {:error, error} = Ofex.parse("You ain't getting past me!")
    assert error == %Ofex.InvalidData{data: "You ain't getting past me!", message: "data provided cannot be parsed. May not be OFX format"}
  end

  test "returns an error if data to parse is not the correct type" do
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(1000)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(true)
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(%{})
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse([])
    assert {:error, %Ofex.InvalidData{message: "data is not binary"}} = Ofex.parse(fn(x) -> x end)
  end
end
