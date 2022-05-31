defmodule Kasten do
  @moduledoc """
  Documentation for `Kasten`.
  """

  def scan_dir(path, opts \\ []) do
    _scan_dir([path], opts)
    |> List.flatten()
  end

  defp _scan_dir(paths, opts \\ [])
  defp _scan_dir([], _opts), do: []
  defp _scan_dir([path | rest], opts) do
    case File.stat(path) do
      {:ok, %File.Stat{type: :directory}} -> [_scan_dir(File.ls!(path) |> Enum.map(&(path <> "/" <> &1)), opts) | _scan_dir(rest, opts)]
      {:ok, %File.Stat{type: :regular}} -> [path | _scan_dir(rest, opts) ] 
      _ -> IO.inspect(path)
        _scan_dir(rest, opts) 
    end
  end
end
