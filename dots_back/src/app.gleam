import gleam/erlang/process
import gleam/io
import gleam/otp/actor
import users

import router

import games_manager
import mist
import wisp.{type Request, type Response}

pub fn main() {
  io.println("Hello from dots_back!")
  wisp.configure_logger()

  let games_visor =
    actor.start(games_manager.init_games_supervisor(), games_manager.handle_msg)
  let assert Ok(users_manager) = users.start_users_manager()
  case games_visor {
    Ok(g_visor) -> {
      let handle_req = fn(req: Request) -> Response {
        router.handle_request(req, g_visor, users_manager)
      }
      let assert Ok(_) =
        wisp.mist_handler(handle_req, "secret")
        |> mist.new
        |> mist.port(8000)
        |> mist.start_http

      io.debug(games_visor)
      process.sleep_forever()
    }
    Error(_) -> {
      io.print_error("failed to start games manager")
    }
  }
}
