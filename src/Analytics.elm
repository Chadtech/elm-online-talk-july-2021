module Analytics exposing
    ( Event
    , name
    , none
    , toCmd
    , withProp
    )

import Json.Encode as Encode
import Ports.Outgoing



-------------------------------------------------------------------------------
-- TYPES --
-------------------------------------------------------------------------------


type Event
    = Event { name : String, props : List ( String, Encode.Value ) }
    | None



-------------------------------------------------------------------------------
-- API --
-------------------------------------------------------------------------------


name : String -> Event
name str =
    Event { name = str, props = [] }


none : Event
none =
    None


withProp : String -> Encode.Value -> Event -> Event
withProp propName propVal event =
    case event of
        None ->
            None

        Event e ->
            Event { name = e.name, props = ( propName, propVal ) :: e.props }


toCmd : Event -> Cmd msg
toCmd event =
    case event of
        Event payload ->
            Ports.Outgoing.fromType_ "analytics_event"
                |> Ports.Outgoing.fieldsBody
                    [ Tuple.pair "eventName" <| Encode.string payload.name
                    , Tuple.pair "props" <| Encode.object payload.props
                    ]
                |> Ports.Outgoing.send

        None ->
            Cmd.none
