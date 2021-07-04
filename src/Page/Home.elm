module Page.Home exposing
    ( Model
    , Msg
    , getSession
    , incomingPortsListener
    , init
    , track
    , update
    , view
    )

import Analytics
import Css
import Html.Styled as Html exposing (Html)
import Html.Styled.Attributes as Attr
import Html.Styled.Events as Ev
import Layout exposing (Document)
import Ports.Incoming
import Session exposing (Session)
import Util.Html as HtmlUtil



--------------------------------------------------------------------------------
-- NOTES --
--------------------------------------------------------------------------------


notes =
    """
    Goals:
    - Speedrun through an OK implementation of doing analytics
    - Show you a "better" implementation of analytics
    - Generalize the "better" implementation so you can use it for
      all kinds of different things
    """



-------------------------------------------------------------------------------
-- TYPES --
-------------------------------------------------------------------------------


type alias Model =
    { session : Session
    , field : String
    , savedValue : Maybe String
    , open : Bool
    }


type Msg
    = SaveClicked
    | EnterPressed
    | CloseClicked
    | OpenClicked
    | FieldChanged String



--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------


init : Session -> Model
init session =
    { session = session
    , field = initialFieldValue
    , savedValue = Nothing
    , open = True
    }



--------------------------------------------------------------------------------
-- INTERNAL HELPERS --
--------------------------------------------------------------------------------


initialFieldValue : String
initialFieldValue =
    ""


setField : String -> Model -> Model
setField newField model =
    { model | field = newField }


save : Model -> Model
save model =
    { model | savedValue = Just model.field }
        |> setField initialFieldValue
        |> close


open : Model -> Model
open =
    setOpen True


close : Model -> Model
close =
    setOpen False


setOpen : Bool -> Model -> Model
setOpen b model =
    { model | open = b }



--------------------------------------------------------------------------------
-- API --
--------------------------------------------------------------------------------


getSession : Model -> Session
getSession model =
    model.session



--------------------------------------------------------------------------------
-- UPDATE --
--------------------------------------------------------------------------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveClicked ->
            ( save model
            , Cmd.none
            )

        EnterPressed ->
            ( save model
            , Cmd.none
            )

        CloseClicked ->
            ( close model
            , Cmd.none
            )

        OpenClicked ->
            ( open model
            , Cmd.none
            )

        FieldChanged field ->
            ( setField field model
            , Cmd.none
            )



--------------------------------------------------------------------------------
-- ANALYTICS --
--------------------------------------------------------------------------------


track : Msg -> Analytics.Event
track msg =
    case msg of
        SaveClicked ->
            Analytics.name "save clicked"

        EnterPressed ->
            Analytics.name "enter pressed"

        CloseClicked ->
            Analytics.name "close clicked"

        OpenClicked ->
            Analytics.name "open clicked"

        FieldChanged field ->
            Analytics.none



--------------------------------------------------------------------------------
-- VIEW --
--------------------------------------------------------------------------------


view : Model -> Document Msg
view model =
    let
        titleText : String
        titleText =
            "Form"

        title : Html Msg
        title =
            Html.div
                [ Attr.css
                    [ Css.justifyContent Css.center
                    , Css.displayFlex
                    , Css.flexDirection Css.column
                    ]
                ]
                [ Html.text titleText ]

        openCloseButton : Html Msg
        openCloseButton =
            let
                label : String
                label =
                    if model.open then
                        "Close"

                    else
                        "Open"

                clickMsg : Msg
                clickMsg =
                    if model.open then
                        CloseClicked

                    else
                        OpenClicked
            in
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.column
                    , Css.justifyContent Css.center
                    , Css.marginRight gapSize
                    ]
                ]
                [ Html.button
                    [ Ev.onClick clickMsg ]
                    [ Html.text label ]
                ]

        header : Html Msg
        header =
            Html.div
                [ Attr.css
                    [ Css.displayFlex
                    , Css.flexDirection Css.row
                    , Css.marginBottom gapSize
                    ]
                ]
                [ openCloseButton
                , title
                ]

        body : List (Html Msg)
        body =
            if model.open then
                bodyView
                    { field = model.field
                    , savedValue = model.savedValue
                    }

            else if model.savedValue /= Nothing then
                [ Html.div
                    []
                    [ Html.text "Value saved! Thank you" ]
                ]

            else
                []
    in
    Layout.document titleText (header :: body)


bodyView : { field : String, savedValue : Maybe String } -> List (Html Msg)
bodyView args =
    let
        inputField : Html Msg
        inputField =
            Html.input
                [ Attr.value args.field
                , Ev.onInput FieldChanged
                , Attr.placeholder "Press enter to save"
                , Attr.autofocus True
                , Attr.spellcheck False
                , HtmlUtil.onEnter EnterPressed
                ]
                []

        previousValue : Html Msg
        previousValue =
            case args.savedValue of
                Just value ->
                    let
                        msg : String
                        msg =
                            "There is an existing saved value : " ++ value
                    in
                    Html.div
                        []
                        [ Html.text msg ]

                Nothing ->
                    Html.text ""

        saveButton : Html Msg
        saveButton =
            Html.div
                [ Attr.css
                    [ Css.marginTop gapSize ]
                ]
                [ Html.button
                    [ Ev.onClick SaveClicked ]
                    [ Html.text "Save" ]
                ]
    in
    [ inputField
    , previousValue
    , saveButton
    ]


gapSize : Css.Rem
gapSize =
    Css.rem 1



--------------------------------------------------------------------------------
-- PORTS --
--------------------------------------------------------------------------------


incomingPortsListener : Ports.Incoming.Listener Msg
incomingPortsListener =
    Ports.Incoming.none
