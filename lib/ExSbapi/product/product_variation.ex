defmodule ExSbapi.ProductVariation do
  alias __MODULE__

  alias ExSbapi.{
    ProductVariation,
    Price,
    ProductDimensions,
    ProductWeight
  }

  @type sku :: binary
  @type stock :: integer
  @type price :: Price.t()
  @type dimensions :: ProductDimensions.t() | nil
  @type weight :: ProductWeight.t() | nil
  @type images :: [] | nil
  @type status :: binary | nil
  @type options :: %{} | nil
  @type old_price :: Price.t() | nil

  @type t() :: %ProductVariation{
          sku: sku,
          stock: stock,
          price: price,
          dimensions: dimensions,
          weight: weight,
          image_product: images,
          status: status,
          options: options,
          old_price: old_price
        }
  @moduledoc false
  defstruct sku: "",
            stock: "",
            price: nil,
            dimensions: nil,
            weight: nil,
            status: nil,
            image_product: [],
            options: %{},
            old_price: nil

  def new(
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
    %ProductVariation{
      sku: sku,
      price: price,
      stock: stock,
      dimensions: dimensions,
      weight: weight,
      status: status,
      image_product: images,
      options: options,
      old_price: old_price
    }
  end
end
