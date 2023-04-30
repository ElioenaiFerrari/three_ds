defmodule ThreeDs.Crypto do
  @block_size 16

  def generate_secret do
    :crypto.strong_rand_bytes(@block_size)
    |> Base.encode64()
  end

  def encrypt(plaintext, secret_key) do
    with {:ok, secret_key} <- Base.decode64(secret_key) do
      iv = :crypto.strong_rand_bytes(@block_size)
      plaintext = pad(plaintext, @block_size)
      ciphertext = :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, plaintext, true)

      {:ok, Base.encode64(iv <> ciphertext)}
    end
  end

  def decrypt(ciphertext, secret_key) do
    with {:ok, secret_key} <- Base.decode64(secret_key),
         {:ok, <<iv::binary-@block_size, ciphertext::binary>>} <- Base.decode64(ciphertext) do
      plaintext =
        :crypto.crypto_one_time(:aes_128_cbc, secret_key, iv, ciphertext, false)
        |> unpad

      {:ok, plaintext}
    else
      {:error, _} = err -> err
      _ -> {:error, "Bad encrypted data"}
    end
  end

  defp pad(data, block_size) do
    to_add = block_size - rem(byte_size(data), block_size)
    data <> :binary.copy(<<to_add>>, to_add)
  end

  defp unpad(data) do
    to_remove = :binary.last(data)
    :binary.part(data, 0, byte_size(data) - to_remove)
  end
end
