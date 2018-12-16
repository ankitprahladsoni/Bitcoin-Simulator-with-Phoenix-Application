defmodule HashUtil do
  @difficulty 4
  def hash(data), do: :crypto.hash(:sha256, data) |> Base.encode16()

  def isValidHash?(hash),
    do: String.slice(hash, 0..(@difficulty - 1)) == String.duplicate("0", @difficulty)

  def createPair() do
    {pb, pv} = :crypto.generate_key(:ecdh, :secp256k1)
    {Base.encode16(pb), Base.encode16(pv)}
  end

  def getSign(private_key, data),
    do: :crypto.sign(:ecdsa, :sha256, data, [Base.decode16!(private_key), :secp256k1]) |> Base.encode16()

  def verifySign(public_key, sign, data)
    do
      dSign = Base.decode16!(sign)
      :crypto.verify(:ecdsa, :sha256, data, dSign, [Base.decode16!(public_key), :secp256k1])
end
end
