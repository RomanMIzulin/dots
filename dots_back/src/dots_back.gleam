import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/otp/actor
import users

import game.{type Game}

pub fn main() {
  io.println("Hello from dots_back!")
  let games_visor = actor.start(init_games_supervisor(), handle_msg)
  io.debug(games_visor)
  loop()
}

pub fn loop() {
  process.receive(process.new_subject(), 1000)
  loop()
}

// here top level supervisor definition that sits on top of the app

pub type GamePid =
  Int

pub type GameSupervisorMsg {
  CreateGame(requested_by_user_id: Int)
}

//need game supervisor
pub type GamesAll {
  GamesAll(games: Dict(GamePid, Game))
}

pub fn init_games_supervisor() {
  GamesAll(games: dict.new())
}

pub fn handle_msg(
  msg: GameSupervisorMsg,
  state: GamesAll,
) -> actor.Next(GameSupervisorMsg, GamesAll) {
  case msg {
    //create new game and register it in all games 
    CreateGame(user_id) -> {
      let new_game = create_game(user_id)
      let new_state =
        state.games
        |> dict.insert(new_game.id, new_game)
      actor.continue(GamesAll(games: new_state))
    }
  }
}

// handle create game call from a user(which is websocket?)
fn create_game(user_id: Int) -> Game {
  game.NewGame(id: int.random(65_536), player1: users.get_user(user_id))
}
