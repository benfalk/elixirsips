defmodule FridgeServer do
  use GenServer
  
  # Client API
  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end
  
  # Server callbacks
  def init(items) do
    {:ok, items}
  end
  
  def handle_call({:store, item}, _from, items) do
    {:reply, :ok, [item|items]}
  end

  def handle_call({:take, item}, _from, items) do
    case Enum.member?(items, item) do
      true ->
        {:reply, { :ok, item }, List.delete(items, item)}
      false ->
        {:reply, :not_found, items}
    end
  end
end

defmodule FridgeServerTest do
  use ExUnit.Case

  test "putting something in the fridge" do
    {:ok, fridge} = GenServer.start_link(FridgeServer, [])
    assert :ok == GenServer.call(fridge, { :store, :bacon })
  end

  test "removing something from the fridge" do
    {:ok, fridge} = GenServer.start_link(FridgeServer, [])
    GenServer.call(fridge, { :store, :bacon })
    assert {:ok, :bacon} = GenServer.call(fridge, { :take, :bacon })
  end

  test "attempting to take something not in fridge" do
    {:ok, fridge} = GenServer.start_link(FridgeServer, [])
    assert :not_found == GenServer.call(fridge, { :take, :bacon })
  end
end
