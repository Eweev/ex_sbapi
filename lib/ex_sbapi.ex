defmodule ExSbapi do
  alias ExSbapi.Helper

  alias ExSbapi.{
    Product,
    ProductVariation,
    Collection,
    ProductOption
  }

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

  def authorize_url!(provider, scope, client = %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_authorize_url!(provider, scope, finalized_client_map)

      {:error, reason} ->
        raise reason
    end
  end

  def authorize_url!(_, _, _) do
    raise "Please check your third variable it should be %{client_id: _,client_secret: _,website_url: _,redirect_uri: _} For more information what each variable means please check the documentation"
  end

  def get_token!(provider, code, client = %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_get_token!(provider, code, finalized_client_map)

      {:error, reason} ->
        raise reason
    end
  end

  def refresh_token(refresh_token, client = %{}, params \\ [], headers \\ [], opts \\ []) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        ShopbuilderOauth.shopbuilder_refresh_token!(
          refresh_token,
          finalized_client_map,
          params,
          headers,
          opts
        )

      {:error, reason} ->
        raise reason
    end
  end

  def get_request(%{website_url: website_url, access_token: access_token}, %{
        object: object,
        params: params,
        format: format,
        body: _
      }) do
    ShopbuilderApi.get(website_url, access_token, object, params, format)
  end

  def get_request(_, _) do
    raise "Make sure all parameters are available"
  end

  def post_request(%{website_url: website_url, access_token: access_token}, %{
        object: object,
        body: body,
        params: params,
        format: format
      }) do
    ShopbuilderApi.post(website_url, access_token, object, body, params, format)
  end

  def post_request(_, _) do
    raise "Make sure all parameters are available"
  end

  def put_request(%{website_url: website_url, access_token: access_token}, %{
        object: object,
        body: body,
        params: params,
        format: format
      }) do
    ShopbuilderApi.put(website_url, access_token, object, body, params, format)
  end

  def put_request(_, _) do
    raise "Make sure all parameters are available"
  end

  def delete_request(%{website_url: website_url, access_token: access_token}, %{
        object: object,
        params: params,
        format: format,
        body: _
      }) do
    ShopbuilderApi.delete(website_url, access_token, object, params, format)
  end

  def delete_request(_, _) do
    raise "Make sure all parameters are available"
  end

  def get_address(user_id, website_url, access_token, format \\ "", option \\ "") do
    params = %{
      filter: %{},
      uri_token: []
    }

    params =
      case option do
        "" ->
          new_filter =
            params.filter
            |> Map.put_new(:uid, user_id)
            |> Map.put_new(:type, "shipping")

          Map.put(params, :filter, new_filter)

        "uuid" ->
          new_filter = Map.put_new(params.filter, :user_uuid, user_id)
          Map.put(params, :filter, new_filter)

        "uuid && active" ->
          new_filter =
            params.filter
            |> Map.put_new(:user_uuid, user_id)
            |> Map.put_new(:status, 1)

          Map.put(params, :filter, new_filter)
      end

    object_params = %{object: "customer_profile", body: "", params: params, format: format}
    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  def get_order(order_id, website_url, access_token, format \\ "json") do
    object_params = %{
      object: "order",
      body: "",
      params: Helper.params_with_order_id(order_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  def get_sb_countries(website_url, access_token, format \\ "json") do
    object_params = %{
      object: "countries",
      body: "",
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  def get_payment_options(order_id, website_url, access_token) do
    object_params = %{
      object: "payment_options",
      body: "",
      params: Helper.params_with_order_id(order_id),
      format: ""
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  def get_shipping_options(order_id, website_url, access_token) do
    object_params = %{
      object: "shipping_options",
      body: "",
      params: Helper.params_with_order_id(order_id),
      format: ""
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  def add_email(value, order_id, website_url, access_token, format \\ "json") do
    order_object = %ExSbapi.Order.Mail{
      mail: value
    }

    object_params = %{
      object: "order",
      body: order_object,
      params: Helper.params_with_order_id(order_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    put_request(client_params, object_params)
  end

  def add_shipping(value, order_id, website_url, access_token, format \\ "json") do
    order_object = %ExSbapi.Order.Shipping{
      shipping: %{
        service: value
      }
    }

    object_params = %{
      object: "order",
      body: order_object,
      params: Helper.params_with_order_id(order_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    put_request(client_params, object_params)
  end

  def add_payment(value, order_id, website_url, access_token, format \\ "json") do
    order_object = %ExSbapi.Order.Payment{
      payment: %{
        method: value
      }
    }

    object_params = %{
      object: "order",
      body: order_object,
      params: Helper.params_with_order_id(order_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    put_request(client_params, object_params)
  end

  def add_coupon(code_value, order_id, website_url, access_token, format \\ "json") do
    order_object = %ExSbapi.Order.Coupon{
      coupons: [
        %{code: code_value}
      ]
    }

    object_params = %{
      object: "order",
      body: order_object,
      params: Helper.params_with_order_id(order_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}

    put_request(client_params, object_params)
  end

  def list_of_events(access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "get_events",
          body: "",
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def subscribe_to_event(event, endpoint, access_token, client \\ %{}, object \\ "subscribe") do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: object,
          body: %{"#{event}" => "#{endpoint}"},
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def unsubscribe_from_event(endpoint, access_token, client \\ %{}, object \\ "unsubscribe") do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: object,
          body: %{"eventIds" => endpoint},
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def unsubscribe_from_all_events(access_token, client \\ %{}, object \\ "unsubscribe") do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: object,
          body: %{"eventIds" => ["all"]},
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def get_roles(access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "roles",
          body: "",
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def get_payload(your_hash_key, payload, sb_hash, format \\ "") do
    if Helper.check_hash(your_hash_key, payload, sb_hash) do
      decoded_data = Base.decode64!(payload, padding: false)

      if format == "" do
        {:ok, data} = Poison.decode(decoded_data)
        data
      else
        decoded_data
      end
    else
      {:error, "Not valid hash key"}
    end
  end

  def get_restricted_mode(access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "restricted",
          body: "",
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def set_restricted_mode(restricted, mode, authorized_roles, access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "restricted",
          body: Helper.body_for_mode(restricted, mode, authorized_roles),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def get_profile_mobile_number(access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "restricted",
          body: "",
          params: Helper.default_empty_params(),
          format: ""
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        case get_request(client_params, object_params) do
          {:ok, response} ->
            {:ok, response["success"]["profile_mobile_number"]}

          {:error, logger} ->
            {:error, logger}
        end

      {:error, reason} ->
        raise reason
    end
  end

  def set_profile_mobile_number(required, show_on_registration_form, access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "profile_mobile_number",
          body: Helper.body_for_profile_mobile_number(required, show_on_registration_form),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def product_redirections(status, access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "product_redirections",
          body: Helper.product_redirection(status),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def generate_auto_login_link(user_uuid, destination_url, access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "auto_login",
          body: Helper.generate_auto_login_link(user_uuid, destination_url),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

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

  def order_query(list_of_uuid, date, access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "order_query",
          body: Helper.generate_order_query_object(list_of_uuid, date),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def redirection_to_product(status, access_token, client) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "redirection_to_product",
          body: Helper.generate_redirection_to_product_query(status),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def check_email(access_token, email, client \\ %{}) do
    params = %{
      filter: %{},
      uri_token: [
        email
      ]
    }

    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{object: "email", body: "", params: params, format: "json"}

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def buy_link_enable(status, access_token, client) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "buy_link_enable",
          body: Helper.generate_buy_link_enable_body(status),
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        post_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def buy_link_generate(sku, qty, access_token, client) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "buy_link_generate",
          body: "",
          params: Helper.params_with_buy_link(sku, qty),
          format: ""
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def add_customer_profile(params) do
    client_params = %{
      website_url: params.website_url,
      access_token: params.access_token
    }

    object_params = %{
      object: "customer_profile",
      body: params.value,
      params: Helper.default_empty_params(),
      format: params.format
    }

    ExSbapi.post_request(client_params, object_params)
  end

  def add_customer_profile_to_order(params) do
    client_params = %{
      website_url: params.website_url,
      access_token: params.access_token
    }

    object_params = %{
      object: "order",
      body: params.value,
      params: Helper.params_with_order_id(params.order_uuid),
      format: params.format
    }

    ExSbapi.put_request(client_params, object_params)
  end

  @doc """
  Set app settings 

  ## Endpoint: 
  This function is being called from `/lib/zaq_web/controllers/auth_controller.ex` by 
  `callback/2`

  ## Parameters: 
  `website_url::String` , `access_token::String`, `body::Map %{scripts: "", html: "", hash_key: ""}`

  ## Examples: 
      iex> set_app_settings(
        "http:\\merhi.dev.shopbuilder.me", 
        "01a1f82c447c1ffc19f54a8174ae1b8e648cc864",
        %{hash_key: "5tQ4jHbQAqdfjI3cNEqoLAIChw6ZK2BI9tJR9omkzNCAFZS7odwcx+yC5xxTgt47wUg0iaoKuoRyClhU/3+okQ=="}
      )
      {:ok, %{"success": ["App settings has been updated."]}}
  """
  def set_app_settings(website_url, access_token, body) do
    client_params = %{
      website_url: website_url,
      access_token: access_token
    }

    object_params = %{
      object: "settings",
      body: body,
      params: Helper.default_empty_params(),
      format: ""
    }

    ExSbapi.post_request(client_params, object_params)
  end

  def get_subscribed_emails(access_token, client \\ %{}) do
    case Config.check_client_params(client) do
      {:ok, finalized_client_map} ->
        object_params = %{
          object: "get_subscribed_emails",
          body: "",
          params: Helper.default_empty_params(),
          format: "json"
        }

        client_params = %{
          website_url: finalized_client_map.website_url,
          access_token: access_token
        }

        get_request(client_params, object_params)

      {:error, reason} ->
        raise reason
    end
  end

  def subscribe_email(event, endpoint, access_token, client \\ %{}) do
    subscribe_to_event(event, endpoint, access_token, client, "subscribe_email")
  end

  def unsubscribe_email(endpoint, access_token, client \\ %{}) do
    unsubscribe_from_event(endpoint, access_token, client, "unsubscribe_email")
  end

  def unsubscribe_email_all(access_token, client \\ %{}) do
    unsubscribe_from_all_events(access_token, client, "unsubscribe_email")
  end

  def get_custom_shipping(website_url, access_token) do
    client_params = %{
      website_url: website_url,
      access_token: access_token
    }

    object_params = %{
      object: "custom_shipping",
      body: "",
      params: Helper.default_empty_params(),
      format: "json"
    }

    ExSbapi.get_request(client_params, object_params)
  end

  def add_custom_shipping(website_url, access_token, body) do
    client_params = %{
      website_url: website_url,
      access_token: access_token
    }

    object_params = %{
      object: "custom_shipping",
      body: body,
      params: Helper.default_empty_params(),
      format: "json"
    }

    ExSbapi.post_request(client_params, object_params)
  end

  def update_custom_shipping(website_url, access_token, body, method_name) do
    client_params = %{
      website_url: website_url,
      access_token: access_token
    }

    object_params = %{
      object: "update_custom_shipping",
      body: body,
      params: Helper.params_with_custom_shipping_method(method_name),
      format: "json"
    }

    ExSbapi.put_request(client_params, object_params)
  end

  def delete_custom_shipping(website_url, access_token, method_name) do
    client_params = %{
      website_url: website_url,
      access_token: access_token
    }

    object_params = %{
      object: "delete_custom_shipping",
      body: "",
      params: Helper.params_with_custom_shipping_method(method_name),
      format: "json"
    }

    ExSbapi.delete_request(client_params, object_params)
  end

  @doc """

  Builds a new `ExSbapi.ProductVariation` struct using the provided arguments.

  ## Arguments

  * `sku` - a unique string for the product variation.
  * `stock` - an integer, quantity of the variation
  * `price` - a `ExSbapi.Price` struct
  * `dimensions` - a `ExSbapi.ProductDimensions` struct
  * `weight` - a `ExSbapi.ProductWeight` struct
  * `status` - "0" or "1"
  * `images` - a list of images
  * `options` - options
  * `old_price` - a `ExSbapi.Price` struct

  """
  @spec build_product_variation(
          binary,
          integer,
          Price.t(),
          ProductDimensions.t(),
          ProductWeight.t(),
          binary,
          list,
          map,
          Price.t()
        ) :: ProductVariation.t()
  def build_product_variation(
        sku,
        stock,
        price,
        dimensions \\ nil,
        weight \\ nil,
        status \\ "1",
        images \\ nil,
        options \\ nil,
        old_price \\ nil
      ) do
    ProductVariation.new(
      sku,
      stock,
      price,
      dimensions,
      weight,
      status,
      images,
      options,
      old_price
    )
  end

  @doc """

  Builds a new `ExSbapi.Product` struct using the provided arguments.

  ## Arguments

  * `title` - title of the product.
  * `variations` - a list of `ExSbapi.ProductVariation` structs
  * `collections` - a list of `ExSbapi.ProductType` structs
  * `description` -  description of the product.
  * `status` - "0" or "1"
  * `images` - a list of images
  * `ref` - a reference string
  * `language` - language code ex. "en"
  * `new` - boolean, to indicate if product is new 
  * `on_sale` - boolean, to indicate if product is on sale 
  * `same_price` - boolean, to indicate if all product variations has the same price 
  * `price` - a `ExSbapi.Price` struct (will apply to all variations)
  * `same_weight_dimensions` - boolean, to indicate if all product variations has the same dimensions and weight
  * `weight` - a `ExSbapi.ProductWeight` struct (will apply to all variations)
  * `dimensions` - a `ExSbapi.ProductDimensions` struct (will apply to all variations)
  * `suggested_products` - a list of suggested products
  * `seo` - a tupple containing seo fields
  * `type` - ex. "shop_builder_display"

  """
  @spec build_product(
          binary,
          list,
          list,
          any,
          binary,
          list,
          binary,
          binary,
          boolean,
          boolean,
          boolean,
          Price.t(),
          boolean,
          ProductWeight.t(),
          ProductDimensions.t(),
          list,
          map,
          binary
        ) :: Product.t()

  def build_product(
        title,
        variations,
        collections,
        description \\ "",
        status \\ "1",
        images \\ [],
        ref \\ "",
        language \\ "en",
        new \\ true,
        on_sale \\ false,
        same_price \\ false,
        price \\ nil,
        same_weight_dimensions \\ false,
        weight \\ nil,
        dimensions \\ nil,
        suggested_products \\ nil,
        seo \\ nil,
        type \\ "shop_builder_display"
      ) do
    Product.new(
      title,
      variations,
      collections,
      description,
      status,
      images,
      ref,
      language,
      new,
      on_sale,
      same_price,
      price,
      same_weight_dimensions,
      weight,
      dimensions,
      suggested_products,
      seo,
      type
    )
  end

  @doc """

  Builds a new `ExSbapi.Collection` struct using the provided arguments.

  ## Arguments

  * `title` - a unique string for the product variation.
  * `description` - description for the variarion
  * `image` - an `Image` struct
  * `ref` - a reference string

  """
  @spec build_collection(binary, any, map, binary) :: Collection.t()

  def build_collection(title, description \\ "", image \\ nil, ref \\ "") do
    Collection.new(title, description, image, ref)
  end

  @doc """

  Creates a product collection to the given `website_url` using the provided arguments.

  ## Arguments

  * `title` - a unique string for the product variation.
  * `description` - description for the variarion
  * `image` - an `Image` struct
  * `ref` - a reference string

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """

  @spec add_collection(binary, binary, any, binary, any, map, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def add_collection(
        website_url,
        access_token,
        title,
        description \\ "",
        image \\ nil,
        ref \\ "",
        format \\ "json"
      ) do
    collection_object = build_collection(title, description, image, ref)

    object_params = %{
      object: "collection",
      body: collection_object,
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Creates a product to the given `website_url` with a provided `product_object`.

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec add_product(binary, binary, Product.t(), binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def add_product(website_url, access_token, product_object, format \\ "json") do
    object_params = %{
      object: "product",
      body: product_object,
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Creates a product to the given `website_url` with the provided arguments.

  ## Arguments

  * `title` - title of the product.
  * `variations` - a list of `ExSbapi.ProductVariation` structs
  * `collections` - a list of `ExSbapi.ProductType` structs
  * `description` -  description of the product.
  * `status` - "0" or "1"
  * `images` - a list of images
  * `ref` - a reference string
  * `language` - language code ex. "en"
  * `new` - boolean, to indicate if product is new 
  * `on_sale` - boolean, to indicate if product is on sale 
  * `same_price` - boolean, to indicate if all product variations has the same price 
  * `price` - a `ExSbapi.Price` struct (will apply to all variations)
  * `same_weight_dimensions` - boolean, to indicate if all product variations has the same dimensions and weight
  * `weight` - a `ExSbapi.ProductWeight` struct (will apply to all variations)
  * `dimensions` - a `ExSbapi.ProductDimensions` struct (will apply to all variations)
  * `suggested_products` - a list of suggested products
  * `seo` - a tupple containing seo fields
  * `type` - ex. "shop_builder_display"

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec add_product(binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def add_product(
        website_url,
        access_token,
        title,
        variations,
        collections,
        description \\ "",
        status \\ "1",
        images \\ [],
        ref \\ "",
        language \\ "en",
        new \\ true,
        on_sale \\ false,
        same_price \\ false,
        price \\ nil,
        same_weight_dimensions \\ false,
        weight \\ nil,
        dimensions \\ nil,
        suggested_products \\ nil,
        seo \\ nil,
        type \\ "shop_builder_display",
        format \\ "json"
      ) do
    product_object =
      build_product(
        title,
        variations,
        collections,
        description,
        status,
        images,
        ref,
        language,
        new,
        on_sale,
        same_price,
        price,
        same_weight_dimensions,
        weight,
        dimensions,
        suggested_products,
        seo,
        type
      )

    object_params = %{
      object: "product",
      body: product_object,
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Gets the option with the given `option_id` from the given `website_url`.

  Makes a `GET` request to the given `website_url` using the `OAuth2.AccessToken`

  """
  @spec get_option(integer, binary, binary, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def get_option(option_id, website_url, access_token, format \\ "json") do
    object_params = %{
      object: "option_id",
      body: "",
      params: Helper.params_with_option_id(option_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  @doc """

  Creates a product option to the given `website_url` with the provided arguments.

  ## Arguments

  * `name` - name of the option.
  * `bundle_type` - "shop_builder" or "digital_goods", bundle type to which this option is available.
  * `is_attribute` - boolean, to indicate if this option is an attribute.
  * `is_searchable` -  boolean, to indicate if this option should be added as a filter in the shop page.
  * `is_default_visible` - boolean, to indicate if this option should show when adding products.
  * `show_as_button` - boolean, to indicate if this option should show as a button in the product page.

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec add_option(
          binary,
          binary,
          any,
          boolean,
          boolean,
          boolean,
          boolean,
          binary,
          binary
        ) :: {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def add_option(
        website_url,
        access_token,
        name,
        is_attribute \\ false,
        is_searchable \\ false,
        is_default_visible \\ false,
        show_as_button \\ false,
        bundle_type \\ "shop_builder",
        format \\ "json"
      ) do
    option_object =
      ProductOption.new(
        name: name,
        bundle_type: bundle_type,
        is_attribute: is_attribute,
        is_searchable: is_searchable,
        is_default_visible: is_default_visible,
        show_as_button: show_as_button
      )

    object_params = %{
      object: "option",
      body: option_object,
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Updates a product option with the given `option_id` to the given `website_url` with the provided arguments.

  ## Arguments

  * `option_id` - id of the option.
  * `name` - name of the option.
  * `bundle_type` - bundle type to which this option is available.
  * `is_attribute` - boolean, to indicate if this option is an attribute.
  * `is_searchable` -  boolean, to indicate if this option should be added as a filter in the shop page.
  * `is_default_visible` - boolean, to indicate if this option should show when adding products.
  * `show_as_button` - boolean, to indicate if this option should show as a button in the product page.

  Makes a `PUT` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec update_option(
          integer,
          binary,
          binary,
          any,
          boolean,
          boolean,
          boolean,
          boolean,
          binary,
          binary
        ) :: {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def update_option(
        option_id,
        website_url,
        access_token,
        name,
        is_attribute \\ false,
        is_searchable \\ false,
        is_default_visible \\ false,
        show_as_button \\ false,
        bundle_type \\ "shop_builder",
        format \\ "json"
      ) do
    option_object =
      ProductOption.new(
        name: name,
        bundle_type: bundle_type,
        is_attribute: is_attribute,
        is_searchable: is_searchable,
        is_default_visible: is_default_visible,
        show_as_button: show_as_button
      )

    object_params = %{
      object: "option_id",
      body: option_object,
      params: Helper.params_with_option_id(option_id),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    put_request(client_params, object_params)
  end

  @doc """

  Deletes the option with the given `option_id` from the given `website_url`.

  Makes a `DELETE` request to the given `website_url` using the `OAuth2.AccessToken`

  """
  @spec delete_option(integer, binary, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def delete_option(option_id, website_url, access_token) do
    object_params = %{
      object: "option_id",
      body: "",
      params: Helper.params_with_option_id(option_id),
      format: "json"
    }

    client_params = %{website_url: website_url, access_token: access_token}
    delete_request(client_params, object_params)
  end

  @doc """

  Fetchs all products from the given `website_url`.

  Makes a `GET` request to the given `website_url` using the `OAuth2.AccessToken`

  """
  @spec get_products(binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def get_products(website_url, access_token, fields \\ nil, filter \\ %{}, format \\ "json") do
    object_params = %{
      object: "product",
      body: "",
      params: Helper.params(filter, fields),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  @doc """

  Fetchs all product collections from the given `website_url`.

  Makes a `GET` request to the given `website_url` using the `OAuth2.AccessToken`

  """
  @spec get_collections(binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def get_collections(website_url, access_token, fields \\ nil, filter \\ %{}, format \\ "json") do
    object_params = %{
      object: "collection",
      body: "",
      params: Helper.params(filter, fields),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  @doc """

  Fetchs all product options from the given `website_url`.

  Makes a `GET` request to the given `website_url` using the `OAuth2.AccessToken`

  """
  @spec get_options(binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def get_options(website_url, access_token, fields \\ nil, filter \\ %{}, format \\ "json") do
    object_params = %{
      object: "option",
      body: "",
      params: Helper.params(filter, fields),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    get_request(client_params, object_params)
  end

  @doc """

  Initiates a product bulk operation that can create, update or delete a set of products (up to 20 products)
  in a single request to the given `website_url`.

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """

  @spec product_bulk_operation(binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def product_bulk_operation(website_url, access_token, body, format \\ "json") do
    object_params = %{
      object: "product_bulk",
      body: body,
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Creates a image to the given `website_url`.

  ## Arguments

  * `imagename` - name of the image.
  * `imagedata` - image in base64.
  * `status` - "0" (unpublished) or "1" (published).

  Makes a `POST` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec create_image(binary, binary, binary, binary, any, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def create_image(
        website_url,
        access_token,
        imagename,
        imagedata,
        status \\ "1",
        format \\ "json"
      ) do
    object_params = %{
      object: "image",
      body: %{"filename" => imagename, "file" => imagedata, "status" => status},
      params: Helper.default_empty_params(),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    post_request(client_params, object_params)
  end

  @doc """

  Updates a image to the given `website_url`.

  ## Arguments
  * `fid` - image id. 
  * `filedata` - image in base64.
  * `status` - "0" (unpublished) or "1" (published).

  Makes a `PUT` request to the given `website_url` using the `OAuth2.AccessToken`.

  """
  @spec update_image(binary, binary, integer, binary, binary, binary) ::
          {:ok, Response.t()} | {:error, Response.t()} | {:error, Error.t()}
  def update_image(
        website_url,
        access_token,
        fid,
        imagedata,
        status \\ "1",
        format \\ "json"
      ) do
    object_params = %{
      object: "image_fid",
      body: %{"file" => imagedata, "status" => status},
      params: Helper.params(%{}, nil, [fid]),
      format: format
    }

    client_params = %{website_url: website_url, access_token: access_token}
    put_request(client_params, object_params)
  end
end
