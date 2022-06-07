defmodule Kasten do
  @moduledoc """
  Documentation for `Kasten`.
  """
  use GenServer

  # Client API {{{
  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Lookup a file in the registry.
  """
  def lookup(server, fname) do
    GenServer.call(server, {:lookup, fname})
  end
  
  @doc """
  Scans a directory for files (notes). This replaces the current set of files.
  """
  def scan_dir(server, directory \\ ".") do
    GenServer.call(server, {:scan_dir, directory})
  end
  

  # }}}

  # GenServer callbacks {{{

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, fileset) do
    {:reply, Kasten.FileSet.fetch(fileset, name), fileset}
  end

  @impl true
  def handle_call({:scan_dir, directory}, _from, _fileset) do
    newset = Kasten.Scanner.scan_dir(directory) |> Enum.reduce(%{}, &Kasten.FileSet.put(&2, &1))
    {:reply, :ok, newset}
  end
  
  # }}}


end
