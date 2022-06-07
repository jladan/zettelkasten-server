defmodule Zettel do
  @moduledoc """
  Zettel (index card) state, implementing Agent OTP spec
  """
  use Agent

  @type zettel :: pid()

  @doc """
  Start a new Zettel process.
  """
  def start_link(opts) do
    case Keyword.fetch(opts, :filename) do
      {:ok, fname} -> Agent.start_link(fn -> Zettel.State.from_file(fname) end)
      {:error} -> Agent.start_link(fn -> Zettel.State.new() end)
    end
  end
  
  @doc """
  Get the filename of a card.
  """
  def filename(zettel) do
    Agent.get(zettel, &(&1.filename))
  end
  
  @doc """
  Get the list of links.
  """
  def links(zettel) do
    Agent.get(zettel, &(&1.links))
  end

  @doc """
  Retrieve the list of backlinks.
  """
  def backlinks(zettel) do
    Agent.get(zettel, &(&1.backlinks))
  end

  @doc """
  Add a backlink to a card.
  """
  @spec backlink(zettel, String.t()) :: :ok
  def backlink(zettel, source) do
    Agent.update(zettel, Zettel.State, :add_backlink, [source])
  end

end
