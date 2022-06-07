defmodule Zettel.State do
  @moduledoc """
  State structure for a Zettel.  For now, contains filename, links, and  backlinks
  """
  defstruct [:filename, links: [], backlinks: []]

  alias Zettel.Link

  def new() do
    %Zettel.State{filename: "test", links: [1,2,3]}
  end
  
  def add_backlink(state, source) do
    Map.update!(state, :backlinks, &([source | &1]))
  end

  @doc """
  Read a file, and extract all the links from it.
  """
  @spec from_file(String.t()) :: Zettel.State
  def from_file(path) do
    links = File.read!(path) |> find_links()
    %Zettel.State{filename: path, links: links}
  end
  # a wiki-style link [[target is the title]]
  @wikilink ~r/\[\[(.+?)\]\]/
  # A markdown inline link [Title](url)
  @mdlink ~r/\[(.*?)\]\((.+?)\)/
  # A markdown reference link [identifier]: url title
  # XXX the optional title is not implemented here
  @mdref ~r/\[(.+?)\]:\s+(.*)$/

  @doc """
  Find links of all kinds inside of a string.
  """
  @spec find_links(String.t()) :: [Link]
  def find_links(content) do
    [&find_wikilink/1, &find_mdlink/1, &find_mdref/1]
    |> Enum.flat_map(fn f -> f.(content) end)
  end

  @spec find_wikilink(String.t()) :: [Link]
  defp find_wikilink(content) do
    Regex.scan(@wikilink, content)
    |> Enum.map(&Link.from_wiki_match/1)
  end

  @spec find_mdlink(String.t()) :: [Link]
  defp find_mdlink(content) do
    Regex.scan(@mdlink, content)
    |> Enum.map(&Link.from_md_match/1)
  end

  @spec find_mdref(String.t()) :: [Link]
  defp find_mdref(content) do
    Regex.scan(@mdref, content)
    |> Enum.map(&Link.from_mdref_match/1)
  end

end
