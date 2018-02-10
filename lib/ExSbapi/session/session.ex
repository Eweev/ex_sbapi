defmodule ExSbapi.Process.Session do
	use GenServer

	def start_link(args) do
		GenServer.start_link(__MODULE__,%{verified: false}, name: String.to_atom(args))
	end

	def init(state) do
		token_duration = (Application.get_env(:ex_sbapi,ExSbapi) 
		|> Keyword.get(:token_duration)) * 1000
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

defmodule ExSbapi.Session do
  import Plug.Conn
  def init(options) do
    options
  end
  
  def call(conn, _opts) do
  	# Here we need to check the validity of the token after Phoenix verification occured
  	# We are supposed to have the token data available in the conn so we can use it

  	# If we have no data we Stop the request execution and consider the request malformed
  	# Only routes that should be protected should use this plug
  	hash_key = "TQ67BG4xQ3UdcjlSke3QJO7+ZhAwFqPYGnQcDIRSI8eOW1Xg5vC7G+7tW0XRsGIBV7KDTnL5XIg8iMIbr6p+Nw=="
    
    if(:crypto.hmac(:sha256, hash_key, token) 
    |> Base.encode16(case: :lower) 
    |> String.to_atom() 
    |> GenServer.call(:check_verification)) do
      # Keep Going
    else
		current_time = System.system_time(:second)
	    check_time = current_time - data.timestamp
	    token_verification_grace_period = Application.get_env(:influence_profile_fields, :token_verification_grace_period)
	    if(check_time > token_verification_grace_period) do
	      # Stop the Request execution and return an error
	    else
	   	  # Keep Going
	    end
    end
  end
end