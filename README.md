# Tournaments based on sorting networks

Normal (single-elimination) tournaments only accurately determine the best player, 
and for casual tournaments, have the disadvantage that most players only get to play 1 or 2 matches.

Round-Robin tournaments require an excessive number of rounds and are not guaranteed to generate an unambiguous ranking at the end.

Ladder structures are good for clubs, but not a great fit for a single tournament, and require a large number of rounds to generate a good result.

A speeded up version of the ladder, where losers move down one position and winners move up one position, is faster, but does not yield a stable sort.

A managed round-robin tournament where people are ranked and paired (by a judge, or by points) can be ambiguous and subjective.

A possibly better alternative to all of these is to use a tournament structure based on [Sorting Networks](https://en.wikipedia.org/wiki/Sorting_network). 
It will yield a full ranking of the entrants, and also has a reasonable number of matches for most players.
The last few rounds are refining the rankings in the middle positions, and could be dropped with little loss 
(Generally, people don't care too much if they end up 4th out of 8 or 5th out of 8).

The files in this directory generate a tournament that will yield a full ranking of all the entrants.
The sequence of matches is based on the sequence of comparisons in a sorting network.

File | Description
---|---
[tournament_8.example.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_8.example.txt) |  This is probably the best place to start. Tournament for 8 players, filled out with an example.
[tournament_8.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_8.txt)  |  Tournament for 8 players.
[tournament_10.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_10.txt) |  Tournament for 10 players.
[tournament_12.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_12.txt) |  Tournament for 12 players.
[tournament_14.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_14.txt) |  Tournament for 14 players.
[tournament_16.txt](https://raw.githubusercontent.com/sgauria/sorting_networks/master/tournament_16.txt) |  Tournament for 16 players.
[SN_tournament.pl](https://github.com/sgauria/sorting_networks/blob/master/SN_tournament.pl) | Code to generate the files above or similar files for different numbers of players. Uses the [web interface to Algorithm::Networksort](http://pages.ripco.net/~jgamble/nw.html).
