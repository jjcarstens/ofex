defmodule Ofex.Signon do
  import SweetXml

  @doc """
  Parses `SIGNONMSGSRSV1` message set for details of the OFX signon response.

  * `:status_code`
  * `:status_severity`
  * `:language`
  * `:financial_institution`

  Returns a tuple that is later used to create a map.

  Example of a typical `SIGNONMSGSRSV1` message:
  ```xml
  <!-- <SIGNONMSGSRSV1> --> <!-- Top level tag parsed out before getting here -->
      <SONRS>
          <STATUS>
              <CODE>0</CODE>
              <SEVERITY>INFO</SEVERITY>
          </STATUS>
          <DTSERVER>20170127110131.603[-5:EST]</DTSERVER>
          <LANGUAGE>ENG</LANGUAGE>
          <FI>
            <ORG>Galactic CU</ORG>
          </FI>
      </SONRS>
  <!-- </SIGNONMSGSRSV1> -->
  ```
  """
  @spec create(binary) :: {:signon, %{}}
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
