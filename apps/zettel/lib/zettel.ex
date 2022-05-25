defmodule Zettel do
  @moduledoc """
  Documentation for `Zettel`.
  """

  defmodule Link do
    @enforce_keys [:target, :title]
    defstruct [:target, :title, :style, :original, :location]

    @doc """
    Create a new Link from `target` with optional `title` and `:style`
    """
    def new(target), do: %Link{target: target, title: target}
    def new(target, opts) when is_list(opts), do: new(target, target, opts)
    def new(target, title), do: %Link{target: target, title: title}
    def new(target, title, opts) when is_list(opts) do
      style = Keyword.get(opts, :style, nil)
      original = Keyword.get(opts, :original, nil)
      location = Keyword.get(opts, :location, nil)
      %Link{target: target, title: title, style: style, original: original, location: location}
    end

    @doc """
    Convert a link to a string matching the style and link data.
    """
    def to_string(link) do
      case link.style do
        :wiki -> if link.title == link.target do
            "[[#{link.target}]]" 
          else 
            "[[#{link.target}|#{link.title}]]"
          end
        :markdown -> "[#{link.title}](#{link.target})"
        :reference -> "[#{link.title}]: #{link.target}"
        _ -> ""
      end
    end
    ## Conversion functions from regex matches
    
    def from_wiki_match([_, middle]) do
      case String.split(middle, "|") do
        [target, title] -> Link.new(target, title, style: :wiki)
        [target] -> Link.new(target, style: :wiki)
      end
    end

    def from_md_match([_, title, target]) do
      Link.new(target, title, style: :markdown)
    end

    def from_mdref_match([_, identifier, url]) do
      Link.new(url, identifier, style: :reference)
    end
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
