defmodule Kasten.FileSet do
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
