defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       score: 0,
       message: "Make a guess",
       time: time(),
       correct: :rand.uniform(10) |> to_string(),
       has_won: false
     )}
  end

  def handle_event("guess", %{"number" => guess}, socket) do
    message = "Your guess: #{guess}. " <> create_message(guess, socket.assigns.correct)
    score = calculate_score(socket.assigns.score, guess, socket.assigns.correct)

    {
      :noreply,
      assign(
        socket,
        message: message,
        score: score,
        time: time(),
        has_won: socket.assigns.has_won || is_win(guess, socket.assigns.correct)
      )
    }
  end

  defp create_message(guess, correct) do
    cond do
      is_win(guess, correct) ->
        "You got it! Congratulations!"

      true ->
        "Wrong. Guess again. "
    end
  end

  def calculate_score(score, guess, correct) do
    cond do
      is_win(guess, correct) ->
        score + 1

      true ->
        score - 1
    end
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    It's <%= @time %>
    <h1>Your score: <%= @score %></h1>
    <h2>
      <%= @message %>
    </h2>
    <%= if @has_won do %>
      <h3>
        Play again?
      </h3>
    <% else %>
      <h2>
        <%= for n <- 1..10 do %>
          <.link href="#" phx-click="guess" phx-value-number={n}>
            <%= n %>
          </.link>
        <% end %>
      </h2>
    <% end %>
    """
  end

  def time() do
    DateTime.utc_now() |> to_string()
  end

  defp is_win(guess, correct) do
    guess == correct
  end
end
