module UVMHS.Core.Classes.FunctorM where

import UVMHS.Init

import UVMHS.Core.Classes.Monad

class FunctorM (t ∷ ★ → ★) where mapM ∷ (Monad m) ⇒ (a → m b) → t a → m (t b)

mapMOn ∷ (Monad m,FunctorM t) ⇒ t a → (a → m b) → m (t b)
mapMOn = flip mapM
