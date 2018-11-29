defmodule ExSbapi.Collection do
  @moduledoc ~S"""
  Shopbuilder Product Collection struct and functions.
  """

  alias __MODULE__

  @type title :: binary
  @type body :: any
  @type image :: %{} | nil
  @type ref :: binary

  @type t() :: %Collection{
          name: title,
          description: body,
          image_cc: image,
          reference: ref
        }

  @moduledoc false
  defstruct name: "",
            description: "",
            image_cc: nil,
            reference: ""

  def new(title, body \\ "", image \\ nil, ref \\ "") do
    %Collection{
      name: title,
      description: body,
      image_cc: image,
      reference: ref
    }
  end
end
