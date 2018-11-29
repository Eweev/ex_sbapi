defmodule ExSbapi.ProductType do
  alias __MODULE__
  @type uuid :: binary
  @type weight :: integer
  @type t() :: %ProductType{
          uuid: uuid,
          weight: weight
        }
  @moduledoc false
  defstruct uuid: "",
            weight: ""
end
