module Yoyocomponent.Root (root) where

import Prelude

-- TODO: separate out the logic that actually gets and processes images
import Affjax.Web as AX
import Affjax.ResponseFormat (blob)
import Data.Bifunctor (bimap)
import Data.Either (either)
import Data.Traversable (traverse)
import Foreign.Jank (blobToOffscreen)
import Effect.Exception (error, throwException)

import Effect.Aff.Class (class MonadAff)
import DOM.HTML.Indexed.InputType as InputType
import Halogen as H
import Halogen.HTML as HTML
import Halogen.HTML.Events as Events
import Halogen.HTML.Properties as Prop

data Action = UrlInput String

type State =
  { inputUrl :: String
  }

root
  :: forall query input output m.
  MonadAff m =>
  H.Component query input output m
root = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval H.defaultEval { handleAction = handleAction }
  }

initialState :: forall a. a -> State
initialState _ =
  { inputUrl: ""
  }

render :: forall m. State -> H.ComponentHTML Action () m
render _ = HTML.div_
  [ HTML.h1_ [HTML.text "mentos cola!"]
  , HTML.input [Prop.type_ InputType.InputUrl, Events.onValueInput UrlInput]
  , HTML.p_
    [ HTML.text "this website, the 44ko manga reader, is free and open source software under the "
    , HTML.b_ [HTML.text "gnu affero general public license version 3.0 or later"]
    , HTML.text ". source code is available at "
    , HTML.a [Prop.href "https://github.com/UnrelatedString/44ko"]
      [ HTML.text "github.com/UnrelatedString/44ko"
      ]
    , HTML.text ", where bug reports and suggestions are also always welcome."
    ]
  ]


handleAction :: forall output m. MonadAff m => Action -> H.HalogenM State Action () output m Unit
handleAction (UrlInput url) = do
  response <- H.liftAff $ AX.get blob url 
  offscreen <- traverse
    (H.liftAff <<< blobToOffscreen)
    $ bimap (error <<< AX.printError) _.body response
  H.liftEffect $ either throwException (const $ pure unit) offscreen