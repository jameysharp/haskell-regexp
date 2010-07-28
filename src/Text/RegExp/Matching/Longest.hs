{-# LANGUAGE MultiParamTypeClasses, FlexibleContexts, FlexibleInstances #-}

-- |
-- Module      : Text.RegExp.Matching.Longest
-- Copyright   : Thomas Wilke, Frank Huch, and Sebastian Fischer
-- License     : BSD3
-- Maintainer  : Sebastian Fischer <mailto:sebf@informatik.uni-kiel.de>
-- Stability   : experimental
-- 
-- This module implements longest matching based on weighted regular
-- expressions. It should be imported qualified as the interface
-- resembles that provided by other matching modules.
-- 
module Text.RegExp.Matching.Longest (

  Longest(..), Matching(..),

  matching, getLongest

  ) where

import Text.RegExp

-- |
-- A 'Matching' records the leftmost start index of a matching subword.
-- 
data Matching = Matching {
 
  -- | Length of the matching subword in the queried word.
  matchingLength :: !Int
 
  }
 deriving Eq

instance Show Matching
 where
  showsPrec _ m = showString "<length:" . shows (matchingLength m)
                . showString ">"

-- |
-- Returns the longest of all matchings for a regular expression in a
-- given word.
-- 
matching :: RegExp c -> [c] -> Maybe Matching
matching r = getLongest . partialMatch r

-- | Semiring used for longest matching.
-- 
data Longest = Zero | One | Longest !Int
 deriving (Eq,Show)

getLongest :: Longest -> Maybe Matching
getLongest Zero         =  Nothing
getLongest One          =  Just $ Matching 0 
getLongest (Longest x)  =  Just $ Matching x

instance Semiring Longest where
  zero = Zero; one = One

  Zero       .+.  y          =  y
  x          .+.  Zero       =  x
  One        .+.  y          =  y
  x          .+.  One        =  x
  Longest a  .+.  Longest b  =  Longest (max a b)

  Zero       .*.  _          =  Zero
  _          .*.  Zero       =  Zero
  One        .*.  y          =  y
  x          .*.  One        =  x
  Longest a  .*.  Longest b  =  Longest (a+b)

instance Weight c c Longest where
  symWeight p c = p c .*. Longest 1