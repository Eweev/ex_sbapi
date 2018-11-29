defmodule ExSbapi.Product do
  @moduledoc ~S"""
  A Shopbuilder Product struct and functions.
  """

  alias ExSbapi.{
    Product,
    ProductVariation,
    ProductType,
    ProductWeight,
    ProductDimensions,
    Price
  }

  @type title :: binary
  @type variations :: [ProductVariation.t()]
  @type collections :: [ProductType.t()]
  @type body :: any
  @type status :: binary | nil
  @type images :: []
  @type ref :: any
  @type language :: any
  @type new :: boolean | nil
  @type on_sale :: boolean | nil
  @type same_weight_dimensions :: boolean
  @type weight :: ProductWeight.t() | nil
  @type dimensions :: ProductDimensions.t() | nil
  @type same_price :: boolean | nil
  @type price :: Price.t() | nil
  @type suggested_products :: []
  @type seo :: any
  @type type :: binary

  @type t() :: %Product{
          title: title,
          product: variations,
          product_type: collections,
          description: body,
          status: status,
          image_product: images,
          reference: ref,
          language: language,
          new: new,
          on_sale: on_sale,
          same_price: same_price,
          price: price,
          same_weight_dimensions: same_weight_dimensions,
          weight: weight,
          dimensions: dimensions,
          suggested_products: suggested_products,
          seo: seo,
          type: type
        }

  defstruct title: "",
            product: [],
            product_type: [],
            description: "",
            status: "1",
            image_product: [],
            reference: "",
            language: "",
            new: nil,
            on_sale: nil,
            same_price: nil,
            price: nil,
            same_weight_dimensions: nil,
            weight: %{},
            dimensions: %{},
            suggested_products: [],
            seo: %{},
            type: ""

  @doc """
  Builds a new Shopbuilder Product
  """
  def new(
        title,
        variations,
        collections,
        description \\ "",
        status \\ "1",
        images \\ [],
        ref \\ "",
        language \\ "en",
        new \\ true,
        on_sale \\ false,
        same_price \\ false,
        price \\ nil,
        same_weight_dimensions \\ false,
        weight \\ nil,
        dimensions \\ nil,
        suggested_products \\ nil,
        seo \\ nil,
        type \\ "shop_builder_display"
      ) do
    %Product{
      title: title,
      product: variations,
      product_type: collections,
      description: description,
      status: status,
      image_product: images,
      reference: ref,
      language: language,
      new: new,
      on_sale: on_sale,
      same_price: same_price,
      price: price,
      same_weight_dimensions: same_weight_dimensions,
      weight: weight,
      dimensions: dimensions,
      suggested_products: suggested_products,
      seo: seo,
      type: type
    }
  end
end
