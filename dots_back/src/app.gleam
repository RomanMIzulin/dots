import gleam/dict.{type Dict}
import gleam/erlang/atom
import gleam/erlang/process
import gleam/float
import gleam/int
import gleam/io
import gleam/otp/actor

import router
import users

import mist
import wisp

pub fn main() {
  io.println("Hello from dots_back!")
  wisp.configure_logger()

  let games_visor = actor.start(init_games_supervisor(), handle_msg)
  let assert Ok(_) =
    wisp.mist_handler(router.handle_request, "secret")
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  process.register(games_visor.pid, atom.from_string("games_visor"))
  io.debug(games_visor)
  loop()
}
