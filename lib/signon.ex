defmodule Ofex.Signon do
  import SweetXml

  def create(ofx_data) do
    signon_details = xpath(ofx_data, ~x"SONRS",
                       status_code: ~x"STATUS/CODE/text()"s,
                       status_severity: ~x"STATUS/SEVERITY/text()"s,
                       language: ~x"LANGUAGE/text()"s,
                       financial_institution: ~x"FI/ORG/text()"s,
                     )
    {:signon, signon_details}
  end
end
