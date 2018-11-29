defmodule ExSbapi.ProductDimensions do
  alias __MODULE__
  @type length :: float
  @type width :: float
  @type height :: float
  @type unit :: binary
  @type t() :: %ProductDimensions{
          length: length,
          width: width,
          height: height,
          unit: unit
        }

  defstruct length: "",
            width: "",
            height: "",
            unit: ""
end
