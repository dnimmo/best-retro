module User exposing (User, getName, getUser)


type alias ID =
    String


type User
    = User
        { id : ID
        , name : String
        , email : String
        }


getName : User -> String
getName (User { name }) =
    name


getUser : User
getUser =
    -- Eventually this will actually fetch a user properly
    User
        { id = "123"
        , name = "John Doe"
        , email = "dnimmo@gmail.com"
        }
