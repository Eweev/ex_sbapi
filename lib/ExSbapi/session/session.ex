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

if Code.ensure_loaded?(Plug) do
	defmodule ExSbapi.Session do
	  import Plug.Conn

	  @hash_key "TQ67BG4xQ3UdcjlSke3QJO7+ZhAwFqPYGnQcDIRSI8eOW1Xg5vC7G+7tW0XRsGIBV7KDTnL5XIg8iMIbr6p+Nw=="

	  defmodule InsecureRequestError do
	    @moduledoc "Error raised when CSRF token is invalid."

	    message =
	      "The request does not contain a valid token, make sure "
	      <> "requests include a valid conn.assigns[:exsbapi_session_data]"

	    defexception message: message, plug_status: 403
	  end

	  defmodule ExpiredGracePeriodError do
	    @moduledoc "Error raised when CSRF token is invalid."

	    message =
	      "The token hasn't been verified. "
	      <> "Make sure you verify tokens before the grace period expires"

	    defexception message: message, plug_status: 403
	  end

	  def init(options) do
	    options
	  end
	  
	  # We define the call function in case this plug should be executed at the endpoint level
	  def call(conn, _opts) do
	  	# Here we need to check the validity of the token after Phoenix verification occured
	  	# We are supposed to have the token data available in the conn so we can use it
	  	if(conn.assigns[:exsbapi_session_data] == nil) do
	  		raise InsecureRequestError
	  	end

	  	# If we have no data we Stop the request execution and consider the request malformed
	  	# Only routes that should be protected should use this plug 
	    data = conn.assigns[:exsbapi_session_data]
	    if(:crypto.hmac(:sha256, @hash_key, conn.assigns[:token]) 
	    |> Base.encode16(case: :lower) 
	    |> String.to_atom() 
	    |> GenServer.call(:check_verification)) do
	      # Keep Going
	      conn
	    else
			current_time = System.system_time(:second)
		    check_time = current_time - data.timestamp
		    token_verification_grace_period = Application.get_env(:ex_sbapi,ExSbapi) |> Keyword.get(:token_verification_grace_period)
		    if(check_time > token_verification_grace_period) do
		      # Stop the Request execution and return an error
		      raise ExpiredGracePeriodError
		    else
		   	  # Keep Going
		   	  conn
		    end
	    end
	  end

	  def set_token_verified(token) do 
	    (:crypto.hmac(:sha256, @hash_key, token))
	    |> Base.encode16(case: :lower) 
	    |> String.to_atom() 
	    |> GenServer.call(:set_verification, true)
	  end
	end
end