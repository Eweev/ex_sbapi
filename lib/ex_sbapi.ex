defmodule ExSbapi do
  @moduledoc """
  Documentation for ExSbapi.
  """

  @subsribe_events %{product_edit: "product_edit",product_add: "product_add"}

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
    ShopbuilderApi.get(website_url,access_token,object,params,format);
  end

  def get_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def post_request(%{website_url: website_url,access_token: access_token},%{object: object, body: body, params: params, format: format})do
    ShopbuilderApi.post(website_url,access_token,object,body,params,format);
  end

  def post_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def put_request(%{website_url: website_url,access_token: access_token},%{object: object, body: body, params: params, format: format})do
    ShopbuilderApi.put(website_url,access_token,object,body,params,format);
  end

  def put_request(_,_)do
    raise "Make sure all parameters are available"
  end

  def delete_request(%{website_url: website_url,access_token: access_token},%{object: object, params: params, format: format,body: body})do
    ShopbuilderApi.delete(website_url,access_token,object,params,format);
  end

  def delete_request(_,_)do
    raise "Make sure all parameters are available"
  end


  def get_address(user_id,order_id,website_url,access_token) do

    params =  %{
      filter: %{
        uid: user_id,
        type: "shipping"
        },
      uri_token: [
        order_id
      ]
    }

    object_params = %{object: "customer_profile", body: "", params: params, format: ""}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  end

  def get_order(order_id,website_url,access_token, format \\ "json") do
    object_params = %{object: "order", body: "", params: fill_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  end

  def get_payment_options(order_id,website_url,access_token) do
    object_params = %{object: "payment_options", body: "", params: fill_order_id(order_id), format: ""}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)
  
  end

  def get_shipping_options(order_id,website_url,access_token) do
    object_params = %{object: "shipping_options", body: "", params: fill_order_id(order_id), format: ""}
    client_params = %{website_url: website_url,access_token: access_token}
    get_request(client_params,object_params)

  end

  def add_email(value,order_id,website_url,access_token,format \\ "json") do

    order_object = %ExSbapi.Order.Mail{
      mail: value
    }

    object_params = %{object: "order", body: order_object, params: fill_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)
    
  end

  def add_shipping(value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Shipping{
      shipping: %{
        service: value
      }
    }

    object_params = %{object: "order", body: order_object, params: fill_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)  
    
  end

  def add_payment(value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Payment{
      payment: %{
        method: value
      }
    }

    object_params = %{object: "order", body: order_object, params: fill_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}
    put_request(client_params,object_params)    
  end

  def add_coupon(code_value,order_id,website_url,access_token,format \\ "json") do
    order_object = %ExSbapi.Order.Coupon{
      coupons: [
        %{code: code_value}
      ]
    }

    object_params = %{object: "order", body: order_object, params: fill_order_id(order_id), format: format}
    client_params = %{website_url: website_url,access_token: access_token}

    put_request(client_params,object_params)
  end

  defp fill_order_id(order_id) do
    %{ filter: %{},
       uri_token: [order_id]
     }
  end

  def list_of_events do
    @subsribe_events
    |> Enum.map( fn {k, v} -> 
      v 

    end)
  end


  def subscribe_to_event(event,endpoint,access_token,client \\ %{}) do
    params =  %{
      filter: %{},
      uri_token: []
    }
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
        if(Map.has_key?(@subsribe_events,event |> String.to_atom())) do
          object_params = %{object: "webhook", body: %{"#{event}" => "#{endpoint}"}, params: params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          put_request(client_params,object_params)
        else
          raise "event is not found"
        end
      {:error, reason} ->
        raise reason 
    end
  end

  def subscribe_from_event(event,endpoint,access_token, client \\ %{}) do
    params =  %{
      filter: %{},
      uri_token: []
    }
     case Config.check_client_params(client) do
      {:ok,finalized_client_map} ->
        if(Map.has_key?(@subsribe_events,event |> String.to_atom())) do
          object_params = %{object: "webhook", body: %{"#{event}" => "#{endpoint}"}, params: params, format: "json"}
          client_params = %{website_url: finalized_client_map.website_url,access_token: access_token}
          put_request(client_params,object_params)
        else
          raise "event is not found"
        end
      {:error, reason} ->
        raise reason 
    end
  end



end
