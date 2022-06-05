defmodule Kasten do
  @moduledoc """
  Documentation for `Kasten`.
  """

  @doc """
  Scan a directory for all files underneath it

  options:
    - :show_hidden (bool, default: false) include hidden files
    - :follow_links (bool, default: false) follow links (unimplemented)
  """
  def scan_dir(path \\ ".", opts \\ []) do
    if path == "." do
      _scan_dir(File.ls!(), _scan_opts(opts))
    else
      _scan_dir([path], _scan_opts(opts))
    end
    |> List.flatten()
  end

  defp _scan_dir([], _opts), do: []
  defp _scan_dir([path | rest], opts) do
    if Keyword.fetch!(opts, :show_hidden) or not hidden?(path) do
      case File.stat(path) do
        {:ok, %File.Stat{type: :directory}} -> 
          [_scan_dir(File.ls!(path) |> Enum.map(&:filename.join(path, &1)), opts) | _scan_dir(rest, opts)]
        {:ok, %File.Stat{type: :regular}} -> [path | _scan_dir(rest, opts) ] 
        _ -> IO.inspect(path)
          _scan_dir(rest, opts) 
      end
    else
      _scan_dir(rest, opts)
    end
  end

  defp _scan_opts(opts) do
    [
      show_hidden: Keyword.get(opts, :show_hidden, false),
      follow_links: Keyword.get(opts, :follow_links, false)
    ]
  end


  def hidden?(path) do
    fname = :filename.basename(path)
    cond do
      fname == "." or fname == ".." -> false
      String.starts_with?(fname, ".") -> true
      true -> false
    end
  end

  defmodule FileSet do
    @moduledoc """
    Store an inventory of files by basename, and account for duplicate names.

    %Map{<basename> : [<absolute_name>]}
    """

    def put(set, fname) do
      bname = :filename.basename(fname)
      absname = :filename.absname(fname)
      Map.update(set, bname, MapSet.new([absname]), &MapSet.put(&1, absname))
    end

    def fetch(set, fname) do
      with bname <- :filename.basename(fname), 
           {:ok, s} <- Map.fetch(set, bname) do
        {:ok, MapSet.to_list(s)}
      end
    end

    def shortest_name(set, fname) do
      with bname <- :filename.basename(fname),
           absname = :filename.absname(fname),
           {:ok, s} <- Map.fetch(set, bname) do
        if MapSet.member?(s, absname) do
          if MapSet.size(s) == 1, do: {:ok, bname}, else: {:ok, absname}
        else
          :error
        end
      end
    end

    def member?(set, fname) do
      with bname <- :filename.basename(fname),
           absname <- :filename.absname(fname),
           {:ok, s} <- Map.fetch(set, bname)
      do
        MapSet.member?(s, absname)
      else
        :error -> false
      end
    end

  end
end
