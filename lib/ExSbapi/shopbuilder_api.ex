defmodule ShopbuilderApi do
	require Logger
	
	defp api_endpoints do
	    api_root = "/api/v1/"
	    %{"order" =>  api_root <> "order/id/!0",
	      "customer_profile" => api_root <> "customer-profile",
	      "payment_options" => api_root <> "order-payment-methods/id/!0",
	      "shipping_options" => api_root <> "order-shipping-methods/id/!0",
        "subscribe" => api_root <> "sb_webhooks/subscribe_webhook",
        "get_events" => api_root <> "sb_webhooks",
        "unsubscribe" => api_root <> "sb_webhooks/unsubscribe_webhook",
        "roles" => api_root <> "sb_roles",
        "restricted" => api_root <> "sb_api_config",
        "countries" => api_root <> "fetch-countries"
	    }
  	end

  defp client(website,access_token) do
    OAuth2.Client.new([site: website,token: access_token])
  end

  def get(website_url,access_token,object, params \\ %{}, format \\ "") do
    url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    client = client(website_url,access_token)
    case OAuth2.Client.get(client,url) do
      {:ok, %OAuth2.Response{status_code: 200,body: response}} ->
        {:ok, format_output(format,response)}
      {:error, %OAuth2.Response{status_code: code, body: body}} ->
        error_handler(code,body)
      {:error, %OAuth2.Error{reason: reason}} ->
        error_handler(500,reason)
    end
  end

  def put(website_url,access_token ,object, body \\ "", params \\ %{}, format \\ "") do
    url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.put(client(website_url,access_token),url, to_json(body),["Content-Type": "application/json"]) do
      {:ok, %OAuth2.Response{status_code: 200,body: response}} ->
        {:ok, format_output(format,response)}
      {:error, %OAuth2.Response{status_code: code, body: body}} ->
        error_handler(code,body)
      {:error, %OAuth2.Error{reason: reason}} ->
        error_handler(500,reason)

    end
  end

  def post(website_url,access_token, object,body \\ "", params \\ %{}, format \\ "") do
     url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.post(client(website_url,access_token),url, body,["Content-Type": "application/json"]) do
      {:ok, %OAuth2.Response{status_code: 200,body: response}} ->
        {:ok, format_output(format,response)}
      {:error, %OAuth2.Response{status_code: code, body: body}} ->
        error_handler(code,body)
      {:error, %OAuth2.Error{reason: reason}} ->
        error_handler(500,reason)
    end
    
  end

  def delete(website_url,access_token, object, params \\ %{}, format \\ "") do
     url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.delete(client(website_url,access_token),url) do
      {:ok, %OAuth2.Response{status_code: 200,body: response}} ->
        {:ok, format_output(format,response)}
      {:error, %OAuth2.Response{status_code: code, body: body}} ->
        error_handler(code,body)
      {:error, %OAuth2.Error{reason: reason}} ->
        error_handler(500,reason)
    end
    
  end

  def error_handler(status_code,reason) do
   logger = case status_code do
      401 ->
        "ExSbapi: Unauthorized token"
      404 ->
        "ExSbapi: No entities found"
      _ ->
        "ExSbapi: #{inspect reason}"
    end

     case Logger.error(logger) do
       :ok ->
        {:error, logger}
      {:error, reason} ->
        {:error, "ExSbapi: Unable to Log the follwing error #{inspect reason}"}
     end

  end

  defp parse_params(params) do
    if(params != %{}) do
      if(params.filter != nil) do
        ret = params.filter 
        |> Enum.reduce("?",fn({k, v}, acc) -> acc = acc <> "parameters[#{k}]=#{v}&" end) 
        else
        ""      
      end
      else
        ""
    end
  end

  defp modify_url(url,params) do

    # replace tokens in commands with parameters
    %{count: _, data: currated_command} = Enum.reduce(params, %{count: 0, data: url}, fn(x, acc) -> 
    # We return a map with the new count (to properly update the pattern) and the new data
    # the data is being replaced incrementally, each time with the new param
    %{count: acc[:count]+1, data: String.replace(acc[:data], "!#{acc[:count]}", x)} end)
    
    currated_command

  end

  defp to_object(x) do
    case Poison.decode(x) do
      {:ok, body} ->
        body
    end
  end

  defp to_json(x) do
    case Poison.encode(x) do
      {:ok, body} ->
        body
    end
  end

	defp format_output(format,response) do
    case format do
      "json" -> 
        response
       _ ->
        to_object(response)
    end
	end

end