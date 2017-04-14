defmodule Ofex.Signon do
  import Ofex.Helpers
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
    signon_details_map = ofx_data
                         |> signon_details_attributes_list
                         |> create_attribute_map

    %{signon: signon_details_map}
  end

  defp signon_details_attributes_list(ofx_data) do
    [
      {:status_code, xpath(ofx_data, ~x"SONRS/STATUS/CODE/text()"s)},
      {:status_severity, xpath(ofx_data, ~x"SONRS/STATUS/SEVERITY/text()"s)},
      {:language, xpath(ofx_data, ~x"SONRS/LANGUAGE/text()"s)},
      {:financial_institution, xpath(ofx_data, ~x"SONRS/FI/ORG/text()"s)},
    ]
  end
end
