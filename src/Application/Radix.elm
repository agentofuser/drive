module Radix exposing (..)

{-| Root-level types.
-}

import Authentication.Essentials as Authentication
import Browser
import Browser.Navigation as Navigation
import ContextMenu exposing (ContextMenu)
import Coordinates exposing (Coordinates)
import Debouncer.Messages as Debouncer exposing (Debouncer)
import Drive.Item exposing (Item)
import Drive.Item.Inventory as Item
import Drive.Sidebar
import FileSystem
import Html.Events.Extra.Mouse as Mouse
import Json.Decode as Json
import Keyboard
import Management
import Modal exposing (Modal)
import Notifications exposing (Notification)
import Routing exposing (Route)
import Time
import Toasty
import Url exposing (Url)



-- ⛩


{-| Flags passed initializing the application.
-}
type alias Flags =
    { currentTime : Int
    , usersDomain : String
    , viewportSize : { height : Int, width : Int }
    }



-- 🌱


{-| Model of our UI state.
-}
type alias Model =
    { authenticated : Maybe Authentication.Essentials
    , currentTime : Time.Posix
    , directoryList : Result String Item.Inventory
    , contextMenu : Maybe (ContextMenu Msg)
    , dragndropMode : Bool
    , helpfulNote : Maybe { faded : Bool, note : String }
    , isFocused : Bool
    , fileSystemCid : Maybe String
    , fileSystemStatus : FileSystem.Status
    , modal : Maybe (Modal Msg)
    , navKey : Navigation.Key
    , pressedKeys : List Keyboard.Key
    , route : Route
    , viewportSize : { height : Int, width : Int }
    , showLoadingOverlay : Bool
    , toasties : Toasty.Stack (Notification Msg)
    , url : Url
    , usersDomain : String

    -----------------------------------------
    -- Debouncers
    -----------------------------------------
    , loadingDebouncer : Debouncer Msg
    , notificationsDebouncer : Debouncer Msg

    -----------------------------------------
    -- Sidebar
    -----------------------------------------
    , sidebarExpanded : Bool
    , sidebar : Maybe Drive.Sidebar.Model
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
    | NotificationsDebouncerMsg (Debouncer.Msg Msg)
      -----------------------------------------
      -- Drive
      -----------------------------------------
    | ActivateSidebarAddOrCreate
    | AddFiles { blobs : List { path : String, url : String } }
    | ClearSelection
    | CloseSidebar
    | CopyPublicUrl { item : Item, presentable : Bool }
    | CopyToClipboard { clip : String, notification : String }
    | CreateFileOrFolder (Maybe { extension : String })
    | DigDeeper { directoryName : String }
    | DownloadItem Item
    | GotAddOrCreateInput String
    | GoUp { floor : Int }
    | IndividualSelect Int Item
    | RangeSelect Int Item
    | RemoveItem Item
    | RemoveSelectedItems
    | RenameItem Item
    | Select Int Item
    | ShowRenameItemModal Item
    | ToggleExpandedSidebar
    | ToggleSidebarAddOrCreate
    | SidebarMsg Drive.Sidebar.Msg
      -----------------------------------------
      -- File System
      -----------------------------------------
    | GotFsDirectoryList Json.Value
    | GotFsError String
    | GotFsItemUtf8 { pathSegments : List String, text : String }
      -----------------------------------------
      -- 🌏 Common
      -----------------------------------------
    | GoToRoute Route
    | HideHelpfulNote
    | HideModal
    | RemoveContextMenu
    | RemoveHelpfulNote
    | Reset Route
    | SetModalState String String
    | ShowContextMenu (ContextMenu Msg) Mouse.Event
    | ShowContextMenuWithCoordinates Coordinates (ContextMenu Msg)
    | ShowHelpfulNote String
      -----------------------------------------
      -- 🐚 Other
      -----------------------------------------
    | Blurred
    | Focused
    | HideWelcomeMessage
    | Initialise (Maybe Authentication.Essentials)
    | KeyboardInteraction Keyboard.Msg
    | LinkClicked Browser.UrlRequest
    | LostWindowFocus
    | RedirectToLobby
    | ScreenSizeChanged Int Int
    | SetCurrentTime Time.Posix
    | ToastyMsg (Toasty.Msg (Notification Msg) Model)
    | ToggleLoadingOverlay { on : Bool }
    | UrlChanged Url


{-| State management.
-}
type alias Organizer model =
    Management.Manager Msg model


type alias Manager =
    Organizer Model
