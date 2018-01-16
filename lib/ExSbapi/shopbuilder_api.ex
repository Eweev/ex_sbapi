defmodule ShopbuilderApi do
	require Logger
	
	defp api_endpoints do
	    api_root = "/api/v1/"
	    %{"order" =>  api_root <> "order/id/!0",
	      "customer_profile" => api_root <> "customer-profile",
	      "payment_options" => api_root <> "order-payment-methods/id/!0",
	      "shipping_options" => api_root <> "order-shipping-methods/id/!0"
	    }
  	end

  defp client(website,access_token) do
    OAuth2.Client.new([site: website,token: access_token])
  end

  def get(website_url,access_token,object, params \\ %{}, format \\ "") do
    url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    client = client(website_url,access_token)

    case OAuth2.Client.get(client,url) do
      {:ok, %OAuth2.Response{body: response}} ->
        format_output(format,response)
      {:error, %OAuth2.Response{status_code: status_code, body: body}} ->
        Logger.error("Status code: "<> status_code <>" Unauthorized token")
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def put(website_url,access_token ,object, body \\ "", params \\ %{}, format \\ "") do
    url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.put(client(website_url,access_token),url, to_json(body),["Content-Type": "application/json"]) do
      {:ok, %OAuth2.Response{body: response}} ->
        format_output(format,response)
      {:error, %OAuth2.Response{status_code: 401, body: body}} ->
        Logger.error("Unauthorized token")
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
  end

  def post(website_url,access_token, object,body \\ "", params \\ %{}, format \\ "") do
     url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.post(client(website_url,access_token),url, to_json(body),["Content-Type": "application/json"]) do
      {:ok, %OAuth2.Response{body: response}} ->
        format_output(format,response)
      {:error, %OAuth2.Response{status_code: 401, body: body}} ->
        Logger.error("Unauthorized token")
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
    end
    
  end

  def delete(website_url,access_token, object, params \\ %{}, format \\ "") do
     url = modify_url(api_endpoints[object] <> parse_params(params), params.uri_token)
    case OAuth2.Client.delete(client(website_url,access_token),url) do
      {:ok, %OAuth2.Response{body: response}} ->
        format_output(format,response)
      {:error, %OAuth2.Response{status_code: 401, body: body}} ->
        Logger.error("Unauthorized token")
      {:error, %OAuth2.Error{reason: reason}} ->
        Logger.error("Error: #{inspect reason}")
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