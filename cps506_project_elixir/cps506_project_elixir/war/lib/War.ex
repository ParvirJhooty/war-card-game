defmodule War do
  @moduledoc """
    Documentation for `War`.
  """

  @doc """
    Function stub for deal/1 is given below. Feel free to add
    as many additional helper functions as you want.

    The tests for the deal function can be found in test/war_test.exs.
    You can add your five test cases to this file.

    Run the tester by executing 'mix test' from the war directory
    (the one containing mix.exs)
  """

  def deal(shuf) do
  # returns the winning deck of cards, deals cards to players, winning list is converted back to 1s and returned.
    deck = ace_highest(shuf)
    {p1, p2} = deal_cards(deck)
    change_ace(is_winner(p1, p2))
  end

  defp ace_highest(cards) do
  # changes the 1s in the list to 14 for the ace value
    cards
    |> Enum.map(fn
      card -> case card do
        1 -> 14
        _ -> card
      end
    end)
  end

  defp change_ace(cards) do
  # changes all the 14s in the given list back to 1
    cards
    |> Enum.map(fn
      card -> case card do
        14 -> 1
        _ -> card
      end
    end)
  end

  def deal_cards(list) do
 # Deals the deck of cards alternatively to the 2 players, list is then reversed as players pick up their face down decks
    p1 = list
      |> Stream.with_index()
      |> Stream.filter(fn {_, index} -> rem(index, 2) == 0 end)
      |> Stream.map(fn {element, _} -> element end)
      |> Enum.reverse()

    p2 = list
     |> Stream.with_index()
     |> Stream.filter(fn {_, index} -> rem(index, 2) == 1 end)
     |> Stream.map(fn {element, _} -> element end)
     |> Enum.reverse()

    {p1, p2}
  end

  defp compare_cards(card1, card2) do
  # compares the cards put down during the game and returns have greater one, if tied nil is returned to start a war
    if card2 < card1, do: card1, else:
    if card1 < card2, do: card2, else: nil
  end

  defp is_winner([], p2), do: p2
  defp is_winner(p1, []), do: p1
  defp is_winner(p1, p2) do
    # Recursively call the `turn/2` function to continue the game, player is returned winner of the game if opponent runs out of cards.
    {winner1, winner2} = play(p1, p2)
    is_winner(winner1, winner2)
  end

  defp play(p1, p2, won_cards \\ [])
    # incase a player runs out of cards in a war
  defp play([], card2, won_cards), do: {[], card2 ++ won_cards}
  defp play(card1, [], won_cards), do: {card1 ++ won_cards, []}
  defp play([card1 | rest1], [card2 | rest2], _) when (length(rest1) == 0 or length(rest2) == 0) and card2 == card1 do
      if length(rest1) == 1, do: {rest2 ++ rest1 ++ [card1] ++ [card2], []}, else: {rest1 ++ rest2 ++ [card2] ++ [card1], []}
  end
  defp play([card1 | rest1], [card2 | rest2], won_cards) do
    # emulates a round in the game by comparing the cards of p1 and p2 to determine which one is higher or if there is a tie,
    # resulting in a "war" scenario. In the event of a tie, each player removes two cards and the turn function is recursively called with the
    # second card to determine the winner of the war or if there is yet another tie. The cards used in the war are stored in the winCard variable and will be added to the winner's pile.
    case compare_cards(card1, card2) do
      nil ->
        [card_face_down1 | rem1 ] = rest1
        [card_face_down2 | rem2 ] = rest2
        addedWonCards = won_cards ++ [card1, card_face_down1, card2, card_face_down2]
        play(rem1, rem2, Enum.sort(addedWonCards, :desc))
        # If one of the players wins a round, their pile of cards, along with any cards accumulated during a war, is appended with the winning card, and then both players are returned.
      winner ->
        if card1 == winner do
            {rest1 ++ Enum.sort([card1, card2] ++ won_cards, :desc), rest2}
        else
            {rest1, rest2 ++ Enum.sort([card2, card1] ++ won_cards, :desc)}
        end
    end
  end
end

