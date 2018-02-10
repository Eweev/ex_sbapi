defmodule ExSbapi.Process.Session do
	use GenServer

	def start_link(args) do
		GenServer.start_link(__MODULE__,%{verified: false}, name: String.to_atom(args))
	end

	def init(state) do
		token_duration = Application.get_env(:ex_sbapi,:token_duration) * 1000
		Process.send_after(self(), :kill, token_duration)
		{:ok, state}
	end

	def handle_call(:check_verification, _from, state)do
		{:reply,state.verified,state}
	end

	def handle_cast({:set_verification, payload}, state) do
	    {:noreply, Map.put(state,:verified,payload)}
  	end	

  	def handle_info(:kill, state) do
  		Process.exit(self(), :kill)
  		{:noreply,state}
  	end

end