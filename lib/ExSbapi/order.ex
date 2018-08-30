defmodule ExSbapi.Order.Mail do
  @moduledoc false
  defstruct mail: ""
end

defmodule ExSbapi.Order.Shipping do
  @moduledoc false
  defstruct shipping: %{
              service: String
            }
end

defmodule ExSbapi.Order.Coupon do
  @moduledoc false
  defstruct coupons: [
              %{code: ""}
            ]
end

defmodule ExSbapi.Order.Payment do
  @moduledoc false
  defstruct payment: %{
              method: ""
            }
end

defmodule ExSbapi.Order.CustomerShipping do
  @moduledoc false
  alias ExSbapi.CustomerProfile.CustomerAddress
  alias ExSbapi.CustomerProfile.NewAddress

  defstruct customer_shipping: %NewAddress{
              customer_address: %CustomerAddress{
                country: "",
                name_line: "",
                locality: "",
                postal_code: "",
                phone_number: "",
                mobile_number: "",
                fax_number: ""
              },
              reference: "",
              type: "",
              uid: ""
            }
end
