defmodule ExSbapi.Helper do

	def check_hash(your_hash_key,payload,sb_hash)do
	    hashed_string = :crypto.hmac(:sha256, your_hash_key ,payload) |> Base.encode16(case: :lower)
	    if(hashed_string == sb_hash) do
	      true
	    else
	      false
	    end
	end

	def default_empty_params do
		%{
			filter: %{},
			uri_token: []
		}
	end

	def params_with_order_id(order_id) do
    %{ filter: %{},
       uri_token: [order_id]
     }
  end

  def body_for_mode(restricted,mode,authorized_roles) do
		%{
			restricted: restricted,
			mode: mode,
			authorized_roles: authorized_roles
		}
  end

  def product_redirection(status) do
		%{
			status: status
		}
  end

  def generate_auto_login_link(user_uuid,destination_url) do
	%{
		user_id: user_uuid,
		destination: destination_url
	}
  end


end