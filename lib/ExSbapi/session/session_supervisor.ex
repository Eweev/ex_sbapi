defmodule ExSbapi.Process.SessionSupervisor do
	use DynamicSupervisor
	# use GenServer

	def start_link() do
		DynamicSupervisor.start_link(__MODULE__, [] , name: __MODULE__)
	end

	#Callback
	def init(_args) do
		DynamicSupervisor.init(
			strategy: :one_for_one
		)
	end

	def new_process(topic) do
		child = 
			%{
				id: ExSbapi.Process.Session,
				start:  {ExSbapi.Process.Session,:start_link, [topic]},
				restart: :transient
			}
		supervisor = DynamicSupervisor.start_child(__MODULE__, child)

		case supervisor do
			{:error, :already_present} ->
				Supervisor.restart_child(__MODULE__, topic)
			_ ->
				supervisor
		end

	end 
end