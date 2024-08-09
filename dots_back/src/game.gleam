//// Contains all logic related to a specif game between 2 users

import users

pub type GameRes {
  Player1Won
  Player2Won
  Draw
}

pub type Game {
  NewGame(id: Int)
  OngoingGame(id: Int, player1: users.User, player2: users.User)
  FinishedGame(
    id: Int,
    player1: users.User,
    player2: users.User,
    game_res: GameRes,
  )
  FailedGame(id: Int, reason: String)
}
