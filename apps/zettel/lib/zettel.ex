defmodule Zettel do
  @moduledoc """
  Documentation for `Zettel`.
  """
  defstruct [:filename, links: [], backlinks: []]

  defmodule Link do
    @moduledoc """
    Link structure.
    """
    @enforce_keys [:target, :title]
    defstruct [:target, :title, :style, :original]

    @doc """
    Create a new Link from `target` with optional `title` and `:style`
    """
    def new(target), do: %Link{target: target, title: target}
    def new(target, opts) when is_list(opts), do: new(target, target, opts)
    def new(target, title), do: %Link{target: target, title: title}
    def new(target, title, opts) when is_list(opts) do
      style = Keyword.get(opts, :style, nil)
      original = Keyword.get(opts, :original, nil)
      %Link{target: target, title: title, style: style, original: original}
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
    
    def from_wiki_match([original, middle]) do
      case String.split(middle, "|") do
        [target, title] -> Link.new(target, title, style: :wiki, original: original)
        [target] -> Link.new(target, style: :wiki, original: original)
      end
    end

    def from_md_match([original, title, target]) do
      Link.new(target, title, style: :markdown, original: original)
    end

    def from_mdref_match([original, identifier, url]) do
      Link.new(url, identifier, style: :reference, original: original)
    end
  end

  @doc """
  Read a file, and extract all the links from it.
  """
  @spec from_file(String.t()) :: Zettel
  def from_file(path) do
    links = File.read!(path)
            |> find_links()
    %Zettel{filename: path, links: links}
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
