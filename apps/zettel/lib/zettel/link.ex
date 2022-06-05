defmodule Zettel.Link do
  @moduledoc """
  Link structure.
  """

  alias Zettel.Link

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
      [target, title] -> new(target, title, style: :wiki, original: original)
      [target] -> new(target, style: :wiki, original: original)
    end
  end

  def from_md_match([original, title, target]) do
    new(target, title, style: :markdown, original: original)
  end

  def from_mdref_match([original, identifier, url]) do
    new(url, identifier, style: :reference, original: original)
  end
end
