module Main where

import Prelude

import Effect (Effect)
import Halogen.Aff (runHalogenAff, awaitBody)
import Halogen.VDom.Driver (runUI)

import Yoyocomponent.Root (root)

main :: Effect Unit
main = runHalogenAff do
  body <- awaitBody
  runUI root unit body

