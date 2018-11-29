defmodule ExSbapi.Price do
  alias __MODULE__
  @type amount :: integer
  @type currency_code :: binary
  @type t() :: %Price{
          amount: amount,
          currency_code: currency_code
        }

  defstruct amount: "",
            currency_code: ""
end
