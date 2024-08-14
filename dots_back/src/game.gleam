//// Contains all logic related to a specif game between 2 users

import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/otp/actor

pub type GameRes {
  Player1Won
  Player2Won
  Draw
}

pub type Point {
  Point(x: Int, y: Int)
}

// Used for already started game?
// Supposed to alter game state
pub type GameMessage {
  Shutdown

  UserPlacedDot(user_id: Int, coordinates: Point)

  UserJoined(user_id: Int, reply_with: Subject(Result(String, String)))
  UserLeaved(user_id: Int)
}

pub type Game {
  //just created waiting for a second user to join
  NewGame(id: Int, player1: Int, game_name: String)
  // started and ongoing game with 2 players
  OngoingGame(id: Int, player1: Int, player2: Int, game_name: String)
  FinishedGame(
    id: Int,
    player1: Int,
    player2: Int,
    game_res: GameRes,
    game_name: String,
  )
  FailedGame(id: Int, reason: String, game_name: String)
}

// Entrypoing for handling all game related messages. Specifically to only ONE game.
// actor.start(NewGame, handle_message) -> actor.call(game_actor, UserJoined, <here pid of manager of all game sessions>)
pub fn handle_message(
  msg: GameMessage,
  game_state: Game,
) -> actor.Next(GameMessage, Game) {
  case msg {
    Shutdown -> actor.Stop(process.Normal)

    // it means there are 2 players and game can start
    UserJoined(user_id, client) -> {
      case game_state {
        NewGame(id, player1, game_name) -> {
          let new_state =
            OngoingGame(id: id, player1: player1, player2: user_id, game_name:)
          actor.continue(new_state)
        }
        _ -> {
          process.send(client, Error("Game is not new"))
          actor.continue(game_state)
        }
      }
    }
    _ -> actor.continue(game_state)
  }
}

// returns game process id
// req_user_id means that there can not be game without at least a user
pub fn start_game(
  req_user_id: Int,
  game_name: String,
) -> #(Subject(GameMessage), Int) {
  let game_id = int.random(56_123)
  let init_state = NewGame(id: game_id, player1: req_user_id, game_name:)
  let assert Ok(new_game) = actor.start(init_state, handle_message)
  #(new_game, game_id)
}
