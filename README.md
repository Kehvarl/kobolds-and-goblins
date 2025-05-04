# Kobolds and Goblins

tic-tac-toe style game

Get 3 in a row to overwhelm your opponent and steal their treasure.

Pick your team:  Choose 3 units you'll have availabe, Kobolds and Goblins have different, but complimentary powers

Unit Types.  Each activity 1/unit/game
Kobold:
    Miner - can remove (or replace) adjacent enemy
    Scout - place a second mark in any corner
    Disruptor - skip opponent next turn

Goblin:
    Shaman - Protect a space from capture
    Gremlin - Swap any 2 of your units
    Trickster - place unit in free corner

Both:
    Sapper - Remove any unit but skip your next turn
    Guard - this unit cannot be removed or swapped
    Caller - Summon an additional unit

Possible variants
   Try to NOT get 3 in a row
   4x4, 4 in a row

Local multiplayer or simple bots
Algorithms
Basic
  Win: If it can win on this move, do it.
  Block: If the opponent can win next move, block it.
  Center: Take center if it's available.
  Corner: Take an available corner.
  Side: Take a side (edge) if nothing else.

Needs
  Sprites:
    Kobolds
    Goblins
