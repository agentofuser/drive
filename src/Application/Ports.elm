port module Ports exposing (..)

import Json.Decode as Json



-- 📣


port ipfsListDirectory : String -> Cmd msg


port ipfsSetup : () -> Cmd msg



-- 📰


port ipfsCompletedSetup : (() -> msg) -> Sub msg


port ipfsGotDirectoryList : (Json.Value -> msg) -> Sub msg
