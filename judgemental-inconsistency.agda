open import Nat
open import Prelude
open import core

module judgemental-inconsistency where
  data incon : τ̇ → τ̇ → Set where
    ICNumArr1 : {t1 t2 : τ̇} → incon num (t1 ==> t2)
    ICNumArr2 : {t1 t2 : τ̇} → incon (t1 ==> t2) num
    ICArr1 : {t1 t2 t3 t4 : τ̇} →
               incon t1 t3 →
               incon (t1 ==> t2) (t3 ==> t4)
    ICArr2 : {t1 t2 t3 t4 : τ̇} →
               incon t2 t4 →
               incon (t1 ==> t2) (t3 ==> t4)

  -- inconsistency is symmetric
  inconsym : ∀ {t1 t2} → incon t1 t2 → incon t2 t1
  inconsym ICNumArr1 = ICNumArr2
  inconsym ICNumArr2 = ICNumArr1
  inconsym (ICArr1 x) = ICArr1 (inconsym x)
  inconsym (ICArr2 x) = ICArr2 (inconsym x)

  --inconsistency isn't reflexive
  incon-nrefl : ∀{t} → incon t t → ⊥
  incon-nrefl (ICArr1 x) = incon-nrefl x
  incon-nrefl (ICArr2 x) = incon-nrefl x

  -- first half of iso
  to~̸ : (t1 t2 : τ̇) → incon t1 t2 → t1 ~̸ t2
  to~̸ .num ._ ICNumArr1 ()
  to~̸ ._ .num ICNumArr2 ()
  to~̸ ._ ._ (ICArr1 incon) TCRefl = abort (incon-nrefl incon)
  to~̸ ._ ._ (ICArr1 incon) (TCArr x x₁) = to~̸ _ _ incon x
  to~̸ ._ ._ (ICArr2 incon) TCRefl = abort (incon-nrefl incon)
  to~̸ ._ ._ (ICArr2 incon) (TCArr x x₁) = (to~̸ _ _ incon x₁)

  -- second half of iso
  from~̸ : (t1 t2 : τ̇) → t1 ~̸ t2 → incon t1 t2
  from~̸ num (t2 ==> t3) ncon = ICNumArr1
  from~̸ (t1 ==> t2) num ncon = ICNumArr2
  from~̸ (t1 ==> t2) (t3 ==> t4) ncon with ~dec t1 t3 | ~dec t2 t4
  from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inl x | qq = ICArr2 (from~̸ _ _ (λ a → ncon (TCArr x a)))
  from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inr x | Inl x₁ = ICArr1 (from~̸ _ _ (λ a → ncon (TCArr a x₁)))
  from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inr x | Inr x₁ = {!!}

  -- from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inl x | Inl y = abort (ncon (TCArr x y))
  -- from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inl x | Inr y = ICArr2 (from~̸ t2 t4 y)
  -- from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inr x | Inl y = ICArr1 (from~̸ t1 t3 x)
  -- from~̸ (t1 ==> t2) (t3 ==> t4) ncon | Inr x | Inr y = {!!}

  -- ... | Inl qq = ICArr2 (from~̸ _ _ (λ x → ncon (TCArr qq x)))
  -- ... | Inr qq = ICArr1 (from~̸ _ _ qq)
  -- the remaining consistent types all lead to absurdities
  from~̸ num num ncon = abort (ncon TCRefl)
  from~̸ num ⦇⦈ ncon = abort (ncon TCHole1)
  from~̸ ⦇⦈ num ncon = abort (ncon TCHole2)
  from~̸ ⦇⦈ ⦇⦈ ncon = abort (ncon TCRefl)
  from~̸ ⦇⦈ (t2 ==> t3) ncon = abort (ncon TCHole2)
  from~̸ (t1 ==> t2) ⦇⦈ ncon = abort (ncon TCHole1)

  -- need to display that at least one of the round-trips above is stable
  -- for this to be structure preserving and really an iso.
  rt1 : (t1 t2 : τ̇) → (x : t1 ~̸ t2) → (to~̸ t1 t2 (from~̸ t1 t2 x)) == x
  rt1 num (t2 ==> t3) x         = funext (λ x₁ → abort (x x₁))
  rt1 (t1 ==> t2) num x         = funext (λ x₁ → abort (x x₁))
  rt1 (t1 ==> t2) (t3 ==> t4) x = funext (λ x₁ → abort (x x₁))
  rt1 num num x                 = abort (x TCRefl)
  rt1 num ⦇⦈ x                  = abort (x TCHole1)
  rt1 ⦇⦈ num x                  = abort (x TCHole2)
  rt1 ⦇⦈ ⦇⦈ x                   = abort (x TCRefl)
  rt1 ⦇⦈ (t2 ==> t3) x          = abort (x TCHole2)
  rt1 (t1 ==> t2) ⦇⦈ x          = abort (x TCHole1)

  rt2 : (t1 t2 : τ̇) → (x : incon t1 t2) → (from~̸ t1 t2 (to~̸ t1 t2 x)) == x
  rt2 num num ()
  rt2 num ⦇⦈ ()
  rt2 num (t2 ==> t3) ICNumArr1 = refl
  rt2 ⦇⦈ num ()
  rt2 ⦇⦈ ⦇⦈ ()
  rt2 ⦇⦈ (t2 ==> t3) ()
  rt2 (t1 ==> t2) num ICNumArr2 = refl
  rt2 (t1 ==> t2) ⦇⦈ ()
  rt2 (t1 ==> t2) (t3 ==> t4) x with ~dec t1 t3 | ~dec t2 t4
  rt2 (t1 ==> t2) (t3 ==> t4) x₂ | Inl x | Inl y = abort (to~̸ _ _ x₂ (TCArr x y))
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr1 x₂) | Inl x | Inr y = abort (to~̸ _ _ x₂ x)
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr2 x₂) | Inl x | Inr y = ap1 ICArr2 (rt2 t2 t4 x₂)
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr1 x₂) | Inr x | Inl y = ap1 ICArr1 (rt2 t1 t3 x₂)
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr2 x₂) | Inr x | Inl y = abort (to~̸ _ _ x₂ y)
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr1 x₂) | Inr x | Inr y = {!!}
  rt2 (t1 ==> t2) (t3 ==> t4) (ICArr2 x₂) | Inr x | Inr y = {!!}

  -- ~dec t1 t3
  -- rt2 (t1 ==> t2) (t3 ==> t4) (ICArr1 x₁) | Inl x = abort (to~̸ t1 t3 x₁ x)
  -- rt2 (t1 ==> t2) (t3 ==> t4) (ICArr2 x₁) | Inl x = ap1 ICArr2 (rt2 t2 t4 x₁)
  -- rt2 (t1 ==> t2) (t3 ==> t4) (ICArr1 y)  | Inr x = ap1 ICArr1 (rt2 t1 t3 y)
  -- rt2 (t1 ==> t2) (t3 ==> t4) (ICArr2 y)  | Inr x = {!!}

  incon-iso : (t1 t2 : τ̇) → (incon t1 t2) ≃ (t1 ~̸ t2)
  incon-iso t1 t2 = (to~̸ t1 t2) , (from~̸ t1 t2) , (rt2 t1 t2) , (rt1 t1 t2)
