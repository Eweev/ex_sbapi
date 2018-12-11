defmodule ExSbapi.ProductOption do
  alias __MODULE__
  @type name :: binary
  @type bundle_type :: binary
  @type is_attribute :: boolean
  @type is_searchable :: boolean
  @type show_as_button :: boolean
  @type is_default_visible :: boolean
  @type t() :: %ProductOption{
          name: name,
          bundle_type: bundle_type,
          is_attribute: is_attribute,
          is_searchable: is_searchable,
          show_as_button: show_as_button,
          is_default_visible: is_default_visible
        }
  @moduledoc false
  defstruct name: "",
            bundle_type: "",
            is_attribute: false,
            is_searchable: false,
            show_as_button: false,
            is_default_visible: false

  @spec new(t, Keyword.t()) :: t
  def new(client \\ %ProductOption{}, opts) do
    struct(client, opts)
  end
end
