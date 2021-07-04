module Route exposing
    ( Route(..)
    , fromUrl
    , toLabel
    )

import Url exposing (Url)
import Url.Parser as P exposing (Parser)



---------------------------------------------------------------
-- TYPES --
---------------------------------------------------------------


type Route
    = Landing



---------------------------------------------------------------
-- API --
---------------------------------------------------------------


fromUrl : Url -> Maybe Route
fromUrl =
    P.parse parser


toLabel : Route -> String
toLabel route =
    case route of
        Landing ->
            "Landing"



---------------------------------------------------------------
-- INTERNAL HELPERS --
---------------------------------------------------------------


parser : Parser (Route -> a) a
parser =
    [ P.map Landing P.top ]
        |> P.oneOf
