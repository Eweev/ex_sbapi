defmodule ShopbuilderOauth do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode


  #Initialize call should be this function where it should be found in router
  def shopbuilder_authorize_url!("shopbuilder",scope,client_params) do
    oauth_authorize_url!([scope: scope, state: "xyz"], client_params)
  end

  #If provider is different than shopbuilder an error will be raised
  def shopbuilder_authorize_url!(_,scope,client_params) do
    raise "No matching provider available"
  end

  def shopbuilder_get_token!("shopbuilder", code, client_params) do
    oauth_get_token!([code: code],[], client_params)
  end

  def shopbuilder_get_token!(_, _) do
    raise "No matching provider available"
  end

  def shopbuilder_refresh_token!(token, client_params, params \\ [], headers \\ [], opts \\ []) do
    case shopbuilder_client(client_params) do
      %OAuth2.Client{} = client ->
        client
        |> Map.put(:token, %{refresh_token: token})
        |> OAuth2.Client.refresh_token(params, headers, opts)
    end
  end
 
  def shopbuilder_client(client_params) do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: client_params.client_id,
      client_secret: client_params.client_secret,
      redirect_uri: client_params.redirect_uri,
      site: client_params.website_url,
      authorize_url: client_params.website_url <> "/oauth2/authorize",
      token_url: client_params.website_url <> "/oauth2/token"
    ])
  end

  def oauth_authorize_url!(params \\ [], client_params) do
    OAuth2.Client.authorize_url!(shopbuilder_client(client_params), params)
  end

  def oauth_get_token!(params \\ [], headers \\ [], client_params) do
    OAuth2.Client.get_token!(shopbuilder_client(client_params), params, headers)
  end

  def oauth_refresh_token!(token, params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.refresh_token(token, params, headers, opts)
  end

  # strategy callbacks
  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

   def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
  
end