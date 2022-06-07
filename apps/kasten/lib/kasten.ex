defmodule Kasten do
  @moduledoc """
  Documentation for `Kasten`.
  """
  use GenServer

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  # GenServer callbacks {{{
  @impl true
  def handle_call({:lookup, name}, _from, fileset) do
    {:reply, Kasten.FileSet.fetch(fileset, name), fileset}
  end

  @impl true
  def handle_call({:scan_dir}, _from, _fileset) do
    newset = Kasten.Scanner.scan_dir() |> Enum.reduce(%{}, &Kasten.FileSet.put(&2, &1))
    {:reply, :ok, newset}
  end
  
  # }}}


end
