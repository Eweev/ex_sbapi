defmodule ExSbapi.CustomerProfile.Customer_address do
  defstruct country: "",
            name_line: "",
            locality: "",
            postal_code: "",
            phone_number: "",
            mobile_number: "",
            fax_number: ""
end

defmodule ExSbapi.CustomerProfile.New_address do
  defstruct customer_address: %ExSbapi.CustomerProfile.Customer_address{},
            reference: "",
            type: "",
            uid: ""
end
