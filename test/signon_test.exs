defmodule Ofex.SignonTest do
  use ExUnit.Case, async: true

  test "parses ofx doc signon response details" do
    %{signon: signon} = Ofex.parse(File.read!("test/fixtures/banking_account.ofx"))

    assert signon == %{
      financial_institution: "Galactic CU",
      language: "ENG",
      status_code: "0",
      status_severity: "INFO"
    }
  end
end
