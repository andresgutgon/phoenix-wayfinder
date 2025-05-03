defmodule Wayfinder.Routes do
  @moduledoc false

  alias Wayfinder.Processor.Route

  defstruct [:actions]

  # TODO: named routes
  # https://github.com/andresgutgon/phoenix-wayfinder/issues/4
  # I open a new topic on Elixir Forum to discuss this
  # https://elixirforum.com/u/andresgutgon/activity/pending
  @type t :: %__MODULE__{actions: %{module() => [Route.t()]}}
end
