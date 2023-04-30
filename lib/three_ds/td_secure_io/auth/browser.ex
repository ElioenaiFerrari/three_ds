defmodule ThreeDs.TdSecureIo.Auth.Browser do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:color_depth, :integer)
    field(:java_enabled, :boolean, default: false)
    field(:javascript_enabled, :boolean, default: false)
    field(:language, :string)
    field(:screen_height, :integer)
    field(:screen_width, :integer)
    field(:tz, :integer)
    field(:accept_header, :string)
    field(:ip, :string)
    field(:user_agent, :string)
  end

  def changeset(browser, attrs \\ %{}) do
    browser
    |> cast(attrs, [
      :color_depth,
      :java_enabled,
      :javascript_enabled,
      :language,
      :screen_height,
      :screen_width,
      :tz,
      :accept_header,
      :ip,
      :user_agent
    ])
    |> validate_required([
      :color_depth,
      :java_enabled,
      :javascript_enabled,
      :language,
      :screen_height,
      :screen_width,
      :tz,
      :accept_header,
      :ip,
      :user_agent
    ])
    |> validate_format(:ip, ~r/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/, message: "invalid IP address")
  end
end
