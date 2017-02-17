defmodule Ofex do
  alias Ofex.{BankAccount, CreditCardAccount, InvalidData, Signon}
  import SweetXml
  require Logger

  @moduledoc """
  Documentation for Ofex.
  """

  @doc """
  Validates and parses Open Financial Exchange (OFX) data.

  `data` will need to be supplied as a string. Each message set of the OFX data is parsed
  separately and returned as a map with the following keys:
    * `:bank_account` Banking Message Set Response (_BANKMSGSRS_) via `Ofex.BankAccount`
    * `:credit_card_account` Credit Card Message Set Response (_CREDITCARDMSGSRS_) via `Ofex.CreditCardAccount`
    * `:signon` Signon Message Set Response (_SIGNONMSGSRS_) via `Ofex.Signon`

  Parsing errors or invalid data will return a tuple of `{:error, %Ofex.InvalidData{}}` (see `Ofex.InvalidData`)

  ## Examples

      iex > Ofex.parse("<OFX>..actual_ofx_data...</OFX>")
      %{bank_account: %{}, credit_card_account: %{}, signon: %{}}

      iex> Ofex.parse("I am definitely not OFX")
      {:error, %Ofex.InvalidData{message: "data provided cannot be parsed. May not be OFX format", data: "I am definitely not OFX"}}

  ### Only strings are allowed to be passed in for parsing
      iex> Ofex.parse(1234)
      {:error, %Ofex.InvalidData{message: "data is not binary", data: 1234}}

      iex> Ofex.parse(%{whoops: "a daisy"})
      {:error, %Ofex.InvalidData{message: "data is not binary", data: %{whoops: "a daisy"}}}

  ## Unsupported message sets

  Messages sets chunked into a list based on a `*MSGSRS*` match on the name then individually parsed. Support is gradually
  being built out so there may be cases that a message set is matched, but not parsed. The process will complete,
  but those unmatched message sets will be logged to the console and then returned under string key of the
  message set name.

      iex > Ofex.parse("<OFX><UNSUPPORTEDMSGSRSV1>some_data</UNSUPPORTEDMSGSRSV1></OFX>")
      22:22:14.896 [warn]  Skipping unsupported message set: UNSUPPORTEDMSGSRSV1
      %{"UNSUPPORTEDMSGSRSV1" => "some_data"}
  """
  def parse(data) do
    case validate_ofx_data(data) do
      {:ok, parsed_ofx} ->
        parsed_ofx
        |> xpath(~x"//OFX/*[contains(name(),'MSGSRS')]"l)
        |> Enum.map(&parse_message_set(xpath(&1, ~x"name()"s), &1))
        |> Map.new
      {:error, message} -> {:error, %InvalidData{message: message, data: data}}
    end
  end

  defp parse_message_set("SIGNONMSGSRSV1", message_set), do: Signon.create(message_set)
  defp parse_message_set("BANKMSGSRSV1", message_set), do: BankAccount.create(message_set)
  defp parse_message_set("CREDITCARDMSGSRSV1", message_set), do: CreditCardAccount.create(message_set)
  defp parse_message_set(message_set_name, message_set) do
    Logger.warn("Skipping unsupported message set: #{message_set_name}")
    {message_set_name, message_set}
  end

  # TODO: Add more strict checking here
  # TODO: Add support for QFX files as well
  defp validate_ofx_data(data) when is_bitstring(data) do
    case String.match?(data, ~r/<OFX>.*<\/OFX>/is) do
      true -> {:ok, SweetXml.parse(data)}
      false -> {:error, "data provided cannot be parsed. May not be OFX format"}
    end
  end
  defp validate_ofx_data(_), do: {:error, "data is not binary"}
end
