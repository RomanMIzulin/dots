import gleam/string

// is user identified by socket?
pub type User {
  LogedUser(name: String, ip: String, created_at: String, id: Int)
  Visitor(ip: String, id: Int)
}

pub fn greet_user(user: User) {
  case user {
    Visitor(_, _) -> "Hello stranger"
    LogedUser(name, _, _, _) -> "Hello " <> name
  }
}

//get from user regisrty like running process or ets?
pub fn get_user(user_id: Int) -> User {
  LogedUser("kek", "kek", "kek", user_id)
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
