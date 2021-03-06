{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE CPP #-}

module Data.ValiditySpec
    ( spec
    ) where

import GHC.Generics (Generic)
#if !MIN_VERSION_base(4,11,0)
import Data.Monoid
#endif
import Data.Validity

import Test.Hspec

data Wrong
    = Wrong
    | Fine
    deriving (Show, Eq)

instance Validity Wrong where
    validate w =
        case w of
            Wrong -> invalid "Wrong"
            Fine -> valid

data GeneratedValidity =
    G Double
      Double
    deriving (Show, Eq, Generic)

instance Validity GeneratedValidity

-- To make sure that the <?!> operator have the right fixity
data ManuallyInstantiated =
    M Double
      Double
    deriving (Show, Eq)

instance Validity ManuallyInstantiated where
    validate (M m1 m2) = annotate m1 "m1" <> annotate m2 "m2"

-- To make sure that the <?@> operator have the right fixity
data TwoEvens =
    E Int
      Int
    deriving (Show, Eq)

instance Validity TwoEvens where
    validate (E e1 e2) =
        declare "e1 is even" (even e1) <> declare "e2 is even" (even e2)

spec :: Spec
spec = do
    describe "Wrong" $ do
        it "says Wrong is invalid" $ Wrong `shouldSatisfy` (not . isValid)
        it "says Fine is valid" $ Fine `shouldSatisfy` isValid
    describe "GeneratedValidity" $ do
        let nan = read "NaN"
        it "says G nan 0 is not valid" $ G nan 0 `shouldSatisfy` (not . isValid)
        it "says G 0 nan is not valid" $ G 0 nan `shouldSatisfy` (not . isValid)
        it "says G 0 0 is valid" $ G 0 0 `shouldSatisfy` isValid
