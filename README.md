# Tournaments based on sorting networks

Normal (single-elimination) tournaments only accurately determine the best player.
The files in this directory try to generate a tournament that will yield a full ranking of all the entrants.
The sequence of matches is based on the sequence of comparisons in a sorting network.

File | Description
---|---
tournament_8.example.txt |  This is probably the best place to start. Tournament for 8 players, filled out with an example.
tournament_8.txt  |  Tournament for 8 players.
tournament_10.txt |  Tournament for 10 players.
tournament_12.txt |  Tournament for 12 players.
tournament_14.txt |  Tournament for 14 players.
tournament_16.txt |  Tournament for 16 players.
SN_tournament.pl | Code to generate the files above or similar files for different numbers of players. Uses the web interface to Algorithm::Networksort ( http://pages.ripco.net/~jgamble/nw.html ).
