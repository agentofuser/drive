module Types exposing (..)

{-| Root-level types.
-}

import Browser
import Browser.Navigation as Navigation
import ContextMenu exposing (ContextMenu)
import Debouncer.Messages as Debouncer exposing (Debouncer)
import Drive.Sidebar
import File exposing (File)
import Html.Events.Extra.Mouse as Mouse
import Ipfs
import Item exposing (Item)
import Json.Decode as Json
import Keyboard
import Management
import Routing exposing (Route)
import Time
import Url exposing (Url)



-- ⛩


{-| Flags passed initializing the application.
-}
type alias Flags =
    { foundation : Maybe Foundation
    }



-- 🌱


{-| Model of our UI state.
-}
type alias Model =
    { currentTime : Time.Posix
    , directoryList : Result String (List Item)
    , contextMenu : Maybe (ContextMenu Msg)
    , exploreInput : Maybe String
    , foundation : Maybe Foundation
    , ipfs : Ipfs.Status
    , isFocused : Bool
    , navKey : Navigation.Key
    , pressedKeys : List Keyboard.Key
    , route : Route
    , selectedCid : Maybe String
    , showLoadingOverlay : Bool
    , url : Url

    -----------------------------------------
    -- Debouncers
    -----------------------------------------
    , loadingDebouncer : Debouncer Msg

    -----------------------------------------
    -- Sidebar
    -----------------------------------------
    , expandSidebar : Bool
    , showPreviewOverlay : Bool
    , sidebarMode : Drive.Sidebar.Mode
    }



-- 📣


{-| Messages, or actions, that influence our `Model`.
-}
type Msg
    = Bypass
      -----------------------------------------
      -- Debouncers
      -----------------------------------------
    | LoadingDebouncerMsg (Debouncer.Msg Msg)
      -----------------------------------------
      -- Drive
      -----------------------------------------
    | ActivateSidebarMode Drive.Sidebar.Mode
    | AddFiles File (List File)
    | AskUserForFilesToAdd
    | CloseSidebar
    | CopyLink Item
    | DigDeeper { directoryName : String }
    | GoUp { floor : Int }
    | Select Item
    | ShowPreviewOverlay
    | ToggleExpandedSidebar
    | ToggleSidebarMode Drive.Sidebar.Mode
      -----------------------------------------
      -- Explore
      -----------------------------------------
    | Explore
    | GotInput String
    | Reset
      -----------------------------------------
      -- Ipfs
      -----------------------------------------
    | GotDirectoryList Json.Value
    | GotError String
    | GotResolvedAddress Foundation
    | ReplaceResolvedAddress { cid : String }
    | SetupCompleted
      -----------------------------------------
      -- 🐚 Other
      -----------------------------------------
    | Blurred
    | Focused
    | HideContextMenu
    | KeyboardInteraction Keyboard.Msg
    | LinkClicked Browser.UrlRequest
    | ScreenSizeChanged Int Int
    | ShowContextMenu (ContextMenu Msg) Mouse.Event
    | SetCurrentTime Time.Posix
    | ToggleLoadingOverlay { on : Bool }
    | UrlChanged Url


{-| State management.
-}
type alias Organizer model =
    Management.Manager Msg model


type alias Manager =
    Organizer Model



-- 🧩


type alias Foundation =
    { isDnsLink : Bool
    , resolved : String
    , unresolved : String
    }
