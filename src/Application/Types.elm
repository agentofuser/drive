module Types exposing (..)

{-| Root-level types.
-}

import Browser
import Browser.Navigation as Navigation
import Ipfs
import Item exposing (Item)
import Json.Decode as Json
import Management
import Routing exposing (Page)
import Time
import Url exposing (Url)



-- ⛩


{-| Flags passed initializing the application.
-}
type alias Flags =
    { rootCid : Maybe String
    }



-- 🌱


{-| Model of our UI state.
-}
type alias Model =
    { currentTime : Time.Posix
    , directoryList : Result String (List Item)
    , exploreInput : Maybe String
    , ipfs : Ipfs.Status
    , largePreview : Bool
    , navKey : Navigation.Key
    , page : Page
    , rootCid : Maybe String
    , selectedCid : Maybe String
    , showPreviewOverlay : Bool
    , url : Url
    }



-- 📣


{-| Messages, or actions, that influence our `Model`.
-}
type Msg
    = Bypass
      -----------------------------------------
      -- Drive
      -----------------------------------------
    | CopyLink Item
    | DigDeeper { directoryName : String }
    | GoUp { floor : Int }
    | RemoveSelection
    | Select Item
    | ShowPreviewOverlay
    | ToggleLargePreview
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
    | SetupCompleted
      -----------------------------------------
      -- Other
      -----------------------------------------
    | LinkClicked Browser.UrlRequest
    | SetCurrentTime Time.Posix
    | UrlChanged Url


{-| State management.
-}
type alias Organizer model =
    Management.Manager Msg model


type alias Manager =
    Organizer Model



-- 🧩
--
-- Nothing here yet.
-- Here go the other types.
