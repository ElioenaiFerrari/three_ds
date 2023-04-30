defmodule ThreeDs.TdSecureIo.Fingerprint do
  def decode(urlencoded, :method) do
    urlencoded
    |> Map.fetch!("threeDSMethodData")
    |> Base.decode64!(padding: false)
    |> Poison.decode!()
  end

  def decode(urlencoded, :challenge) do
    urlencoded
    |> Map.fetch!("cres")
    |> Base.decode64!(padding: false)
    |> Poison.decode!()
  end
end
