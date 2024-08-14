import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/erlang/process.{type Subject}
import gleam/function
import gleam/http.{Post}
import gleam/int
import gleam/io
import gleam/list
import gleam/result
import gleam/string_builder

import gleam/json
import wisp.{type Request, type Response}

import games_manager
import users.{type User}

pub type UserRegData {
  UserRegData(name: String)
}

pub type StartGameData {
  StartGameData(req_by: Int, game_name: String)
}

fn decode_reg_data(json: Dynamic) -> Result(UserRegData, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode1(UserRegData, dynamic.field("name", dynamic.string))
  decoder(json)
}

fn decode_start_game_data(
  json: Dynamic,
) -> Result(StartGameData, dynamic.DecodeErrors) {
  let decoder =
    dynamic.decode2(
      StartGameData,
      dynamic.field("req_by", dynamic.int),
      dynamic.field("game_name", dynamic.string),
    )
  decoder(json)
}

pub fn handle_request(
  req: Request,
  games_manager_pr: Subject(games_manager.GameSupervisorMsg),
  users_manager: Subject(users.UsersManagerMessage),
) -> Response {
  // Apply the middleware stack for this request/response.
  // how to send message to games visor process that manages all games?

  let res = case wisp.path_segments(req) {
    ["users", "reg"] -> {
      use <- wisp.require_method(req, Post)
      use json <- wisp.require_json(req)
      case decode_reg_data(json) {
        Ok(res) -> {
          // here need to call UsersManager.AddUser
          let object =
            json.object([
              #("name", json.string(res.name)),
              #("created", json.bool(True)),
            ])
          process.send(
            users_manager,
            users.AddUser(name: res.name, ip: req.host),
          )
          wisp.json_response(json.to_string_builder(object), 201)
        }
        Error(_) -> wisp.unprocessable_entity()
      }
    }
    ["users", id] -> {
      case int.parse(id) {
        Ok(user_id) -> {
          let msg = fn(subject: Subject(Result(users.User, Nil))) -> users.UsersManagerMessage {
            users.GetUser(client: subject, user_id: user_id)
          }
          let user_res = process.call(users_manager, msg, 10)
          case user_res {
            Ok(user) -> {
              let object =
                json.object([
                  #("name", json.string(user.name)),
                  #("id", json.int(user.id)),
                  #("ip", json.string(user.ip)),
                ])
              wisp.json_response(json.to_string_builder(object), 201)
            }
            Error(_) ->
              wisp.json_response(
                json.to_string_builder(
                  json.object([#("msg", json.string("failed"))]),
                ),
                404,
              )
          }
        }
        Error(_) ->
          wisp.json_response(
            json.to_string_builder(
              json.object([#("msg", json.string("id should be string"))]),
            ),
            404,
          )
      }
    }
    ["users"] -> {
      let users = process.call(users_manager, users.ListAllUsers, 10)
      let objects =
        dict.to_list(users)
        |> list.map(fn(v) {
          json.object([
            #("id", json.int(v.0)),
            #("name", json.string({ v.1 }.name)),
          ])
        })
      wisp.json_response(
        json.to_string_builder(json.array(objects, function.identity)),
        200,
      )
    }
    ["games", "start"] -> {
      // create a new game by request of a user
      use <- wisp.require_method(req, Post)
      use json <- wisp.require_json(req)
      let assert Ok(res) = decode_start_game_data(json)

      let msg = fn(subject: Subject(games_manager.GamePid)) -> games_manager.GameSupervisorMsg {
        games_manager.CreateGame(
          reply_with: subject,
          requested_by_user_id: res.req_by,
          game_name: res.game_name,
        )
      }
      let game_id = process.call(games_manager_pr, msg, 10)
      wisp.json_response(
        json.to_string_builder(json.object([#("game_id", json.int(game_id))])),
        200,
      )
    }
    ["games"] -> {
      let subject = process.new_subject()
      let games =
        process.send(games_manager_pr, games_manager.ListAllGames(subject))
      io.debug(games)
      let body = string_builder.from_string("kek")
      wisp.html_response(body, 200)
    }
    _ -> wisp.not_found()
  }
  // Later we'll use templates, but for now a string will do.

  // Return a 200 OK response with the body and a HTML content type.
  wisp.log_info("request from " <> req.host)
  // wisp.html_response(body, 200)
  res
}
