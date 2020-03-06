module Debouncing exposing (..)

import Debouncer.Messages as Debouncer exposing (Debouncer, fromSeconds)
import Return
import Types exposing (..)



-- LOADING


cancelLoading : Manager
cancelLoading model =
    Return.singleton { model | loadingDebouncer = Debouncer.cancel model.loadingDebouncer }


loading : Debouncer Msg
loading =
    Debouncer.manual
        |> Debouncer.settleWhenQuietFor (Just <| fromSeconds 1.5)
        |> Debouncer.toDebouncer


loadingInput : Msg -> Msg
loadingInput =
    Debouncer.provideInput >> LoadingDebouncerMsg


loadingUpdateConfig : Debouncer.UpdateConfig Msg Model
loadingUpdateConfig =
    { mapMsg = LoadingDebouncerMsg
    , getDebouncer = .loadingDebouncer
    , setDebouncer = \debouncer model -> { model | loadingDebouncer = debouncer }
    }