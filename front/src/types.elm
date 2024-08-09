type UserStatus
  = Regular
  | Visitor

type alias User =
  { status : UserStatus
  , name : String
  }

