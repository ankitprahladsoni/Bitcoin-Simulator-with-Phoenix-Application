defmodule Server do
  use GenServer
  import UTxO

  def start_link(_params) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    Proj4bWeb.Endpoint.subscribe("timer:start", [])
    {:ok, state}
  end

  def handle_info(:update, state) do
    schedule_timer(1_000)
    broadcast("Total Bitcoins Mined per Second and Peer Balance")
    {:noreply, state}
  end

  def handle_info(%{event: "start_timer"}, state) do
    init()
    broadcast("Started timer!")
    schedule_timer(1_000)
    {:noreply, state}
  end

  defp schedule_timer(interval), do: Process.send_after(self(), :update, interval)

  defp broadcast(response) do
    data = %{
      response: response,
      chain: getChain(),
      peers: getPeersWallet()
    }

    # IO.inspect data
    Proj4bWeb.Endpoint.broadcast!("timer:update", "new_time", data)
  end

  def init() do
    :ets.new(:tbl, [:set, :public, :named_table])
    :ets.insert(:tbl, {:bc, []})
    :ets.insert(:tbl, {:txPool, []})
    :ets.insert(:tbl, {:utxo, []})
    peers = Enum.map(1..100,fn _x -> HashUtil.createPair() end)
    Enum.each(peers, fn x -> Actor.start_link(x) end)

    :ets.insert(:tbl, {:peers, getPublicKeys(peers)})
  end

  defp getPublicKeys(peers) do
    Enum.map(peers, fn {public, _private} -> public end)
  end

  def updateChain(block) do
    if BlockChainValidator.validBlock?(block) do
      newUTxOs = Transaction.processTxForBlock(block.blockData, getUTxOs())

      if newUTxOs == nil do
        raise "block doesn't have valid transactions"
      else
        updateBChain(block)
        updateUTxOs(newUTxOs)

        updateTransactionPool(newUTxOs)
      end
    else
      raise "Block is invalid"
    end
  end

  def updateTransactionPool(uTxOs) do
    getTxPool()
    |> Enum.filter(fn tx -> !notInUTxOs(tx, uTxOs) end)
    |> updateTxPool()
  end

  def addToTransactionPool(tx) do
    if TxValidator.validTx?(tx, getUTxOs()) do
      updateTxPool(getTxPool() ++ [tx])
    end
  end

  def getUTxOs(), do: getFromTable(:utxo)

  def updateUTxOs(uTxOs), do: :ets.insert(:tbl, {:utxo, uTxOs})

  def getTxPool(), do: getFromTable(:txPool)

  defp updateTxPool(txPool), do: :ets.insert(:tbl, {:txPool, txPool})

  def getChain(), do: getFromTable(:bc)

  defp updateBChain(block), do: :ets.insert(:tbl, {:bc, [block | getChain()]})
  def getPeers(), do: getFromTable(:peers)

  def getPeersWallet() do
    getPeers()
    |> Enum.map(fn pb -> %{addr: pb, amt: Wallet.balance(pb)} end)
  end

  def getLastestBlock() do
    case :ets.lookup(:tbl, :bc) do
      [{_, [head | _tail]}] -> head
      [{_, []}] -> nil
    end
  end

  defp getFromTable(key) do
    case :ets.lookup(:tbl, key) do
      [{_, value}] -> value
      [] -> []
    end
  end
end
