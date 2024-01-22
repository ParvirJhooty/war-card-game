#![allow(non_snake_case,non_camel_case_types,dead_code)]
use std::vec::Vec;

/*
    Below is the function stub for deal. Add as many helper functions
    as you like, but the deal function should not be modified. Just
    fill it in.
    
    Test your code by running 'cargo test' from the war_rs directory.
*/

fn deal(shuf: &[u8; 52]) -> [u8; 52] {
    // The function takes an array of 52 unsigned 8-bit integers representing a shuffled deck of cards.
    // It calls the `ace_highest` function to ensure that aces are considered the highest card.
    let deck = ace_highest(shuf);
   
    // It calls the `deal_cards` function to deal the cards between two players.
    // The function returns a tuple containing two mutable vectors of unsigned 8-bit integers, `p1` and `p2`.
    let (mut p1, mut p2) = deal_cards(&deck);
   
    // It calls the `play_war` function to simulate a game of War between the two players.
    // The function returns a mutable vector of unsigned 8-bit integers representing the result of the game.
    let mut result = play_war(&mut p1, &mut p2);
   
    // It calls the `change_ace` function to convert any aces that were temporarily changed to the highest card value back to their original value.
    // The function takes a mutable reference to the result of the game and returns a new array of 52 unsigned 8-bit integers.
    let final_deck = change_ace(&mut result);
  
    // The function returns the final array of 52 unsigned 8-bit integers.
    final_deck
}

//function deals the cards to player 1 and 2
fn deal_cards(list: &[u8]) -> (Vec<u8>, Vec<u8>) {
    let p1: Vec<u8> = list
        .iter()                                     // The code starts by calling the `iter` method on `list` to create an iterator over its elements.
        .enumerate()        // It then calls the `enumerate` method to create a new iterator that yields tuples containing each element and its index in `list`.
        .filter_map(|(i, &x)| if i % 2 == 0 { Some(x) } else { None }) //filter out every second element (i.e., those with an even index). The closure passed to `filter_map` takes each tuple `(i, &x)` and returns `Some(x)` if `i` is even, or `None` otherwise.
        .rev()                      // It calls the `rev` method on the resulting iterator to reverse the order of the remaining elements.
        .collect();                                         // Finally, it calls the `collect` method on the iterator to collect the remaining elements into a new vector of unsigned 8-bit integers.

    let p2: Vec<u8> = list
        .iter()
        .enumerate()
        .filter_map(|(i, &x)| if i % 2 == 1 { Some(x) } else { None })
        .rev()
        .collect();

    (p1, p2) //player cards stored in the tuple
}

fn ace_highest(shuf: &[u8; 52]) -> [u8; 52] {
    let mut deck = *shuf;               // Create a mutable copy of the input deck
    deck.iter_mut().for_each(|card| {    // Iterate over each card in the deck and replace any Aces (cards with value 1) with 14
        if *card == 1 {
            *card = 14;
        }
    });
    deck                                          // Return the modified deck with Aces treated as the highest card (value 14)
}

fn change_ace(list: &mut Vec<u8>) -> [u8; 52] {
    let mut result = [0; 52];

    list.iter_mut().enumerate().for_each(|(i, card)| { // Iterate over each card in the input vector, replacing any Aces (cards with value 14) with 1 in the corresponding position in the output array, and leaving all other cards unchanged
        result[i] = if *card == 14 { 1 } else { *card };
    });
    result
}

//function simulating the game
fn play_war(p1: &mut Vec<u8>, p2: &mut Vec<u8>) -> Vec<u8> {
    let mut cards_played: Vec<u8> = Vec::new(); //for cards players are playing on their turn

    while !p1.is_empty() && !p2.is_empty() { //loops while each player has cards in their deck
        if p1[0] > p2[0] {          //if p1 facedown card is greater than p2's facedown card
            p1.push(p1[0]); p1.push(p2[0]); p1.remove(0); p2.remove(0); //p1 takes both cards
        }
        else if p1[0] < p2[0] {   //if p2 facedown card is greater than p1's facedown card
            p2.push(p2[0]); p2.push(p1[0]); p1.remove(0); p2.remove(0); //p2 takes both cards
        }
        else {
            while p1.len() > 2 && p2.len() > 2 && p1[0] == p2[0] { //players enter war 
                cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0); //2 cards are drawn from each player for war
                cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0);

                if p2[0] < p1[0]{
                    cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0);
                    cards_played.sort_by_key(|a| std::cmp::Reverse(*a));    // Sort the cards played in reverse order
                    p1.extend(cards_played);                               // Append the sorted cards to player 1's hand
                    cards_played = Vec::new();                                  // Create a new empty vector to represent the cards played in the next round
                }

                else if p2[0] > p1[0]{
                    cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0);
                    cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                    p2.extend(cards_played);                            // Append the sorted cards to player 2's hand
                    cards_played = Vec::new();
                }
            }
            if p1.len() == 0{ //player1 runs out of cards during war
                cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                p2.extend(cards_played);
                cards_played = Vec::new();
                break;
            }
            if p2.len() == 0{
                cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                p1.extend(cards_played);
                cards_played = Vec::new();
                break;
            }
                if p1[0] != p2[0] && p1.len() < 3 || p2.len() < 3 {  //checks whether the top cards of each player's hand do not match, and if either player has fewer than three cards left in their hand.
                    cards_played.push(p1[0]); cards_played.push(p2[0]);

                    if p1[0]>p2[0]{
                        cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                        p1.extend(cards_played);
                        cards_played = Vec::new();
                    }

                    if p1[0]<p2[0]{
                        cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                        p2.extend(cards_played);
                        cards_played = Vec::new();
                    }
                    p1.remove(0); p2.remove(0);
                }

                if (p1.len() == 2 || p2.len() == 2) && p1[0] == p2[0] { //if statement that checks if both players have at least two cards left in their hand, and if the top cards of their hands match.
                    for _i in 0..2 {                               //for loop that iterates twice, adding the top cards from each player's hand to a vector called `cards_played`.
                        cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0);
                    }
                }

                if (p1.len() == 1 || p2.len() == 1) && p1[0] == p2[0] { //checks if at least one player has exactly one card left in their hand, and if the top cards of their hands match.
                    cards_played.push(p1[0]); cards_played.push(p2[0]); p1.remove(0); p2.remove(0);
                }

                if p1.len() == 0{
                    cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                    p2.extend(cards_played);
                    cards_played = Vec::new();
                }
                if p2.len() == 0{
                    cards_played.sort_by_key(|a| std::cmp::Reverse(*a));
                    p1.extend(cards_played);
                    cards_played = Vec::new();
                }
            
        }
    }

    //returns winner
    if p1.len() == 0 {
        return p2.to_vec();
    }
    return p1.to_vec();
}

