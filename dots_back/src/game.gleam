//// Contains all logic related to a specif game between 2 users

import gleam/erlang/process.{type Subject}
import gleam/otp/actor

import users

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
  NewGame(id: Int, player1: users.User)
  // started and ongoing game with 2 players
  OngoingGame(id: Int, player1: users.User, player2: users.User)
  FinishedGame(
    id: Int,
    player1: users.User,
    player2: users.User,
    game_res: GameRes,
  )
  FailedGame(id: Int, reason: String)
}

// Entrypoing for handling all gamesession relaged messages
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
        NewGame(id, player1) -> {
          let new_state =
            OngoingGame(
              id: id,
              player1: player1,
              player2: users.get_user(user_id),
            )
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
