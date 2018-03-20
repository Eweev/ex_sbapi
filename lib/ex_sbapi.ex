defmodule ExSbapi do
  alias ExSbapi.Helper
  @moduledoc """
  Elixir Wrapper Around Shopbuilder API
  """

  @doc """
  Returns `{:ok,_ }` or `{:error, %{reason: "unauthorized"}}` 

  ## Endpoint: 
  This function is being called from `/lib/RtCheckoutWeb/templates/install/channel.js.eex` by 
  `this.channel.join()`

  ## Params: 
  `checkout:checkout_id` , `message`, `socket`

  ## Functionality: 
  It checks `website_id` and `order_od` that has been sent from `client side` with `website_id` and 
  `order_id` that has been verified in `user_socket`.
  """

  def authorize_url!(provider,scope,client = %{}) do
    case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_authorize_url!(provider,scope,finalized_client_map)
      {:error, reason} ->
        raise reason 
    end
   
  end

  def authorize_url!(provider,scope,_) do
   raise "Please check your third variable it should be %{client_id: _,client_secret: _,website_url: _,redirect_uri: _} For more information what each variable means please check the documation" 
  end

  def get_token!(provider, code, client = %{}) do
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_get_token!(provider,code,finalized_client_map)
      {:error, reason} ->
        raise reason 
    end
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  def refresh_token(refresh_token, client = %{}, params \\ [], headers \\ [], opts \\ []) do
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_refresh_token!(refresh_token,finalized_client_map,params,headers,opts)
      {:error, reason} ->
        raise reason 
    end
  end


  def get_request(%{website_url: website_url,access_token: access_token},%{object: object, params: params, format: format,body: body})do
    ShopbuilderApi.get(website_url,access_token,object,params,format)
  end

  def get_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def post_request(%{website_url: website_url,access_token: access_token},%{object: object, body: body, params: params, format: format})do
    ShopbuilderApi.post(website_url,access_token,object,body,params,format)
  end

  def post_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def put_request(%{website_url: website_url,access_token: access_token},%{object: object, body: body, params: params, format: format})do
    ShopbuilderApi.put(website_url,access_token,object,body,params,format)
  end

  def put_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def delete_request(%{website_url: website_url,access_token: access_token},%{object: object, params: params, format: format,body: body})do
    ShopbuilderApi.delete(website_url,access_token,object,params,format)
  end

  def delete_request(_,_)do
    raise "Make sure all parameters are available"
  end


  def get_address(user_id,website_url,access_token,format \\ "", option \\ "") do
    params =  %{
      filter: %{},
      uri_token: []
    }

    params = case option do
      "" ->
        new_filter = Map.put_new(params.filter, :uid, user_id)
                     |> Map.put_new(:type, "shipping")

        Map.put(params, :filter, new_filter)
      "uuid" ->
        new_filter = Map.put_new(params.filter, :user_uuid, user_id)
        Map.put(params, :filter, new_filter)
    end

    object_params = %{object: "customer_profile", body: "", params: params, format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params) 
  end

  def get_order(order_id,website_url,access_token, format \\ "json") do
    object_params = %{object: "order", body: "", params: Helper.params_with_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  end

  def get_sb_countries(website_url,access_token, format \\ "json") do
    object_params = %{object: "countries", body: "", params: Helper.default_empty_params, format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  end

  def get_payment_options(order_id,website_url,access_token) do
    object_params = %{object: "payment_options", body: "", params: Helper.params_with_order_id(order_id), format: ""}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  
  end

  def get_shipping_options(order_id,website_url,access_token) do
    object_params = %{object: "shipping_options", body: "", params: Helper.params_with_order_id(order_id), format: ""}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)

  end

  def add_email(value,order_id,website_url,access_token,format \\ "json") do

    order_object = %ExSbapi.Order.Mail{
      mail: value
    }

    object_params = %{object: "order", body: order_object, params: Helper.params_with_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)
    
  end

  def add_shipping(value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Shipping{
      shipping: %{
        service: value
      }
    }

    object_params = %{object: "order", body: order_object, params: Helper.params_with_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)  
    
  end

  def add_payment(value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Payment{
      payment: %{
        method: value
      }
    }

    object_params = %{object: "order", body: order_object, params: Helper.params_with_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)    
  end

  def add_coupon(code_value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Coupon{
      coupons: [
        %{code: code_value}
      ]
    }

    object_params = %{object: "order", body: order_object, params: Helper.params_with_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}

    put_request(client_params,object_params)
  end

  def list_of_events(access_token, client \\ %{}) do

    case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "get_events", body: "", params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          get_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end


  def subscribe_to_event(event,endpoint,access_token,client \\ %{}) do

     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "subscribe", body: %{"#{event}" => "#{endpoint}"}, params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def unsubscribe_from_event(endpoint,access_token, client \\ %{}) do

     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "unsubscribe", body: %{"eventIds" => endpoint}, params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def unsubscribe_from_all_events(access_token, client \\ %{}) do

     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "unsubscribe", body: %{"eventIds" => ["all"]}, params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def get_roles(access_token, client \\ %{}) do
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "roles", body: "", params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          get_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end

  end

  def get_payload(your_hash_key,payload,sb_hash,format \\ "") do

    if(Helper.check_hash(your_hash_key,payload,sb_hash))do
      decoded_data = Base.decode64!(payload,padding: false)
      if(format == "")do
        {:ok, data} = Poison.decode(decoded_data)
        data
      else
        decoded_data
      end
    else
      {:error, "Not valid hash key"}
    end

  end

  def get_restricted_mode(access_token,client \\ %{}) do
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "restricted", body: "", params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          get_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def set_restricted_mode(restricted,mode,authorized_roles,access_token,client \\ %{}) do
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "restricted", body: Helper.body_for_mode(restricted,mode,authorized_roles), params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def product_redirections(status,access_token,client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "product_redirections", body: Helper.product_redirection(status), params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  def generate_auto_login_link(user_uuid,destination_url,access_token,client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "auto_login", body: Helper.generate_auto_login_link(user_uuid,destination_url), params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

  @doc """
    This function is expecting `list_of_uuid`,`date`, `access_token` and `client`
    
    The format of date should be:
      date: %{
        start: %{
          year: "2018",
          month: "4",
          day: "12"
        },
        end: %{
          year: "2018",
          month: "4",
          day: "20"
        }
      }
  """

  def order_query(list_of_uuid,date,access_token,client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
          object_params = %{object: "order_query", body: Helper.generate_order_query_object(list_of_uuid,date), params: Helper.default_empty_params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          post_request(client_params,object_params)
      {:error, reason} ->
        raise reason 
    end
  end

end
