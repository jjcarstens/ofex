defmodule Ofex do
  alias Ofex.{BankAccount, InvalidData, Signon}
  import SweetXml

  # @moduledoc """
  # Documentation for Ofex.
  # """
  #
  # @doc """
  # parse
  #
  # ## Examples
  #
  #     iex> Ofex.parse(data)
  #     []
  #
  # """
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
  # defp parse_message_set(message_set) do
  #   case xpath(message_set, ~x"name()"s) do
  #     "SIGNONMSGSRSV1" -> {:test, 1}
  #     "BANKMSGSRSV1" -> BankAccount.create(message_set)
  #   end
  # end

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
