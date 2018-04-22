#!/usr/bin/env stack
{- stack
    --install-ghc
    runghc
    --package zifter
    --package zifter-git
    --package zifter-hindent
    --package zifter-hlint
    --package zifter-stack
-}
import Zifter
import Zifter.Git
import Zifter.Hindent
import Zifter.Hlint
import Zifter.Stack

main :: IO ()
main =
    ziftWith $ do
        recursiveZift
        preprocessor $
            hindentZiftExcept
                [ "genvalidity-hspec/src/Test/Validity/Utils.hs"
                , "genvalidity/src/Data/GenRelativeValidity.hs"
                , "genvalidity/src/Data/GenValidity.hs"
                , "validity-path/src/Data/Validity/Path.hs"
                , "validity/src/Data/RelativeValidity.hs"
                , "validity/src/Data/Validity.hs"
                ]
        prechecker gitAddAllZift
        checker $ do
            hlintZift
            stackBuildZift
