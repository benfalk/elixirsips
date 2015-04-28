defmodule BankAccount do
  def start do
    await([])
  end

  def await(events) do
    receive do
      {:check_balance, pid} -> divulge_balance(pid, events)
      {:deposit, amount} -> events = deposit(amount, events)
      {:withdraw, amount} -> events = withdraw(amount, events)
    end
    await(events)
  end

  defp withdraw(amount, events) do
    [{:withdrawal, amount} | events]
  end

  defp deposit(amount, events) do
    [{:deposit, amount} | events]
  end

  defp divulge_balance(pid, events) do
    send pid, {:balance, calculate_balance(events)}
  end

  defp calculate_balance(events) do
    deposits = just_deposits(events) |> sum
    withdrawals = just_withdrawals(events) |> sum
    deposits - withdrawals
  end

  defp sum(events) do
    Enum.reduce(events, 0, fn({_, amount}, acc) -> acc + amount end)
  end

  defp just_deposits(events) do
    just_type(events, :deposit)
  end

  defp just_withdrawals(events) do
    just_type(events, :withdrawal)
  end

  defp just_type(events, expected_type) do
    Enum.filter(events, fn({type, _}) -> type == expected_type end)
  end
end

defmodule BankAccountTest do
  use ExUnit.Case
  doctest BankAccount

  test "balance starts at 0" do
    account = spawn_link(BankAccount, :start, [])
    verify_balance_is 0, account
  end

  test "balance increases by amount deposited" do
    account = spawn_link(BankAccount, :start, [])
    send account, {:deposit, 10}
    verify_balance_is 10, account
  end

  test "balance decreased by amount withdrawn" do
    account = spawn_link(BankAccount, :start, [])
    send account, {:deposit, 20}
    send account, {:withdraw, 10}
    verify_balance_is 10, account
  end

  def verify_balance_is(expected_balance, account) do
    send(account, {:check_balance, self})
    assert_receive {:balance, ^expected_balance}
  end
end
