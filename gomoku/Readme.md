# gomoku

gomoku for two human players

## Manual
In game, use dpad (normally arrow keys) to move cursor, use button o (🅾️) to place chess piece at current position of cursor, use button x (❎) to reset current game

When game over, use button o to restart a new game

The black and white player use the same cursor, and place chess piece in turn. When a player linked 5 adjacent pieces of the player's color horizontally, vertically or diagonally, game over and this player wins

This game will not call a draw, if there is no place for new chess piece, or all players are impossible to link 5 adjacent pieces, the players need to reset the game manually

## Changelog
v1 2025.2.6
* complete the basic function of gomoku
* optimize the hint message: "win!" now look more obvious (use `\^w\^t` to set wide and tall character)
* add the function to reset after game or in game
* sprite's visual adjustments: chess piece changes to standard circle with radius of 3, board's grid slim by 1 pixel, cursor is larger (now occupies 2x2 sprites)
* modify `board.place()` and `board.count()`: `place()` will make highlight when detect no less than 5 adjacent chess pieces; `count()` now handle both positive and negative direction of one line
* when game over, highlight the 5 or more adjacent chess pieces

(untracked)
demo 2025.2.5
* handle the board's state and drawing
* handle the cursor
* handle players' input
* draw hint message
* determine when the game overs

