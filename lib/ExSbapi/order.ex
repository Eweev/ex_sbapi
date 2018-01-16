defmodule ExSbapi.Order.Mail do
   defstruct mail: ""
end

defmodule ExSbapi.Order.Shipping do
   defstruct shipping: %{
              service: String
            }
end

defmodule ExSbapi.Order.Coupon do
   defstruct coupons: [
            %{code: ""}
            ]
end

defmodule ExSbapi.Order.Payment do
   defstruct payment: %{
            method: ""
          }
end

defmodule ExSbapi.Order.CustomerShipping do

   alias ExSbapi.CustomerProfile.New_address
   alias ExSbapi.CustomerProfile.Customer_address
   
   defstruct customer_shipping: %ExSbapi.CustomerProfile.New_address{
    customer_address: %ExSbapi.CustomerProfile.Customer_address{
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