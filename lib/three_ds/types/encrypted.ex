defmodule ThreeDs.Types.Encrypted do
  use Ecto.Type
  alias ThreeDs.Crypto

  # we store data as string
  def type, do: :string

  def cast(value) when is_binary(value), do: {:ok, value}

  def cast(_), do: :error

  def dump(nil), do: nil
  # encrypt data before persist to database
  def dump(data) when is_binary(data) do
    with {:ok, secret_key} <- Application.fetch_env(:three_ds, :secret_key),
         {:ok, data} <- Crypto.encrypt(data, secret_key) do
      {:ok, data}
    else
      _ -> :error
    end
  end

  def dump(_), do: :error

  def load(nil), do: nil
  # decrypt data after loaded from database
  def load(data) when is_binary(data) do
    secret_key = Application.fetch_env!(:three_ds, :secret_key)

    case Crypto.decrypt(data, secret_key) do
      {:error, _} -> :error
      ok -> ok
    end
  end

  def load(_), do: :error

  def embed_as(_), do: :dump
end
