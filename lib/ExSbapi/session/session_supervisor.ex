defmodule ExSbapi.Process.SessionSupervisor do
  @moduledoc false
  use DynamicSupervisor
  # use GenServer

  def start_link do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Callback
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def new_process(token) do
    hash_key =
      "TQ67BG4xQ3UdcjlSke3QJO7+ZhAwFqPYGnQcDIRSI8eOW1Xg5vC7G+7tW0XRsGIBV7KDTnL5XIg8iMIbr6p+Nw=="

    hashed = :crypto.hmac(:sha256, hash_key, token) |> Base.encode16(case: :lower)

    child = %{
      id: ExSbapi.Process.Session,
      start: {ExSbapi.Process.Session, :start_link, [hashed]},
      restart: :transient
    }

    supervisor = DynamicSupervisor.start_child(__MODULE__, child)

    case supervisor do
      {:error, :already_present} ->
        Supervisor.restart_child(__MODULE__, hashed)

      _ ->
        supervisor
    end
  end
end
