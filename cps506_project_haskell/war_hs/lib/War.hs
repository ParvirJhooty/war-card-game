module War (deal) where

import Data.List
import GHC.RTS.Flags (GCFlags(stkChunkBufferSize))


{--
Function stub(s) with type signatures for you to fill in are given below. 
Feel free to add as many additional helper functions as you want. 

The tests for these functions can be found in src/TestSuite.hs. 
You are encouraged to add your own tests in addition to those provided.

Run the tester by executing 'cabal test' from the war directory 
(the one containing war.cabal)
--}

deal :: [Int] -> [Int] --A function called Deal is created, which takes a shuffled deck as input and will output the winner of the game.
deal shuffle = 
    let (player1deck, player2deck) = decks_reversed (decks (ace_highest shuffle)) 
        winner = change_ace (play player1deck player2deck []) --winner is chosen
    in winner 


-- changes the 1s in the list to 14 for the ace value
ace_highest :: [Int] -> [Int] 
ace_highest = map (\x -> if x == 1 then 14 else x) 

-- changes all the 14s in the given list back to 1
change_ace :: [Int] -> [Int] 
change_ace = map (\x -> if x == 14 then 1 else x) 

--function that deals the original deck to the 2 players until deck is empty
decks :: [Int] -> ([Int], [Int]) 
decks [] = ([], []) 
decks [card] = ([card],[]) 
decks (card1:card2:cards) = (card1: player1_cards', card2: player2_cards') 
    where(player1_cards', player2_cards') = decks cards --called recursively

--decks are reversed after the cards are dealt as the players pick up their cards which were faced down
decks_reversed :: ([Int], [Int]) -> ([Int],[Int]) 
decks_reversed (player1_deck, player2_deck) = (reverse player1_deck, reverse player2_deck) 

--Function where the game of war is played
play :: [Int] -> [Int] -> [Int] -> [Int] 
play [] [] war_deck = war_deck 
play player1_deck [] war_deck = player1_deck ++ reverse war_deck --If player2 has no cards left in their deck, then player1 wins the game. In this case, the function will return player1's deck along with the contents of the warchest.
play player2_deck [] war_deck = player2_deck ++ reverse war_deck 
play (p1_card:p1_deck) (p2_card: p2_deck) war_deck = 
    let 
        battle_cards = reverse $ sort $ p1_card : p2_card : war_deck --The cards that will be used for the battle are stored, and it is verified that they are arranged in a descending order.
    in 
        if p2_card < p1_card then 
            play(p1_deck ++ battle_cards) p2_deck [] --The game is not yet finished, so playWar is called again. Then, the cards that player1 has just won are appended to the end of their deck in a descending order.
        else if p1_card < p2_card then 
            play p1_deck (p2_deck ++ battle_cards) [] 
        else if length p2_deck > 1 && length p1_deck > 1 then --If player1 and player2 have the same value cards, a war occurs. To ensure that the game can continue, it is verified that both players have at least 2 cards remaining.
            let
                (player1_facedown_card:p1_deck') = p1_deck --The facedownCard is set as the first card in player1's deck, as it is the card that will be bet in the event of a tie (war).
                (player2_facedown_card:p2_deck') = p2_deck 
            in
                play p1_deck' p2_deck' (battle_cards ++ [player1_facedown_card, player2_facedown_card]) --Since a war has occurred and the winner will take all the cards that were added to battleCards, the playWar function is invoked again.
        else
            play p1_deck p2_deck battle_cards --If the cards are of equal value and there are less than two cards remaining, the playWar function is called again to continue the game.


-- t6 = [2, 1, 2, 1, 2, 1, 2, 1, 3, 4, 3, 4, 3, 4, 3, 4, 5, 6, 5, 6, 5, 6, 5, 6, 7, 8, 7, 8, 7, 8, 7, 8, 9, 10, 9, 10, 9, 10, 9, 10, 11, 12, 11, 12, 11, 12, 11, 12, 13, 13, 13, 13]
-- r6 = [13, 13, 13, 13, 12, 11, 12, 11, 12, 11, 12, 11, 10, 9, 10, 9, 10, 9, 10, 9, 8, 7, 8, 7, 8, 7, 8, 7, 6, 5, 6, 5, 6, 5, 6, 5, 4, 3, 4, 3, 4, 3, 4, 3, 1, 2, 1, 2, 1, 2, 1, 2]

-- t7 = [9, 5, 2, 9, 13, 5, 6, 3, 3, 1, 1, 6, 11, 8, 12, 2, 8, 4, 3, 11, 10, 9, 5, 10, 9, 11, 7, 5, 10, 11, 4, 2, 1, 3, 4, 12, 7, 8, 1, 4, 12, 12, 13, 2, 6, 13, 13, 10, 8, 7, 7, 6]
-- r7 = [13, 9, 6, 3, 13, 8, 12, 12, 7, 6, 6, 5, 5, 4, 4, 2, 13, 11, 11, 10, 1, 9, 1, 8, 12, 7, 11, 2, 5, 2, 1, 8, 8, 3, 1, 10, 13, 10, 11, 4, 12, 10, 9, 9, 7, 7, 5, 3, 6, 4, 3, 2]

-- t8 = [2, 8, 11, 1, 13, 5, 7, 10, 12, 8, 7, 3, 3, 5, 11, 12, 1, 10, 9, 2, 13, 6, 9, 6, 3, 5, 2, 9, 4, 7, 10, 6, 11, 1, 8, 4, 13, 4, 12, 6, 3, 4, 5, 9, 10, 7, 2, 8, 13, 1, 11, 12]
-- r8 = [9, 3, 11, 9, 10, 7, 6, 5, 1, 13, 8, 4, 1, 10, 6, 4, 3, 2, 11, 8, 10, 2, 10, 7, 8, 2, 1, 12, 13, 12, 13, 9, 11, 5, 12, 3, 12, 2, 9, 8, 7, 6, 5, 4, 1, 7, 13, 4, 11, 5, 6, 3]

-- t9 = [11, 7, 6, 9, 8, 5, 13, 11, 3, 5, 6, 1, 2, 10, 2, 3, 1, 7, 9, 12, 8, 12, 10, 13, 3, 4, 6, 2, 8, 7, 4, 5, 13, 12, 9, 1, 10, 4, 1, 2, 10, 11, 7, 8, 3, 4, 6, 12, 5, 9, 11, 13]
-- r9 = [11, 9, 7, 4, 5, 3, 11, 8, 1, 8, 10, 6, 10, 9, 10, 3, 7, 4, 5, 2, 1, 5, 13, 4, 1, 7, 9, 3, 1, 12, 13, 10, 13, 6, 7, 2, 12, 9, 11, 3, 8, 4, 5, 2, 13, 8, 12, 6, 12, 6, 11, 2]

-- t10 = [5, 6, 9, 9, 7, 7, 6, 6, 6, 5, 13, 12, 10, 11, 1, 2, 7, 8, 8, 9, 9, 5, 5, 8, 8, 7, 1, 4, 4, 3, 13, 11, 13, 11, 12, 4, 10, 11, 1, 1, 13, 10, 2, 10, 4, 3, 2, 2, 3, 12, 3, 12]
-- r10 = [10, 3, 4, 2, 13, 2, 11, 2, 13, 8, 11, 5, 1, 8, 1, 9, 9, 8, 5, 4, 13, 7, 12, 4, 13, 10, 12, 7, 9, 3, 9, 2, 7, 6, 6, 5, 10, 8, 1, 11, 12, 6, 1, 7, 12, 6, 10, 3, 11, 5, 4, 3]