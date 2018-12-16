defmodule Actor do
  use GenServer

  def start_link(keys) do
    GenServer.start_link(__MODULE__, keys)
  end

  def init(keys) do
    schedule_timer(100)
    {:ok, keys}
  end

  def handle_info(:mine, keys) do
    startMining(keys)
    {:noreply, keys}
  end

  def handle_info(:sendMoney, keys) do
    {public, _private} = keys

    other =
      Server.getPeers()
      |> Enum.random()

    IO.puts("Sending Money.")

    amount = Wallet.balance(public)

    if(amount > 10) do
      Wallet.sendTransaction(keys, other, div(amount, 2))
    end

    {:noreply, keys}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :mine, interval)

  defp startMining({public, _private}) do
    BlockChain.mine(public)

    Process.send_after(self(), :sendMoney, 500)
    schedule_timer(1000)
  end
end
