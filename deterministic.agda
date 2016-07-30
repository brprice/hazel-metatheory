open import Nat
open import Prelude
open import core
open import judgemental-erase

module deterministic where
  -- the same action applied to the same type makes the same type
  actdet1 : {t t' t'' : τ̂} {α : action} →
            (t + α +> t') →
            (t + α +> t'') →
            (t' == t'')
  actdet1 TMArrFirstChild TMArrFirstChild = refl
  actdet1 TMArrParent1 TMArrParent1 = refl
  actdet1 TMArrParent1 (TMArrZip1 ())
  actdet1 TMArrParent2 TMArrParent2 = refl
  actdet1 TMArrParent2 (TMArrZip2 ())
  actdet1 TMArrNextSib TMArrNextSib = refl
  actdet1 TMArrNextSib (TMArrZip1 ())
  actdet1 TMDel TMDel = refl
  actdet1 TMConArrow TMConArrow = refl
  actdet1 TMConNum TMConNum = refl
  actdet1 (TMArrZip1 ()) TMArrParent1
  actdet1 (TMArrZip1 ()) TMArrNextSib
  actdet1 (TMArrZip1 p1) (TMArrZip1 p2) with actdet1 p1 p2
  ... | refl = refl
  actdet1 (TMArrZip2 ()) TMArrParent2
  actdet1 (TMArrZip2 p1) (TMArrZip2 p2) with actdet1 p1 p2
  ... | refl = refl

  -- all expressions only move to one other expression
  movedet : {e e' e'' : ê} {δ : direction} →
            (e + move δ +>e e') →
            (e + move δ +>e e'') →
            e' == e''
  movedet EMAscFirstChild EMAscFirstChild = refl
  movedet EMAscParent1 EMAscParent1 = refl
  movedet EMAscParent2 EMAscParent2 = refl
  movedet EMAscNextSib EMAscNextSib = refl
  movedet EMLamFirstChild EMLamFirstChild = refl
  movedet EMLamParent EMLamParent = refl
  movedet EMPlusFirstChild EMPlusFirstChild = refl
  movedet EMPlusParent1 EMPlusParent1 = refl
  movedet EMPlusParent2 EMPlusParent2 = refl
  movedet EMPlusNextSib EMPlusNextSib = refl
  movedet EMApFirstChild EMApFirstChild = refl
  movedet EMApParent1 EMApParent1 = refl
  movedet EMApParent2 EMApParent2 = refl
  movedet EMApNextSib EMApNextSib = refl
  movedet EMNEHoleFirstChild EMNEHoleFirstChild = refl
  movedet EMNEHoleParent EMNEHoleParent = refl

  -- non-movement lemmas; theses show up pervasively throughout and save a
  -- lot of pattern matching.
  lem-nomove-part : ∀ {t t'} → ▹ t ◃ + move parent +> t' → ⊥
  lem-nomove-part ()

  lem-nomove-pars : ∀{Γ e t e' t'} → Γ ⊢ ▹ e ◃ => t ~ move parent ~> e' => t' → ⊥
  lem-nomove-pars (SAMove ())

  lem-nomove-nss : ∀{Γ e t e' t'} → Γ ⊢ ▹ e ◃ => t ~ move nextSib ~> e' => t' → ⊥
  lem-nomove-nss (SAMove ())

  lem-nomove-para : ∀{Γ e t e'} → Γ ⊢ ▹ e ◃ ~ move parent ~> e' ⇐ t → ⊥
  lem-nomove-para (AASubsume e x x₁ x₂) = lem-nomove-pars x₁
  lem-nomove-para (AAMove ())

  lem-nomove-nsa : ∀{Γ e t e'} → Γ ⊢ ▹ e ◃ ~ move nextSib ~> e' ⇐ t → ⊥
  lem-nomove-nsa (AASubsume e  x x₁ x₂) = lem-nomove-nss x₁
  lem-nomove-nsa (AAMove ())

  -- if a move action on a synthetic action makes a new form, it's unique
  synthmovedet : {Γ : ·ctx} {e e' e'' : ê} {t' t'' : τ̇} {δ : direction} →
         (Γ ⊢ e => t' ~ move δ ~> e'' => t'') →
         (e + move δ +>e e') →
         e'' == e'
  synthmovedet (SAMove m1) m2 = movedet m1 m2
  -- all these cases lead to absurdities based on movement
  synthmovedet (SAZipAsc1 x) EMAscParent1         = abort (lem-nomove-para x)
  synthmovedet (SAZipAsc1 x) EMAscNextSib         = abort (lem-nomove-nsa x)
  synthmovedet (SAZipAsc2 x _ _ _) EMAscParent2   = abort (lem-nomove-part x)
  synthmovedet (SAZipApArr _ _ _ x _) EMApParent1 = abort (lem-nomove-pars x)
  synthmovedet (SAZipApArr _ _ _ x _) EMApNextSib = abort (lem-nomove-nss x)
  synthmovedet (SAZipApAna _ _ x) EMApParent2     = abort (lem-nomove-para x)
  synthmovedet (SAZipPlus1 x) EMPlusParent1       = abort (lem-nomove-para x)
  synthmovedet (SAZipPlus1 x) EMPlusNextSib       = abort (lem-nomove-nsa x)
  synthmovedet (SAZipPlus2 x) EMPlusParent2       = abort (lem-nomove-para x)
  synthmovedet (SAZipHole _ _ x) EMNEHoleParent   = abort (lem-nomove-pars x)

  anamovedet : {Γ : ·ctx} {e e' e'' : ê} {t : τ̇} {δ : direction} →
         (Γ ⊢ e ~ move δ ~> e'' ⇐ t) →
         (e + move δ +>e e') →
         e'' == e'
  anamovedet (AASubsume x₂ x x₃ x₁) m = synthmovedet x₃ m
  anamovedet (AAMove x) m = movedet x m
  anamovedet (AAZipLam x₁ x₂ d) EMLamParent = abort (lem-nomove-para d)

  mutual
    -- an action on an expression in a synthetic position produces one
    -- resultant expression and type.
    actdet2 : {Γ : ·ctx} {e e' e'' : ê} {e◆ : ė} {t t' t'' : τ̇} {α : action} →
              (E : erase-e e e◆) →
              (Γ ⊢ e◆ => t) →
              (Γ ⊢ e => t ~ α ~> e'  => t') →
              (Γ ⊢ e => t ~ α ~> e'' => t'') →
              (e' == e'' × t' == t'')
    actdet2 EETop (SAsc x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 EETop (SAsc x) SADel SADel = refl , refl
    actdet2 EETop (SAsc x) SAConAsc SAConAsc = refl , refl
    actdet2 EETop (SAsc x) SAConArg SAConArg = refl , refl
    actdet2 EETop (SAsc x) (SAConPlus1 x₁) (SAConPlus1 x₂) = refl , refl
    actdet2 EETop (SAsc x) (SAConPlus1 x₁) (SAConPlus2 x₂) = abort (x₂ x₁)
    actdet2 EETop (SAsc x) (SAConPlus2 x₁) (SAConPlus1 x₂) = abort (x₁ x₂)
    actdet2 EETop (SAsc x) (SAConPlus2 x₁) (SAConPlus2 x₂) = refl , refl
    actdet2 EETop (SAsc x) (SAConApArr x₁) (SAConApArr x₂) with matcharrunicity x₁ x₂
    ... | refl = refl , refl
    actdet2 EETop (SAsc x) (SAConApArr x₁) (SAConApOtw x₂) = abort (x₂ (matchconsist x₁))
    actdet2 EETop (SAsc x) (SAConApOtw x₁) (SAConApArr x₂) = abort (x₁ (matchconsist x₂))
    actdet2 EETop (SAsc x) (SAConApOtw x₁) (SAConApOtw x₂) = refl , refl
    actdet2 EETop (SAsc x) SAConNEHole SAConNEHole = refl , refl

    actdet2 (EEAscL E) (SAsc x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 (EEAscL E) (SAsc x) (SAMove EMAscParent1) (SAZipAsc1 x₂) = abort (lem-nomove-para x₂)
    actdet2 (EEAscL E) (SAsc x) (SAMove EMAscNextSib) (SAZipAsc1 x₂) = abort (lem-nomove-nsa x₂)
    actdet2 (EEAscL E) (SAsc x) (SAZipAsc1 x₁) (SAMove EMAscParent1) = abort (lem-nomove-para x₁)
    actdet2 (EEAscL E) (SAsc x) (SAZipAsc1 x₁) (SAMove EMAscNextSib) = abort (lem-nomove-nsa x₁)
    actdet2 (EEAscL E) (SAsc x) (SAZipAsc1 x₁) (SAZipAsc1 x₂)
     with actdet3 E x x₁ x₂
    ... | refl = refl , refl

    actdet2 (EEAscR x) (SAsc x₁) (SAMove x₂) (SAMove x₃) = movedet x₂ x₃ , refl
    actdet2 (EEAscR x) (SAsc x₁) (SAMove EMAscParent2) (SAZipAsc2 a _ _ _) = abort (lem-nomove-part a)
    actdet2 (EEAscR x) (SAsc x₁) (SAZipAsc2 a _ _ _) (SAMove EMAscParent2) = abort (lem-nomove-part a)
    actdet2 (EEAscR x) (SAsc x₂) (SAZipAsc2 a e1 _ _) (SAZipAsc2 b e2 _ _)
      with actdet1 a b
    ... | refl = refl , eraset-det e1 e2

    actdet2 EETop (SVar x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 EETop (SVar x) SADel SADel = refl , refl
    actdet2 EETop (SVar x) SAConAsc SAConAsc = refl , refl
    actdet2 EETop (SVar x) SAConArg SAConArg = refl , refl
    actdet2 EETop (SVar x) (SAConPlus1 x₁) (SAConPlus1 x₂) = refl , refl
    actdet2 EETop (SVar x) (SAConPlus1 x₁) (SAConPlus2 x₂) = abort (x₂ x₁)
    actdet2 EETop (SVar x) (SAConPlus2 x₁) (SAConPlus1 x₂) = abort (x₁ x₂)
    actdet2 EETop (SVar x) (SAConPlus2 x₁) (SAConPlus2 x₂) = refl , refl
    actdet2 EETop (SVar x) (SAConApArr x₁) (SAConApArr x₂) with matcharrunicity x₁ x₂
    ... | refl = refl , refl
    actdet2 EETop (SVar x) (SAConApArr x₁) (SAConApOtw x₂) = abort (x₂ (matchconsist x₁))
    actdet2 EETop (SVar x) (SAConApOtw x₁) (SAConApArr x₂) = abort (x₁ (matchconsist x₂))
    actdet2 EETop (SVar x) (SAConApOtw x₁) (SAConApOtw x₂) = refl , refl
    actdet2 EETop (SVar x) SAConNEHole SAConNEHole = refl , refl

    actdet2 EETop (SAp m wt x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 EETop (SAp m wt x) SADel SADel = refl , refl
    actdet2 EETop (SAp m wt x) SAConAsc SAConAsc = refl , refl
    actdet2 EETop (SAp m wt x) SAConArg SAConArg = refl , refl
    actdet2 EETop (SAp m wt x) (SAConPlus1 x₁) (SAConPlus1 x₂) = refl , refl
    actdet2 EETop (SAp m wt x) (SAConPlus1 x₁) (SAConPlus2 x₂) = abort (x₂ x₁)
    actdet2 EETop (SAp m wt x) (SAConPlus2 x₁) (SAConPlus1 x₂) = abort (x₁ x₂)
    actdet2 EETop (SAp m wt x) (SAConPlus2 x₁) (SAConPlus2 x₂) = refl , refl
    actdet2 EETop (SAp m wt x) (SAConApArr x₁) (SAConApArr x₂) with matcharrunicity x₁ x₂
    ... | refl = refl , refl
    actdet2 EETop (SAp m wt x) (SAConApArr x₁) (SAConApOtw x₂) = abort (x₂ (matchconsist x₁))
    actdet2 EETop (SAp m wt x) (SAConApOtw x₁) (SAConApArr x₂) = abort (x₁ (matchconsist x₂))
    actdet2 EETop (SAp m wt x) (SAConApOtw x₁) (SAConApOtw x₂) = refl , refl
    actdet2 EETop (SAp m wt x) SAConNEHole SAConNEHole = refl , refl

    actdet2 (EEApL E) (SAp m wt x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 (EEApL E) (SAp m wt x) (SAMove EMApParent1) (SAZipApArr _ x₂ x₃ d2 x₄) = abort (lem-nomove-pars d2)
    actdet2 (EEApL E) (SAp m wt x) (SAMove EMApNextSib) (SAZipApArr _ x₂ x₃ d2 x₄) = abort (lem-nomove-nss d2)
    actdet2 (EEApL E) (SAp m wt x) (SAZipApArr _ x₁ x₂ d1 x₃) (SAMove EMApParent1) = abort (lem-nomove-pars d1)
    actdet2 (EEApL E) (SAp m wt x) (SAZipApArr _ x₁ x₂ d1 x₃) (SAMove EMApNextSib) = abort (lem-nomove-nss d1)
    actdet2 (EEApL E) (SAp m wt x) (SAZipApArr a x₁ x₂ d1 x₃) (SAZipApArr b x₄ x₅ d2 x₆)
      with erasee-det x₁ x₄
    ... | refl with synthunicity x₂ x₅
    ... | refl with erasee-det E x₁
    ... | refl with actdet2 E x₅ d1 d2
    ... | refl , refl with matcharrunicity a b
    ... | refl = refl , refl

    actdet2 (EEApR E) (SAp m wt x) (SAMove x₁) (SAMove x₂) = movedet x₁ x₂ , refl
    actdet2 (EEApR E) (SAp m wt x) (SAMove EMApParent2) (SAZipApAna x₂ x₃ x₄) = abort (lem-nomove-para x₄)
    actdet2 (EEApR E) (SAp m wt x) (SAZipApAna x₁ x₂ x₃) (SAMove EMApParent2) = abort (lem-nomove-para x₃)
    actdet2 (EEApR E) (SAp m wt x) (SAZipApAna x₁ x₂ d1) (SAZipApAna x₄ x₅ d2)
     with synthunicity m x₂
    ... | refl with matcharrunicity x₁ wt
    ... | refl with synthunicity m x₅
    ... | refl with matcharrunicity x₄ wt
    ... | refl with actdet3 E x d1 d2
    ... | refl = refl , refl

    actdet2 EETop SNum (SAMove x) (SAMove x₁) = movedet x x₁ , refl
    actdet2 EETop SNum SADel SADel = refl , refl
    actdet2 EETop SNum SAConAsc SAConAsc = refl , refl
    actdet2 EETop SNum SAConArg SAConArg = refl , refl
    actdet2 EETop SNum (SAConPlus1 x) (SAConPlus1 x₁) = refl , refl
    actdet2 EETop SNum (SAConPlus1 x) (SAConPlus2 x₁) = abort (x₁ x)
    actdet2 EETop SNum (SAConPlus2 x) (SAConPlus1 x₁) = abort (x x₁)
    actdet2 EETop SNum (SAConPlus2 x) (SAConPlus2 x₁) = refl , refl
    actdet2 EETop SNum (SAConApArr x) (SAConApArr x₁) with matcharrunicity x x₁
    ... | refl = refl , refl
    actdet2 EETop SNum (SAConApArr x) (SAConApOtw x₁) = abort (x₁ (matchconsist x))
    actdet2 EETop SNum (SAConApOtw x) (SAConApArr x₁) = abort (x (matchconsist x₁))
    actdet2 EETop SNum (SAConApOtw x) (SAConApOtw x₁) = refl , refl
    actdet2 EETop SNum SAConNEHole SAConNEHole = refl , refl

    actdet2 EETop (SPlus x x₁) (SAMove x₂) (SAMove x₃) = movedet x₂ x₃ , refl
    actdet2 EETop (SPlus x x₁) SADel SADel = refl , refl
    actdet2 EETop (SPlus x x₁) SAConAsc SAConAsc = refl , refl
    actdet2 EETop (SPlus x x₁) SAConArg SAConArg = refl , refl
    actdet2 EETop (SPlus x x₁) (SAConPlus1 x₂) (SAConPlus1 x₃) = refl , refl
    actdet2 EETop (SPlus x x₁) (SAConPlus1 x₂) (SAConPlus2 x₃) = abort (x₃ x₂)
    actdet2 EETop (SPlus x x₁) (SAConPlus2 x₂) (SAConPlus1 x₃) = abort (x₂ x₃)
    actdet2 EETop (SPlus x x₁) (SAConPlus2 x₂) (SAConPlus2 x₃) = refl , refl
    actdet2 EETop (SPlus x x₁) (SAConApArr x₂) (SAConApArr x₃) with matcharrunicity x₂ x₃
    ... | refl = refl , refl
    actdet2 EETop (SPlus x x₁) (SAConApArr x₂) (SAConApOtw x₃) = abort (matchnotnum x₂)
    actdet2 EETop (SPlus x x₁) (SAConApOtw x₂) (SAConApArr x₃) = abort (matchnotnum x₃)
    actdet2 EETop (SPlus x x₁) (SAConApOtw x₂) (SAConApOtw x₃) = refl , refl
    actdet2 EETop (SPlus x x₁) SAConNEHole SAConNEHole = refl , refl

    actdet2 (EEPlusL E) (SPlus x x₁) (SAMove x₂) (SAMove x₃) = movedet x₂ x₃ , refl
    actdet2 (EEPlusL E) (SPlus x x₁) (SAMove EMPlusParent1) (SAZipPlus1 d2) = abort (lem-nomove-para d2)
    actdet2 (EEPlusL E) (SPlus x x₁) (SAMove EMPlusNextSib) (SAZipPlus1 d2) = abort (lem-nomove-nsa d2)
    actdet2 (EEPlusL E) (SPlus x x₁) (SAZipPlus1 x₂) (SAMove EMPlusParent1) = abort (lem-nomove-para x₂)
    actdet2 (EEPlusL E) (SPlus x x₁) (SAZipPlus1 x₂) (SAMove EMPlusNextSib) = abort (lem-nomove-nsa x₂)
    actdet2 (EEPlusL E) (SPlus x x₁) (SAZipPlus1 x₂) (SAZipPlus1 x₃)
      = ap1 (λ x₄ → x₄ ·+₁ _) (actdet3 E x x₂ x₃) , refl

    actdet2 (EEPlusR E) (SPlus x x₁) (SAMove x₂) (SAMove x₃) = movedet x₂ x₃ , refl
    actdet2 (EEPlusR E) (SPlus x x₁) (SAMove EMPlusParent2) (SAZipPlus2 x₃) = abort (lem-nomove-para x₃)
    actdet2 (EEPlusR E) (SPlus x x₁) (SAZipPlus2 x₂) (SAMove EMPlusParent2) = abort (lem-nomove-para x₂)
    actdet2 (EEPlusR E) (SPlus x x₁) (SAZipPlus2 x₂) (SAZipPlus2 x₃)
      = ap1 (_·+₂_ _) (actdet3 E x₁ x₂ x₃) , refl

    actdet2 EETop SEHole (SAMove x) (SAMove x₁) = movedet x x₁ , refl
    actdet2 EETop SEHole SADel SADel = refl , refl
    actdet2 EETop SEHole SAConAsc SAConAsc = refl , refl
    actdet2 EETop SEHole (SAConVar {Γ = G} p) (SAConVar p₁) = refl , (ctxunicity {Γ = G} p p₁)
    actdet2 EETop SEHole (SAConLam x₁) (SAConLam x₂) = refl , refl
    actdet2 EETop SEHole SAConArg SAConArg = refl , refl
    actdet2 EETop SEHole SAConNumlit SAConNumlit = refl , refl
    actdet2 EETop SEHole (SAConPlus1 x) (SAConPlus1 x₁) = refl , refl
    actdet2 EETop SEHole (SAConPlus1 x) (SAConPlus2 x₁) = abort (x₁ x)
    actdet2 EETop SEHole (SAConPlus2 x) (SAConPlus1 x₁) = abort (x x₁)
    actdet2 EETop SEHole (SAConPlus2 x) (SAConPlus2 x₁) = refl , refl
    actdet2 EETop SEHole (SAConApArr x) (SAConApArr x₁) with matcharrunicity x x₁
    ... | refl = refl , refl
    actdet2 EETop SEHole (SAConApArr x) (SAConApOtw x₁) = abort (x₁ TCHole2)
    actdet2 EETop SEHole (SAConApOtw x) (SAConApArr x₁) = abort (x TCHole2)
    actdet2 EETop SEHole (SAConApOtw x) (SAConApOtw x₁) = refl , refl
    actdet2 EETop SEHole SAConNEHole SAConNEHole = refl , refl

    actdet2 EETop (SNEHole wt) (SAMove x) (SAMove x₁) = movedet x x₁ , refl
    actdet2 EETop (SNEHole wt) SADel SADel = refl , refl
    actdet2 EETop (SNEHole wt) SAConAsc SAConAsc = refl , refl
    actdet2 EETop (SNEHole wt) SAConArg SAConArg = refl , refl
    actdet2 EETop (SNEHole wt) (SAConPlus1 x) (SAConPlus1 x₁) = refl , refl
    actdet2 EETop (SNEHole wt) (SAConPlus1 x) (SAConPlus2 x₁) = abort (x₁ x)
    actdet2 EETop (SNEHole wt) (SAConPlus2 x) (SAConPlus1 x₁) = abort (x x₁)
    actdet2 EETop (SNEHole wt) (SAConPlus2 x) (SAConPlus2 x₁) = refl , refl
    actdet2 EETop (SNEHole wt) (SAFinish x) (SAFinish x₁) = refl , synthunicity x x₁
    actdet2 EETop (SNEHole wt) (SAConApArr x) (SAConApArr x₁) with matcharrunicity x x₁
    ... | refl = refl , refl
    actdet2 EETop (SNEHole wt) (SAConApArr x) (SAConApOtw x₁) = abort (x₁ TCHole2)
    actdet2 EETop (SNEHole wt) (SAConApOtw x) (SAConApArr x₁) = abort (x TCHole2)
    actdet2 EETop (SNEHole wt) (SAConApOtw x) (SAConApOtw x₁) = refl , refl
    actdet2 EETop (SNEHole wt) SAConNEHole SAConNEHole = refl , refl

    actdet2 (EENEHole E) (SNEHole wt) (SAMove x) (SAMove x₁) = movedet x x₁ , refl
    actdet2 (EENEHole E) (SNEHole wt) (SAMove EMNEHoleParent) (SAZipHole _ x₁ d2) = abort (lem-nomove-pars d2)
    actdet2 (EENEHole E) (SNEHole wt) (SAZipHole _ x d1) (SAMove EMNEHoleParent) = abort (lem-nomove-pars d1)
    actdet2 (EENEHole E) (SNEHole wt) (SAZipHole a x d1) (SAZipHole b x₁ d2)
      with erasee-det a b
    ... | refl with synthunicity x x₁
    ... | refl with actdet2 a x d1 d2
    ... | refl , refl = refl , refl


    -- an action on an expression in an analytic position produces one
    -- resultant expression and type.
    actdet3 : {Γ : ·ctx} {e e' e'' : ê} {e◆ : ė} {t : τ̇} {α : action} →
              (erase-e e e◆) →
              (Γ ⊢ e◆ <= t) →
              (Γ ⊢ e ~ α ~> e' ⇐ t) →
              (Γ ⊢ e ~ α ~> e'' ⇐ t) →
              (e' == e'')
    ---- lambda cases first
    -- an erased lambda can't be typechecked with subsume
    actdet3 (EELam _) (ASubsume () _) _ _

    -- for things paired with movements, punt to the move determinism case
    actdet3 _ _ D (AAMove y) = anamovedet D y
    actdet3 _ _ (AAMove y) D =  ! (anamovedet D y)

    -- lambdas never match with subsumption actions, because it won't be well typed.
    actdet3 EETop      (ALam x₁ x₂ wt) (AASubsume EETop () x₅ x₆) _
    actdet3 (EELam _) (ALam x₁ x₂ wt) (AASubsume (EELam x₃) () x₅ x₆) _
    actdet3 EETop      (ALam x₁ x₂ wt) _ (AASubsume EETop () x₅ x₆)
    actdet3 (EELam _) (ALam x₁ x₂ wt) _ (AASubsume (EELam x₃) () x₅ x₆)

    -- with the cursor at the top, there are only two possible actions
    actdet3 EETop (ALam x₁ x₂ wt) AADel AADel = refl
    actdet3 EETop (ALam x₁ x₂ wt) AAConAsc AAConAsc = refl

    -- and for the remaining case, recurr on the smaller derivations
    actdet3 (EELam er) (ALam x₁ x₂ wt) (AAZipLam x₃ x₄ d1) (AAZipLam x₅ x₆ d2)
       with matcharrunicity x₄ x₆
    ... | refl with matcharrunicity x₄ x₂
    ... | refl with actdet3 er wt d1 d2
    ... | refl = refl

    ---- now the subsumption cases
      -- subsume / subsume, so pin things down then recurr
    actdet3 er (ASubsume a b) (AASubsume x x₁ x₂ x₃) (AASubsume x₄ x₅ x₆ x₇)
      with erasee-det x₄ x
    ... | refl with erasee-det er x₄
    ... | refl with synthunicity x₅ x₁
    ... | refl = π1 (actdet2 x x₅ x₂ x₆)

    -- (these are all repeated below, irritatingly.)
    actdet3 EETop (ASubsume a b) (AASubsume EETop x SADel x₁) AADel = refl
    actdet3 EETop (ASubsume a b) (AASubsume EETop x SAConAsc x₁) AAConAsc
      with synthunicity a x
    ... | refl = {!!} -- unprovable
    actdet3 EETop (ASubsume SEHole b) (AASubsume EETop SEHole (SAConVar {Γ = Γ} p) x₂) (AAConVar x₅ p₁)
      with ctxunicity {Γ = Γ} p p₁
    ... | refl = abort (x₅ x₂)
    actdet3 EETop (ASubsume SEHole b) (AASubsume EETop SEHole (SAConLam x₄) x₂) (AAConLam1 x₅ m) = {!!} -- unprovable
    actdet3 EETop (ASubsume a b) (AASubsume EETop x₁ (SAConLam x₃) x₂) (AAConLam2 x₅ x₆) = abort (x₆ x₂)
    actdet3 EETop (ASubsume a b) (AASubsume EETop x₁ SAConNumlit x₂) (AAConNumlit x₄) = abort (x₄ x₂)
    actdet3 EETop (ASubsume a b) (AASubsume EETop x (SAFinish x₂) x₁) (AAFinish x₄) = refl

      -- subsume / del
    actdet3 er (ASubsume a b) AADel (AASubsume x x₁ SADel x₃) = refl
    actdet3 er (ASubsume a b) AADel AADel = refl

      -- subsume / conasc
    actdet3 EETop (ASubsume a b) AAConAsc (AASubsume EETop x₁ SAConAsc x₃)
      with synthunicity a x₁
    ... | refl = {!!} -- unprovable
    actdet3 er (ASubsume a b) AAConAsc AAConAsc = refl

      -- subsume / convar
    actdet3 EETop (ASubsume SEHole b) (AAConVar x₁ p) (AASubsume EETop SEHole (SAConVar {Γ = Γ} p₁) x₅)
      with ctxunicity {Γ = Γ} p p₁
    ... | refl = abort (x₁ x₅)
    actdet3 er (ASubsume a b) (AAConVar x₁ p) (AAConVar x₂ p₁) = refl

      -- subsume / conlam1
    actdet3 EETop (ASubsume SEHole b) (AAConLam1 x₁ x₂) (AASubsume EETop SEHole (SAConLam x₃) x₆) = {!!} -- unprovable
    actdet3 er (ASubsume a b) (AAConLam1 x₁ MAHole) (AAConLam2 x₃ x₄) = abort (x₄ TCHole2)
    actdet3 er (ASubsume a b) (AAConLam1 x₁ MAArr) (AAConLam2 x₃ x₄) = abort (x₄ (TCArr TCHole1 TCHole1))
    actdet3 er (ASubsume a b) (AAConLam1 x₁ x₂) (AAConLam1 x₃ x₄) = refl

      -- subsume / conlam2
    actdet3 EETop (ASubsume SEHole TCRefl) (AAConLam2 x₁ x₂) (AASubsume EETop SEHole x₅ x₆) = abort (x₂ TCHole2)
    actdet3 EETop (ASubsume SEHole TCHole1) (AAConLam2 x₁ x₂) (AASubsume EETop SEHole (SAConLam x₃) x₆) = abort (x₂ x₆)
    actdet3 EETop (ASubsume SEHole TCHole2) (AAConLam2 x₁ x₂) (AASubsume EETop SEHole x₅ x₆) = abort (x₂ TCHole2)
    actdet3 EETop (ASubsume a b) (AAConLam2 x₂ x₁) (AAConLam1 x₃ MAHole) = abort (x₁ TCHole2)
    actdet3 EETop (ASubsume a b) (AAConLam2 x₂ x₁) (AAConLam1 x₃ MAArr) = abort (x₁ (TCArr TCHole1 TCHole1))
    actdet3 er (ASubsume a b) (AAConLam2 x₂ x) (AAConLam2 x₃ x₄) = refl

      -- subsume / numlit
    actdet3 er (ASubsume a b) (AAConNumlit x) (AASubsume x₁ x₂ SAConNumlit x₄) = abort (x x₄)
    actdet3 er (ASubsume a b) (AAConNumlit x) (AAConNumlit x₁) = refl

      -- subsume / finish
    actdet3 er (ASubsume a b) (AAFinish x) (AASubsume x₁ x₂ (SAFinish x₃) x₄) = refl
    actdet3 er (ASubsume a b) (AAFinish x) (AAFinish x₁) = refl
