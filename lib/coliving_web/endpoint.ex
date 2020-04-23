defmodule ColivingWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :coliving

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  def init(_key, config) do
    if config[:load_from_system_env] do
      port =
        Application.get_env(:coliving, :port) ||
          raise "expected the PORT environment variable to be set"

      secret_key_base =
        Application.get_env(:coliving, :secret_key_base) ||
          raise "expected the SECRET_KEY_BASE environment variable to be set"

      host =
        Application.get_env(:coliving, :host) ||
          raise "expected the HOST environment variable to be set"

      database_url =
        Application.get_env(:coliving, :database_url) ||
          raise """
          expected the DATABASE_URL environment variable to be set
          For example: ecto://USER:PASS@HOST/DATABASE
          """

      pool_size = String.to_integer(Application.get_env(:coliving, :pool_size) || "10")

      config =
        config
        |> Keyword.put(:http, [:inet6, port: port])
        |> Keyword.put(:secret_key_base, secret_key_base)
        |> Keyword.put(:host, host)
        |> Keyword.put(:database_url, database_url)
        |> Keyword.put(:pool_size, pool_size)

      {:ok, config}
    else
      {:ok, config}
    end
  end

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_coliving_key",
    signing_salt: "s2W6YZH1"
  ]

  socket "/socket", ColivingWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :coliving,
    gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ColivingWeb.Router
end