#test "deal_6" do
#    t6 = [2, 1, 2, 1, 2, 1, 2, 1, 3, 4, 3, 4, 3, 4, 3, 4, 5, 6, 5, 6, 5, 6, 5, 6, 7, 8, 7, 8, 7, 8, 7, 8, 9, 10, 9, 10, 9, 10, 9, 10, 11, 12, 11, 12, 11, 12, 11, 12, 13, 13, 13, 13]
#    r6 = [13, 13, 13, 13, 12, 11, 12, 11, 12, 11, 12, 11, 10, 9, 10, 9, 10, 9, 10, 9, 8, 7, 8, 7, 8, 7, 8, 7, 6, 5, 6, 5, 6, 5, 6, 5, 4, 3, 4, 3, 4, 3, 4, 3, 1, 2, 1, 2, 1, 2, 1, 2]
#    assert War.deal(t6) == r6
#  end

#  test "deal_7" do
#    t7 = [9, 5, 2, 9, 13, 5, 6, 3, 3, 1, 1, 6, 11, 8, 12, 2, 8, 4, 3, 11, 10, 9, 5, 10, 9, 11, 7, 5, 10, 11, 4, 2, 1, 3, 4, 12, 7, 8, 1, 4, 12, 12, 13, 2, 6, 13, 13, 10, 8, 7, 7, 6]
#    r7 = [13, 9, 6, 3, 13, 8, 12, 12, 7, 6, 6, 5, 5, 4, 4, 2, 13, 11, 11, 10, 1, 9, 1, 8, 12, 7, 11, 2, 5, 2, 1, 8, 8, 3, 1, 10, 13, 10, 11, 4, 12, 10, 9, 9, 7, 7, 5, 3, 6, 4, 3, 2]
#    assert War.deal(t7) == r7
#  end

#  test "deal_8" do
#  t8 = [2, 8, 11, 1, 13, 5, 7, 10, 12, 8, 7, 3, 3, 5, 11, 12, 1, 10, 9, 2, 13, 6, 9, 6, 3, 5, 2, 9, 4, 7, 10, 6, 11, 1, 8, 4, 13, 4, 12, 6, 3, 4, 5, 9, 10, 7, 2, 8, 13, 1, 11, 12]
#  r8 = [9, 3, 11, 9, 10, 7, 6, 5, 1, 13, 8, 4, 1, 10, 6, 4, 3, 2, 11, 8, 10, 2, 10, 7, 8, 2, 1, 12, 13, 12, 13, 9, 11, 5, 12, 3, 12, 2, 9, 8, 7, 6, 5, 4, 1, 7, 13, 4, 11, 5, 6, 3]
#  assert War.deal(t8) == r8
#  end

#  test "deal_9" do
#  t9 = [11, 7, 6, 9, 8, 5, 13, 11, 3, 5, 6, 1, 2, 10, 2, 3, 1, 7, 9, 12, 8, 12, 10, 13, 3, 4, 6, 2, 8, 7, 4, 5, 13, 12, 9, 1, 10, 4, 1, 2, 10, 11, 7, 8, 3, 4, 6, 12, 5, 9, 11, 13]
#  r9 = [11, 9, 7, 4, 5, 3, 11, 8, 1, 8, 10, 6, 10, 9, 10, 3, 7, 4, 5, 2, 1, 5, 13, 4, 1, 7, 9, 3, 1, 12, 13, 10, 13, 6, 7, 2, 12, 9, 11, 3, 8, 4, 5, 2, 13, 8, 12, 6, 12, 6, 11, 2]
#  assert War.deal(t9) == r9
#  end

#  test "deal_10" do
#  t10 = [5, 6, 9, 9, 7, 7, 6, 6, 6, 5, 13, 12, 10, 11, 1, 2, 7, 8, 8, 9, 9, 5, 5, 8, 8, 7, 1, 4, 4, 3, 13, 11, 13, 11, 12, 4, 10, 11, 1, 1, 13, 10, 2, 10, 4, 3, 2, 2, 3, 12, 3, 12]
#  r10 = [10, 3, 4, 2, 13, 2, 11, 2, 13, 8, 11, 5, 1, 8, 1, 9, 9, 8, 5, 4, 13, 7, 12, 4, 13, 10, 12, 7, 9, 3, 9, 2, 7, 6, 6, 5, 10, 8, 1, 11, 12, 6, 1, 7, 12, 6, 10, 3, 11, 5, 4, 3]
#  assert War.deal(t10) == r10
#  end
