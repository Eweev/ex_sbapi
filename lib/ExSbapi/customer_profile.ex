defmodule ExSbapi.CustomerProfile.CustomerAddress do
    @moduledoc false

    defstruct country: "",
            name_line: "",
            locality: "",
            postal_code: "",
            phone_number: "",
            mobile_number: "",
            fax_number: ""
end

defmodule ExSbapi.CustomerProfile.NewAddress do
    @moduledoc false

  defstruct customer_address: %ExSbapi.CustomerProfile.CustomerAddress{},
            reference: "",
            type: "",
            uid: ""
end
