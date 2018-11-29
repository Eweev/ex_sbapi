defmodule ExSbapi.Helper do
  @moduledoc false
  def check_hash(your_hash_key, payload, sb_hash) do
    hashed_string = :crypto.hmac(:sha256, your_hash_key, payload) |> Base.encode16(case: :lower)

    if hashed_string == sb_hash do
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
    %{
      filter: %{},
      uri_token: [order_id]
    }
  end

  def params(filter \\ %{}, fields \\ nil, uri_token \\ []) do
    %{
      filter: filter,
      uri_token: uri_token,
      fields: fields
    }
  end

  def body_for_mode(restricted, mode, authorized_roles) do
    %{
      restricted: restricted,
      mode: mode,
      authorized_roles: authorized_roles
    }
  end

  def body_for_profile_mobile_number(required, show_on_registration_form) do
    %{
      required: required,
      show_on_registration_form: show_on_registration_form
    }
  end

  def product_redirection(status) do
    %{
      status: status
    }
  end

  def generate_auto_login_link(user_uuid, destination_url) do
    %{
      user_id: user_uuid,
      destination: destination_url
    }
  end

  def generate_order_query_object(list_of_uuid, date) do
    %{
      conditions: %{
        owner: %{
          id: list_of_uuid
        },
        confirmed_orders: %{
          start: %{
            year: date.start.year,
            month: date.start.month,
            day: date.start.day
          },
          end: %{
            year: date.end.year,
            month: date.end.month,
            day: date.end.day
          }
        }
      },
      fields: [
        "status",
        "order_id",
        "user",
        "order_total",
        "order_balance",
        "created",
        "closed_date"
      ]
    }
  end

  def generate_redirection_to_product_query(status) do
    %{
      status: status
    }
  end

  def generate_buy_link_enable_body(status) do
    %{
      status: status
    }
  end

  def params_with_buy_link(sku, qty) do
    %{
      filter: %{},
      uri_token: [sku, qty]
    }
  end

  def params_with_custom_shipping_method(method_name) do
    %{
      filter: %{},
      uri_token: [method_name]
    }
  end
end
