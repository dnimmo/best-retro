module Email exposing (Email, create, isValid, value)

import Html exposing (address)
import Test.Runner exposing (SeededRunners(..))
import Validate


type Email
    = Email { address : String } EmailType


type EmailType
    = Valid
    | Invalid


create : String -> Email
create address =
    Email { address = address } <|
        if Validate.isValidEmail address then
            Valid

        else
            Invalid


isValid : Email -> Bool
isValid (Email _ emailType) =
    emailType == Valid


value : Email -> String
value (Email { address } _) =
    address
