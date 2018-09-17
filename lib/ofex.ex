defmodule Ofex do
  alias Ofex.{BankAccount, CreditCardAccount, InvalidData, Signon, SignonAccounts}
  import SweetXml
  require Logger

  @moduledoc """
  Documentation for Ofex.
  """

  @doc """
  Validates and parses Open Financial Exchange (OFX) data.

  `data` will need to be supplied as a string. Each message set of the OFX data is parsed
  separately and returned as map containing a `:signon` map and an `:accounts` list.
    * `:accounts` Message Set Response (_BANKMSGSRS_), (_CREDITCARDMSGSRS_), or (_SIGNUPMSGSR_) via `Ofex.BankAccount` or `Ofex.CreditCardAccount`
    * `:signon` Signon Message Set Response (_SIGNONMSGSRS_) via `Ofex.Signon`

  Parsing errors or invalid data will return a tuple of `{:error, %Ofex.InvalidData{}}` (see `Ofex.InvalidData`)

  ## Examples

      iex > Ofex.parse("<OFX>..actual_ofx_data...</OFX>")
      {:ok, %{signon: %{}, accounts: [%{}, %{}, ...}}

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
  @spec parse(String.t) :: {:ok, map()} | {:error, %Ofex.InvalidData{}}
  def parse(data) do
    try do
      validate_ofx_data(data)
    catch
      :exit, ex -> {:error, %InvalidData{message: inspect(ex), data: data}}
    else
      {:error, message} -> {:error, %InvalidData{message: message, data: data}}
      {:ok, parsed_ofx} -> {:ok, format_parsed_ofx_data(parsed_ofx)}
    end
  end

  @doc """
  Same as `parse`, but does not validate data that is passed in and allows exceptions to be raised.

  Returns the parsed data structure

  ## Examples

      iex > Ofex.parse!("<OFX>..actual_ofx_data...</OFX>")
      %{signon: %{}, accounts: [%{}, %{}, ...}
  """
  @spec parse!(String.t) :: map()
  def parse!(data) do
    data
    |> prepare_and_parse_ofx_data
    |> format_parsed_ofx_data
  end

  defp accumulate_parsed_items(%{signon: signon}, %{accounts: accounts}) do
    %{signon: signon, accounts: accounts}
  end

  defp accumulate_parsed_items(%{account: account}, %{accounts: accounts} = acc) do
    Map.put(acc, :accounts, [account | accounts])
  end

  defp accumulate_parsed_items(_, acc), do: acc

  defp cleanup_whitespace(ofx_data) do
    ofx_data
    |> String.replace(~r/>\s+</m, "><")
    |> String.replace(~r/\s+</m, "<")
    |> String.replace(~r/>\s+/m, ">")
  end

  defp escape_predefined_entities(ofx_data) do
    # TODO: Add more entity replacements here
    ofx_data
    |> String.replace(~r/(?!&amp;)&/, "&amp;") # Replace unsafe & with &amp;
  end

  defp format_parsed_ofx_data(parsed_ofx) do
    parsed_ofx
    |> xpath(~x"//OFX/*[contains(name(),'MSGSRS')]"l)
    |> Enum.map(&parse_message_set(xpath(&1, ~x"name()"s), &1))
    |> List.flatten()
    |> Enum.reduce(%{signon: %{}, accounts: []}, &accumulate_parsed_items/2)
  end

  defp parse_message_set("SIGNUPMSGSRSV1", message_set), do: SignonAccounts.create(message_set)
  defp parse_message_set("SIGNONMSGSRSV1", message_set), do: Signon.create(message_set)
  defp parse_message_set("BANKMSGSRSV1", message_set), do: BankAccount.create(message_set)
  defp parse_message_set("CREDITCARDMSGSRSV1", message_set), do: CreditCardAccount.create(message_set)

  defp parse_message_set(message_set_name, message_set) do
    Logger.warn("Skipping unsupported message set: #{message_set_name}")
    {message_set_name, message_set}
  end

  defp prepare_and_parse_ofx_data(ofx_data) do
    ofx_data
    |> remove_headers
    |> cleanup_whitespace
    |> validate_or_write_close_tags
    |> escape_predefined_entities
    |> SweetXml.parse()
  end

  defp remove_headers(ofx_data) do
    [_headers | tail] = String.split(ofx_data, ~r/<OFX>/, include_captures: true)
    Enum.join(tail)
  end

  defp validate_or_write_close_tags(ofx_data) do
    unclosed_tags =
      Regex.scan(~r/<(\w+|\w+.\w+)>[^<]+/, ofx_data, capture: :all_but_first)
      |> Stream.concat()
      |> Stream.uniq()
      |> Stream.reject(&String.match?(ofx_data, ~r/<#{&1}>([^<]+)<\/#{&1}>/))
      |> Enum.join("|")

    String.replace(ofx_data, ~r/<(#{unclosed_tags})>([^<]+)/, "<\\1>\\2</\\1>")
  end

  defp validate_ofx_data(data) when is_bitstring(data) do
    case String.match?(data, ~r/<OFX>.*<\/OFX>/is) do
      true -> {:ok, prepare_and_parse_ofx_data(data)}
      false -> {:error, "data provided cannot be parsed. May not be OFX format"}
    end
  end

  defp validate_ofx_data(_), do: {:error, "data is not binary"}
end
