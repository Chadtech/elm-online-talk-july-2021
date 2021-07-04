module Style exposing
    ( black
    , globals
    , lightGray
    , red
    , white0
    , white1
    )

import Css exposing (..)
import Css.Global exposing (global)
import Html.Styled exposing (Html)


globals : Html msg
globals =
    [ Css.Global.everything
        [ margin zero
        , padding zero
        ]
    , Css.Global.p
        [ color black ]
    , Css.Global.input
        [ color black
        , outline none
        , width (rem 32)
        , padding <| rem 0.5
        ]
    , Css.Global.button
        [ padding <| rem 0.5
        , minWidth <| rem 4
        ]
    , Css.Global.body
        [ padding <| rem 2
        , displayFlex
        , flexDirection column
        , fontFamilies [ "Arial" ]
        ]
    ]
        |> global



--------------------------------------------------------------------------------
-- COLORS --
--------------------------------------------------------------------------------


black : Color
black =
    hex "#030907"


white0 : Color
white0 =
    hex "#fcf7f9"


white1 : Color
white1 =
    hex "#f9fcfb"


lightGray : Color
lightGray =
    hex "#d0b5a9"


red : Color
red =
    hex "#f21d23"
