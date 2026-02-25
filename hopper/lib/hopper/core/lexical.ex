defmodule Hopper.Core.Lexical do
  @moduledoc """
  Helpers for PDF lexical-level constructs defined in ISO 32000-2 §7.2.
  """

  @doc """
  Builds iodata for a PDF comment (ISO 32000-2 §7.2.4).

  A PDF comment begins with `%` outside of a string or stream, extends to
  but does not include the end-of-line marker, and is treated as a single
  whitespace character by the PDF lexer.

  The caller supplies only the comment body text (without the leading `%`);
  this function prepends `%`.

  ## Examples

      iex> IO.iodata_to_binary(Hopper.Core.Lexical.comment("Hello"))
      "%Hello"

      iex> IO.iodata_to_binary(Hopper.Core.Lexical.comment(""))
      "%"

  """
  @spec comment(binary()) :: iodata()
  def comment(text) when is_binary(text) do
    [?%, text]
  end
end
