import gleam/dict.{type Dict}
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/otp/actor
import gleam/string

// is user identified by socket?
// it is better to have funcs with User as the first arg to be able to use pipe operator
pub type User {
  User(name: String, ip: String, created_at: String, id: Int)
}

pub fn greet_user(user: User) {
  case user {
    User(name, _, _, _) -> "Hello " <> name
  }
}

//get from user regisrty like running process or ets?
pub fn get_user(user_id: Int) -> User {
  User("kek", "kek", "kek", user_id)
}

pub fn validate_reg_info(
  username: String,
  password: String,
) -> Result(String, String) {
  let name_len = string.length(username)
  let pass_len = string.length(password)
  case name_len < 15, name_len > 3 {
    True, True ->
      case pass_len > 5 {
        True -> Ok("Allright budy")
        False -> Error("Password should be longer")
      }

    _, _ -> Error("invalid length of username. It should be more than 3")
  }
}

pub type Message {
  UserMessage(sender_id: Int, text: String)
  SystemMessage
}

pub type Chat {
  UserChat(user1: User, user2: User, msgs: List(Message))
  SystemChat(user1: User, msgs: List(Message))
}

pub opaque type UsersManager {
  UsersManager(users: Dict(Int, User))
}

pub fn create_users_manager() -> UsersManager {
  // is it just state actully?
  // here need to get users from disc or Mnesia, but for now just return empty state
  UsersManager(users: dict.new())
}

pub type UsersManagerMessage {
  // Reg user
  AddUser(name: String, ip: String)
  GetUser(client: Subject(Result(User, Nil)), user_id: Int)
  RemoveUser(Int)
  SendMessage(Int, Int, String)
}

pub fn start_users_manager() {
  actor.start(create_users_manager(), handle_users_manager_message)
}

pub fn handle_users_manager_message(
  message: UsersManagerMessage,
  state: UsersManager,
) -> actor.Next(UsersManagerMessage, UsersManager) {
  case message {
    AddUser(name, ip) -> {
      let generated_id = int.random(65_536)
      let new_state =
        UsersManager(
          users: state.users
          |> dict.insert(generated_id, User(name, ip, "kek", generated_id)),
        )
      actor.continue(new_state)
    }
    GetUser(client, user_id) -> {
      process.send(client, dict.get(state.users, user_id))
      actor.continue(state)
    }
    _ -> actor.continue(state)
  }
}
