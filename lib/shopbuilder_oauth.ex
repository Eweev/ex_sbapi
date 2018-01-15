defmodule ShopbuilderOauth do
  use OAuth2.Strategy
  alias OAuth2.Strategy.AuthCode

  defp authorize_url!("shopbuilder",url,scope) do
    authorize_url!([scope: scope, state: "xyz"],url)
  end

  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("shopbuilder", code, website_url) do
    get_token!([code: code],[], website_url)
  end

  defp get_token!(_, _) do
    raise "No matching provider available"
  end
 
  def shopbuilder_client(client_id,client_secret,website_url,redirect_uri) do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      site: website_url,
      authorize_url: website_url <> "/oauth2/authorize",
      token_url: website_url <> "/oauth2/token"
    ])
  end

  def authorize_url!(params \\ [], website_url) do
    OAuth2.Client.authorize_url!(shopbuilder_client(website_url), params)
  end

  def get_token!(params \\ [], headers \\ [], website_url) do
    OAuth2.Client.get_token!(shopbuilder_client(website_url), params, headers)
  end

  def refresh_token!(token, params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.refresh_token(token, params, headers, opts)
  end

  # strategy callbacks
  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end


end