defmodule Wayfinder.Collections do
  @moduledoc false

  alias Wayfinder.Processor.Route

  defstruct [
    :routes,
    :actions
  ]

  @type t :: %__MODULE__{
          routes: %{String.t() => [Route.t()]},
          actions: %{module() => [Route.t()]}
        }
end
