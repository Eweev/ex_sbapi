defmodule ExSbapi.ProductWeight do
  alias __MODULE__
  @type weight :: float
  @type unit :: binary
  @type t() :: %ProductWeight{
          weight: weight,
          unit: unit
        }

  defstruct weight: "",
            unit: ""
end