#[cfg(test)]
#[path = "tests.rs"]
mod tests;

//t6 = [2, 1, 2, 1, 2, 1, 2, 1, 3, 4, 3, 4, 3, 4, 3, 4, 5, 6, 5, 6, 5, 6, 5, 6, 7, 8, 7, 8, 7, 8, 7, 8, 9, 10, 9, 10, 9, 10, 9, 10, 11, 12, 11, 12, 11, 12, 11, 12, 13, 13, 13, 13]
//r6 = [13, 13, 13, 13, 12, 11, 12, 11, 12, 11, 12, 11, 10, 9, 10, 9, 10, 9, 10, 9, 8, 7, 8, 7, 8, 7, 8, 7, 6, 5, 6, 5, 6, 5, 6, 5, 4, 3, 4, 3, 4, 3, 4, 3, 1, 2, 1, 2, 1, 2, 1, 2]

//t7 = [9, 5, 2, 9, 13, 5, 6, 3, 3, 1, 1, 6, 11, 8, 12, 2, 8, 4, 3, 11, 10, 9, 5, 10, 9, 11, 7, 5, 10, 11, 4, 2, 1, 3, 4, 12, 7, 8, 1, 4, 12, 12, 13, 2, 6, 13, 13, 10, 8, 7, 7, 6]
//r7 = [13, 9, 6, 3, 13, 8, 12, 12, 7, 6, 6, 5, 5, 4, 4, 2, 13, 11, 11, 10, 1, 9, 1, 8, 12, 7, 11, 2, 5, 2, 1, 8, 8, 3, 1, 10, 13, 10, 11, 4, 12, 10, 9, 9, 7, 7, 5, 3, 6, 4, 3, 2]

//t8 = [2, 8, 11, 1, 13, 5, 7, 10, 12, 8, 7, 3, 3, 5, 11, 12, 1, 10, 9, 2, 13, 6, 9, 6, 3, 5, 2, 9, 4, 7, 10, 6, 11, 1, 8, 4, 13, 4, 12, 6, 3, 4, 5, 9, 10, 7, 2, 8, 13, 1, 11, 12]
//r8 = [9, 3, 11, 9, 10, 7, 6, 5, 1, 13, 8, 4, 1, 10, 6, 4, 3, 2, 11, 8, 10, 2, 10, 7, 8, 2, 1, 12, 13, 12, 13, 9, 11, 5, 12, 3, 12, 2, 9, 8, 7, 6, 5, 4, 1, 7, 13, 4, 11, 5, 6, 3]

//t9 = [11, 7, 6, 9, 8, 5, 13, 11, 3, 5, 6, 1, 2, 10, 2, 3, 1, 7, 9, 12, 8, 12, 10, 13, 3, 4, 6, 2, 8, 7, 4, 5, 13, 12, 9, 1, 10, 4, 1, 2, 10, 11, 7, 8, 3, 4, 6, 12, 5, 9, 11, 13]
//r9 = [11, 9, 7, 4, 5, 3, 11, 8, 1, 8, 10, 6, 10, 9, 10, 3, 7, 4, 5, 2, 1, 5, 13, 4, 1, 7, 9, 3, 1, 12, 13, 10, 13, 6, 7, 2, 12, 9, 11, 3, 8, 4, 5, 2, 13, 8, 12, 6, 12, 6, 11, 2]

//t10 = [5, 6, 9, 9, 7, 7, 6, 6, 6, 5, 13, 12, 10, 11, 1, 2, 7, 8, 8, 9, 9, 5, 5, 8, 8, 7, 1, 4, 4, 3, 13, 11, 13, 11, 12, 4, 10, 11, 1, 1, 13, 10, 2, 10, 4, 3, 2, 2, 3, 12, 3, 12]
//r10 = [10, 3, 4, 2, 13, 2, 11, 2, 13, 8, 11, 5, 1, 8, 1, 9, 9, 8, 5, 4, 13, 7, 12, 4, 13, 10, 12, 7, 9, 3, 9, 2, 7, 6, 6, 5, 10, 8, 1, 11, 12, 6, 1, 7, 12, 6, 10, 3, 11, 5, 4, 3]
