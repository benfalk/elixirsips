defmodule FridgeServer do
  use GenServer
  
  # Client API
  def start_link(default) do
    {:ok, fridge} = GenServer.start_link(__MODULE__, default)
    fridge
  end

  def store(fridge, item) do
    GenServer.call(fridge, { :store, item })
  end

  def take(fridge, item) do
    GenServer.call(fridge, { :take, item })
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
    fridge = FridgeServer.start_link([])
    assert :ok == FridgeServer.store(fridge, :bacon)
  end

  test "removing something from the fridge" do
    fridge = FridgeServer.start_link([])
    FridgeServer.store(fridge, :bacon)
    assert {:ok, :bacon} = FridgeServer.take(fridge, :bacon)
  end

  test "attempting to take something not in fridge" do
    fridge = FridgeServer.start_link([])
    assert :not_found == GenServer.call(fridge, { :take, :bacon })
  end
end
