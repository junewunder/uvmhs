module UVMHS.Core.Data.Choice where

import UVMHS.Core.Init
import UVMHS.Core.Classes

instance Functor ((∨) a) where 
  {-# INLINE map #-}
  map f = \case
    Inl x → Inl x
    Inr y → Inr $ f y
instance Return ((∨) a) where 
  {-# INLINE return #-}
  return = Inr
instance Bind ((∨) a) where
  {-# INLINE (≫=) #-}
  Inl x ≫= _ = Inl x
  Inr y ≫= k = k y
instance Monad ((∨) a)
instance FunctorM ((∨) a) where
  {-# INLINE mapM #-}
  mapM f = \case
    Inl x → return $ Inl x
    Inr y → do
      y' ← f y
      return $ Inr y'

instance (Null b) ⇒ Null (a ∨ b) where 
  {-# INLINE null #-}
  null = Inr null
instance (Append a,Append b) ⇒ Append (a ∨ b) where 
  {-# INLINE (⧺) #-}
  Inl x ⧺ Inl y = Inl (x ⧺ y)
  Inl x ⧺ Inr _ = Inl x
  Inr _ ⧺ Inl y = Inl y
  Inr x ⧺ Inr y = Inr (x ⧺ y)
instance (Append a,Monoid b) ⇒ Monoid (a ∨ b) 

{-# INLINE elimChoice #-}
elimChoice ∷ (a → c) → (b → c) → a ∨ b → c
elimChoice f₁ f₂ = \case
  Inl x → f₁ x
  Inr y → f₂ y

{-# INLINE mapChoice #-}
mapChoice ∷ (a₁ → a₂) → (b₁ → b₂) → a₁ ∨ b₁ → a₂ ∨ b₂
mapChoice f g = elimChoice (Inl ∘ f) (Inr ∘ g)

{-# INLINE mapInl #-}
mapInl ∷ (a₁ → a₂) → a₁ ∨ b → a₂ ∨ b
mapInl f = mapChoice f id

{-# INLINE mapInr #-}
mapInr ∷ (b₁ → b₂) → a ∨ b₁ → a ∨ b₂
mapInr f = mapChoice id f
