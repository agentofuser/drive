module Other.State exposing (..)

import Browser
import Browser.Navigation as Navigation
import Drive.State as Drive
import Fs.State as Fs
import Ipfs
import Keyboard
import Maybe.Extra as Maybe
import Ports
import Return exposing (return)
import Return.Extra as Return
import Routing exposing (Route(..))
import Time
import Types exposing (..)
import Url exposing (Url)



-- 🛠


keyboardInteraction : Keyboard.Msg -> Manager
keyboardInteraction msg unmodified =
    (if unmodified.isFocused then
        []

     else
        Keyboard.update msg unmodified.pressedKeys
    )
        |> (\p ->
                { unmodified | pressedKeys = p }
           )
        |> (\m ->
                case m.pressedKeys of
                    [ Keyboard.ArrowDown ] ->
                        Drive.selectNextItem m

                    [ Keyboard.ArrowUp ] ->
                        Drive.selectPreviousItem m

                    [ Keyboard.Character "T" ] ->
                        Drive.toggleExpandedSidebar m

                    [ Keyboard.Character "U" ] ->
                        Drive.goUpOneLevel m

                    [ Keyboard.Enter ] ->
                        Drive.digDeeperUsingSelection m

                    [ Keyboard.Escape ] ->
                        Drive.closeSidebar m

                    _ ->
                        Return.singleton m
           )


screenSizeChanged : Int -> Int -> Manager
screenSizeChanged width height model =
    let
        viewportSize =
            { height = height
            , width = width
            }
    in
    Return.singleton { model | contextMenu = Nothing, viewportSize = viewportSize }


setCurrentTime : Time.Posix -> Manager
setCurrentTime time model =
    Return.singleton { model | currentTime = time }



-- FOCUS


{-| Some element has lost focus.
-}
blurred : Manager
blurred model =
    Return.singleton { model | isFocused = False }


{-| Some element has received focus.
-}
focused : Manager
focused model =
    Return.singleton { model | isFocused = True }



-- URL


linkClicked : Browser.UrlRequest -> Manager
linkClicked urlRequest model =
    case urlRequest of
        Browser.Internal url ->
            return model (Navigation.pushUrl model.navKey <| Url.toString url)

        Browser.External href ->
            return model (Navigation.load href)


redirectToLobby : Manager
redirectToLobby =
    Return.communicate (Ports.redirectToLobby ())


toggleLoadingOverlay : { on : Bool } -> Manager
toggleLoadingOverlay { on } model =
    Return.singleton { model | showLoadingOverlay = on }


{-| This function is responsible for changing the application state based on the URL.

Scenarios include:

  - Listing a directory
  - Resolving a new foundation

-}
urlChanged : Url -> Manager
urlChanged url old =
    let
        stillConnecting =
            old.ipfs == Ipfs.Connecting

        route =
            Routing.routeFromUrl old.mode url

        newRoot =
            Routing.treeRoot url route

        oldRoot =
            Routing.treeRoot url old.route

        isTreeRoute =
            Maybe.isJust newRoot

        needsResolve =
            newRoot /= Maybe.map .unresolved old.foundation

        isInitialListing =
            oldRoot /= Maybe.map .unresolved old.foundation
    in
    { old
        | ipfs =
            if stillConnecting || not isTreeRoute || needsResolve then
                old.ipfs

            else if isInitialListing then
                Ipfs.InitialListing

            else
                Ipfs.AdditionalListing

        --
        , foundation =
            if needsResolve then
                Nothing

            else
                old.foundation

        --
        , route = route
        , selectedPath = Nothing
        , url = url
    }
        |> (\new ->
                if stillConnecting || not isTreeRoute then
                    Return.singleton new

                else if needsResolve then
                    newRoot
                        |> Maybe.map Ports.ipfsResolveAddress
                        |> Maybe.withDefault Cmd.none
                        |> return new

                else if new.route /= old.route && Maybe.isJust old.foundation then
                    if Maybe.map .unresolved old.foundation == Maybe.map .username old.authenticated && isInitialListing then
                        case old.foundation of
                            Just f ->
                                Fs.load f new

                            Nothing ->
                                Return.singleton new

                    else
                        Fs.listDirectory new

                else
                    Return.singleton new
           )
