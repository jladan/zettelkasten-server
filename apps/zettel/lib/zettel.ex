defmodule Zettel do
  @moduledoc """
  Documentation for `Zettel`.
  """

  defmodule Link do
    @enforce_keys [:target, :title]
    defstruct [:target, :title, :style]

    def new(target), do: %Link{target: target, title: target}
    def new(target, style: style), do: %Link{target: target, title: target, style: style}
    def new(target, title), do: %Link{target: target, title: title}
    def new(target, title, style: style), do: %Link{target: target, title: title, style: style}
  end


  # a wiki-style link [[target is the title]]
  @wikilink ~r/\[\[(.+?)\]\]/
  # A markdown inline link [Title](url)
  @mdlink ~r/\[(.*?)\]\((.+?)\)/
  # A markdown reference link [identifier]: url title
  # XXX the optional title is not implemented here
  @mdref ~r/\[(.+?)\]:\s+(.*)$/

  @doc """
  Find links inside of a string.
  """
  @spec find_links(String.t()) :: [Link]
  def find_links(content) do
    [&find_wikilink/1, &find_mdlink/1, &find_mdref/1]
    |> Enum.flat_map(fn f -> f.(content) end)
  end

  @spec find_wikilink(String.t()) :: [Link]
  def find_wikilink(content) do
    Regex.scan(@wikilink, content)
    |> Enum.map(&wiki_grp_to_link/1)
  end

  @spec find_mdlink(String.t()) :: [Link]
  def find_mdlink(content) do
    Regex.scan(@mdlink, content)
    |> Enum.map(&md_grp_to_link/1)
  end

  @spec find_mdref(String.t()) :: [Link]
  def find_mdref(content) do
    Regex.scan(@mdref, content)
    |> Enum.map(&mdref_grp_to_link/1)
  end

  defp wiki_grp_to_link([_, middle]) do
    case String.split(middle, "|") do
      [target, title] -> Link.new(target, title, style: :wiki)
      [target] -> Link.new(target, style: :wiki)
    end
  end

  defp md_grp_to_link([_, title, target]) do
    Link.new(target, title, style: :markdown)
  end

  defp mdref_grp_to_link([_, identifier, url]) do
    Link.new(url, identifier, style: :reference)
  end

end
