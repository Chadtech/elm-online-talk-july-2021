module Main exposing (main)

import Analytics
import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Html.Styled as Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Layout exposing (Document)
import Page.Home as Home
import Ports.Incoming
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Util.Cmd as CmdUtil



--------------------------------------------------------------------------------
-- MAIN --
--------------------------------------------------------------------------------


main : Program Decode.Value Model Msg
main =
    { init = init
    , view = Layout.toBrowserDocument << view
    , update = superUpdate
    , subscriptions = subscriptions
    , onUrlRequest = UrlRequested
    , onUrlChange = RouteChanged << Route.fromUrl
    }
        |> Browser.application



--------------------------------------------------------------------------------
-- TYPES --
--------------------------------------------------------------------------------


type Model
    = PageNotFound Session
    | Home Home.Model


type Msg
    = MsgDecodeFailed Ports.Incoming.Error
    | UrlRequested UrlRequest
    | RouteChanged (Maybe Route)
    | HomeMsg Home.Msg



--------------------------------------------------------------------------------
-- INIT --
--------------------------------------------------------------------------------


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init json url navKey =
    let
        session : Session
        session =
            Session.init navKey
    in
    PageNotFound session
        |> handleRouteChange (Route.fromUrl url)



--------------------------------------------------------------------------------
-- INTERNAL HELPERS --
--------------------------------------------------------------------------------


getSession : Model -> Session
getSession model =
    case model of
        PageNotFound session ->
            session

        Home subModel ->
            Home.getSession subModel


pageName : Model -> String
pageName model =
    case model of
        PageNotFound _ ->
            "not found"

        Home _ ->
            "home"



--------------------------------------------------------------------------------
-- UPDATE --
--------------------------------------------------------------------------------


superUpdate : Msg -> Model -> ( Model, Cmd Msg )
superUpdate msg model =
    let
        analyticsEvent : Analytics.Event
        analyticsEvent =
            track msg

        --|> Analytics.withProp "pageName" (Encode.string <| pageName model)
        ( newModel, cmd ) =
            update msg model
    in
    ( newModel
    , Cmd.batch
        [ cmd
        , analyticsEvent
            |> Analytics.toCmd
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgDecodeFailed _ ->
            model
                |> CmdUtil.withNoCmd

        UrlRequested _ ->
            model
                |> CmdUtil.withNoCmd

        RouteChanged maybeRoute ->
            handleRouteChange maybeRoute model

        HomeMsg subMsg ->
            case model of
                Home subModel ->
                    Home.update subMsg subModel
                        |> CmdUtil.mapBoth Home HomeMsg

                _ ->
                    ( model, Cmd.none )


handleRouteChange : Maybe Route -> Model -> ( Model, Cmd Msg )
handleRouteChange maybeRoute model =
    let
        session =
            getSession model
    in
    case maybeRoute of
        Nothing ->
            PageNotFound session
                |> CmdUtil.withNoCmd

        Just route ->
            case route of
                Route.Landing ->
                    ( Home <| Home.init session
                    , Cmd.none
                    )


track : Msg -> Analytics.Event
track msg =
    case msg of
        MsgDecodeFailed error ->
            case error of
                Ports.Incoming.NotFound _ ->
                    Analytics.none

                Ports.Incoming.BodyDecodeFail portName _ ->
                    Analytics.name
                        "Port Msg decode fail"
                        |> Analytics.withProp "portName" (Encode.string portName)

                Ports.Incoming.StructureDecodeFail _ ->
                    Analytics.name "Port Msg structure decode fail"

        UrlRequested _ ->
            Analytics.none

        RouteChanged maybeRoute ->
            Analytics.name "route changed"
                |> Analytics.withProp "route"
                    (maybeRoute
                        |> Maybe.map Route.toLabel
                        |> Maybe.withDefault "unrecognized route"
                        |> Encode.string
                    )

        HomeMsg subMsg ->
            Home.track subMsg



--------------------------------------------------------------------------------
-- VIEW --
--------------------------------------------------------------------------------


view : Model -> Document Msg
view model =
    case model of
        PageNotFound _ ->
            Layout.document
                "Page not found"
                [ Html.text "Page not found!" ]

        Home subModel ->
            Home.view subModel
                |> Layout.map HomeMsg



--------------------------------------------------------------------------------
-- SUBSCRIPTIONS --
--------------------------------------------------------------------------------


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.Incoming.subscription
        MsgDecodeFailed
        (incomingPortsListeners model)


incomingPortsListeners : Model -> Ports.Incoming.Listener Msg
incomingPortsListeners model =
    case model of
        PageNotFound _ ->
            Ports.Incoming.none

        Home _ ->
            Ports.Incoming.map HomeMsg Home.incomingPortsListener
