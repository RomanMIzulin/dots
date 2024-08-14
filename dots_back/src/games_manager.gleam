import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/otp/actor

import game.{type GameMessage}

pub fn loop() {
  process.receive(process.new_subject(), 1000)
  loop()
}

// here top level supervisor definition that sits on top of the app

pub type GamePid =
  Int

pub type GameSupervisorMsg {
  CreateGame(
    reply_with: process.Subject(GamePid),
    requested_by_user_id: Int,
    game_name: String,
  )
  ListAllGames(reply_with: process.Subject(Result(GamesAll, String)))
  // returns game_id
  JoinGame(
    reply_with: process.Subject(Result(GamePid, String)),
    req_user_id: Int,
    game_name: String,
  )
}

//need game supervisor
pub type GamesAll {
  GamesAll(
    games: Dict(GamePid, Subject(GameMessage)),
    games_by_name: Dict(String, GamePid),
  )
}

pub fn init_games_supervisor() {
  GamesAll(games: dict.new(), games_by_name: dict.new())
}

pub fn handle_msg(
  msg: GameSupervisorMsg,
  state: GamesAll,
) -> actor.Next(GameSupervisorMsg, GamesAll) {
  case msg {
    //create new game and register it in all games 
    CreateGame(client, user_id, game_name) -> {
      let #(new_game, game_id) = game.start_game(user_id, game_name)
      let new_state =
        state.games
        |> dict.insert(game_id, new_game)
      process.send(client, game_id)
      actor.continue(GamesAll(
        games: new_state,
        games_by_name: state.games_by_name,
      ))
    }
    JoinGame(client, req_user_id, game_name) -> {
      // check that game exist, check that user can join
      let game = dict.get(state.games_by_name, game_name)
      case game {
        Ok(g) -> {
          // add here user to game  
          process.send(client, Ok(g))
        }
        Error(_) -> process.send(client, Error("no such game"))
      }
      actor.continue(GamesAll(
        games: state.games,
        games_by_name: state.games_by_name,
      ))
    }
    ListAllGames(client) -> {
      process.send(client, Ok(state))
      actor.continue(state)
    }
  }
}
