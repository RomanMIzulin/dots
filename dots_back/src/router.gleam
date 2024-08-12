import gleam/erlang/atom
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/string_builder
import wisp.{type Request, type Response}

import chip
import games_manager

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request, game_visor: Subject(Int)) -> Response {
  // Apply the middleware stack for this request/response.
  let body = string_builder.from_string("<h1>Hello, Joe!</h1>")
  // how to send message to games visor process that manages all games?

  case wisp.path_segments(req) {
    ["games"] -> {
      let games = process.call(game_visor, games_manager.ListAllGames, 10)
      let body = string_builder.from_string(io.debug(games))
      wisp.html_response(body, 200)
    }
    _ -> wisp.not_found()
  }
  // Later we'll use templates, but for now a string will do.

  // Return a 200 OK response with the body and a HTML content type.
  wisp.log_info("request from " <> req.host)
  wisp.html_response(body, 200)
}
