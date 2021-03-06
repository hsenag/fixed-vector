{-# LANGUAGE FlexibleContexts      #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE UndecidableInstances  #-}
-- |
-- Wrapper function for working with monomorphic vectors. Standard API
-- require vector to be parametric in their element type making it
-- impossible to work with vectors like
--
-- > data Vec3 = Vec3 Double Double Double
--
-- This module provides newtype wrapper which allows use of functions
-- from "Data.Vector.Fixed" with such data types and function which
-- works with such vectors.
--
-- Functions have same meaning as ones from "Data.Vector.Fixed" and
-- documented there.
module Data.Vector.Fixed.Monomorphic (
    -- * Vector type class
    -- ** Vector size
    DimMono
  , Z
  , S
    -- ** Synonyms for small numerals
  , F.N1
  , F.N2
  , F.N3
  , F.N4
  , F.N5
  , F.N6
    -- ** Type class
  , VectorMono(..)
  , Arity
  , Fun(..)
  , length
    -- * Constructors
    -- $construction
    -- ** Small dimensions
    -- $smallDim
  , mk1
  , mk2
  , mk3
  , mk4
  , mk5
    -- ** Functions
  , replicate
  , replicateM
  , generate
  , generateM
  , unfoldr
  , basis
    -- * Modifying vectors
    -- ** Transformations
  , head
  , tail
  , reverse
  , (!)
    -- ** Comparison
  , eq
    -- ** Maps
  , map
  , mapM
  , mapM_
  , imap
  , imapM
  , imapM_
    -- * Folding
  , foldl
  , foldr
  , foldl1
  , ifoldl
  , ifoldr
  , fold
  , foldMap
  , foldM
  , ifoldM
    -- ** Special folds
  , sum
  , maximum
  , minimum
  , and
  , or
  , all
  , any
  , find
    -- * Zips
  , zipWith
  , zipWithM
  , izipWith
  , izipWithM
    -- * Conversion
  , convert
  , toList
  , fromList
  ) where

import Control.Monad (liftM)
import Data.Monoid   (Monoid)
import qualified Data.Vector.Fixed as F
import Data.Vector.Fixed.Cont (S,Z,Arity,Fun(..))
import Prelude (Num,Eq,Ord,Functor(..),Monad(..),Int,Bool,(.),($),Maybe)



----------------------------------------------------------------
-- Wrappers for monomorphic vectors
----------------------------------------------------------------

-- | Wrapper for monomorphic vectors it provides 'Vector' instance for
--   monomorphic vectors. Trick is to restrict type parameter @a@ to
--   single possible value.
newtype Mono v a = Mono { getMono :: v }

type instance F.Dim (Mono v) = DimMono v

instance (VectorMono v, a ~ VectorElm v, Arity (DimMono v)) => F.Vector (Mono v) a where
  construct  = fmap Mono construct
  inspect    = inspect . getMono
  basicIndex = basicIndex . getMono
  {-# INLINE construct  #-}
  {-# INLINE inspect    #-}
  {-# INLINE basicIndex #-}


-- | Dimensions of monomorphic vector.
type family DimMono v :: *

-- | Counterpart of 'Vector' type class for monomorphic vectors.
class Arity (DimMono v) => VectorMono v where
  -- | Type of vector elements.
  type VectorElm v :: *
  -- | Construct vector
  construct :: Fun (DimMono v) (VectorElm v) v
  -- | Inspect vector
  inspect   :: v -> Fun (DimMono v) (VectorElm v) r -> r
  -- | Optional more efficient implementation of indexing
  basicIndex :: v -> Int -> VectorElm v
  basicIndex v i = Mono v F.! i
  {-# INLINE basicIndex #-}

-- | Length of vector
length :: Arity (DimMono v) => v -> Int
length = F.length . Mono
{-# INLINE length #-}


----------------------------------------------------------------
--
----------------------------------------------------------------

mk1 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ F.N1)
    => a -> v
mk1 a1 = getMono $ F.mk1 a1
{-# INLINE mk1 #-}

mk2 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ F.N2)
    => a -> a-> v
mk2 a1 a2 = getMono $ F.mk2 a1 a2
{-# INLINE mk2 #-}

mk3 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ F.N3)
    => a -> a-> a -> v
mk3 a1 a2 a3 = getMono $ F.mk3 a1 a2 a3
{-# INLINE mk3 #-}

mk4 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ F.N4)
    => a -> a-> a -> a -> v
mk4 a1 a2 a3 a4 = getMono $ F.mk4 a1 a2 a3 a4
{-# INLINE mk4 #-}

mk5 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ F.N5)
    => a -> a-> a -> a -> a -> v
mk5 a1 a2 a3 a4 a5 = getMono $ F.mk5 a1 a2 a3 a4 a5
{-# INLINE mk5 #-}

replicate :: (VectorMono v, VectorElm v ~ a) => a -> v
{-# INLINE replicate #-}
replicate = getMono . F.replicate

replicateM :: (VectorMono v, VectorElm v ~ a, Monad m) => m a -> m v
{-# INLINE replicateM #-}
replicateM a = getMono `liftM` F.replicateM a

basis :: (VectorMono v, VectorElm v ~ a, Num a) => Int -> v
{-# INLINE basis #-}
basis = getMono . F.basis

unfoldr :: (VectorMono v, VectorElm v ~ a) => (b -> (a,b)) -> b -> v
{-# INLINE unfoldr #-}
unfoldr f = getMono . F.unfoldr f

generate :: (VectorMono v, VectorElm v ~ a) => (Int -> a) -> v
{-# INLINE generate #-}
generate = getMono . F.generate

generateM :: (Monad m, VectorMono v, VectorElm v ~ a) => (Int -> m a) -> m v
{-# INLINE generateM #-}
generateM f = getMono `liftM` F.generateM f



----------------------------------------------------------------

head :: (VectorMono v, VectorElm v ~ a, DimMono v ~ S n) => v -> a
{-# INLINE head #-}
head = F.head . Mono

tail :: ( VectorMono v, VectorElm v ~ a
        , VectorMono w, VectorElm w ~ a
        , DimMono v ~ S (DimMono w))
     => v -> w
{-# INLINE tail #-}
tail v = getMono $ F.tail $ Mono v

reverse :: (VectorMono v) => v -> v
reverse = getMono . F.reverse . Mono
{-# INLINE reverse #-}

(!) :: (VectorMono v, VectorElm v ~ a) => v -> Int -> a
{-# INLINE (!) #-}
v ! n = Mono v F.! n

foldl :: (VectorMono v, VectorElm v ~ a)
      => (b -> a -> b) -> b -> v -> b
{-# INLINE foldl #-}
foldl f x = F.foldl f x . Mono

foldr :: (VectorMono v, VectorElm v ~ a)
      => (a -> b -> b) -> b -> v -> b
{-# INLINE foldr #-}
foldr f x = F.foldr f x . Mono


foldl1 :: (VectorMono v, VectorElm v ~ a, DimMono v ~ S n)
       => (a -> a -> a) -> v -> a
{-# INLINE foldl1 #-}
foldl1 f = F.foldl1 f . Mono

ifoldr :: (VectorMono v, VectorElm v ~ a)
       => (Int -> a -> b -> b) -> b -> v -> b
{-# INLINE ifoldr #-}
ifoldr f x = F.ifoldr f x . Mono

ifoldl :: (VectorMono v, VectorElm v ~ a)
       => (b -> Int -> a -> b) -> b -> v -> b
{-# INLINE ifoldl #-}
ifoldl f z = F.ifoldl f z . Mono

fold :: (VectorMono v, Monoid (VectorElm v)) => v -> VectorElm v
fold = F.fold . Mono
{-# INLINE fold #-}

foldMap :: (VectorMono v, Monoid m) => (VectorElm v -> m) -> v -> m
foldMap f = F.foldMap f . Mono
{-# INLINE foldMap #-}

foldM :: (VectorMono v, VectorElm v ~ a, Monad m)
      => (b -> a -> m b) -> b -> v -> m b
{-# INLINE foldM #-}
foldM f x = F.foldM f x . Mono

ifoldM :: (VectorMono v, VectorElm v ~ a, Monad m) => (b -> Int -> a -> m b) -> b -> v -> m b
{-# INLINE ifoldM #-}
ifoldM f x = F.ifoldM f x . Mono



----------------------------------------------------------------

sum :: (VectorMono v, VectorElm v ~ a, Num a) => v -> a
sum = F.sum . Mono
{-# INLINE sum #-}

maximum :: (VectorMono v, VectorElm v ~ a, DimMono v ~ S n, Ord a) => v -> a
maximum = F.maximum . Mono
{-# INLINE maximum #-}

minimum :: (VectorMono v, VectorElm v ~ a, DimMono v ~ S n, Ord a) => v -> a
minimum = F.minimum . Mono
{-# INLINE minimum #-}

and :: (VectorMono v, VectorElm v ~ Bool) => v -> Bool
and = F.and . Mono
{-# INLINE and #-}

or :: (VectorMono v, VectorElm v ~ Bool) => v -> Bool
or = F.or . Mono
{-# INLINE or #-}

all :: (VectorMono v, VectorElm v ~ a) => (a -> Bool) -> v -> Bool
all f = F.all f . Mono
{-# INLINE all #-}

any :: (VectorMono v, VectorElm v ~ a) => (a -> Bool) -> v -> Bool
any f = F.any f . Mono
{-# INLINE any #-}

find :: (VectorMono v, VectorElm v ~ a) => (a -> Bool) -> v -> Maybe a
find f = F.find f . Mono
{-# INLINE find #-}

----------------------------------------------------------------

eq :: (VectorMono v, VectorElm v ~ a, Eq a) => v -> v -> Bool
{-# INLINE eq #-}
eq v w = F.eq (Mono v) (Mono w)


----------------------------------------------------------------

map :: (VectorMono v, VectorElm v ~ a) => (a -> a) -> v -> v
{-# INLINE map #-}
map f = getMono . F.map f . Mono

mapM :: (VectorMono v, VectorElm v ~ a, Monad m)
     => (a -> m a) -> v -> m v
{-# INLINE mapM #-}
mapM f v = getMono `liftM` F.mapM f (Mono v)

mapM_ :: (VectorMono v, VectorElm v ~ a, Monad m) => (a -> m b) -> v -> m ()
{-# INLINE mapM_ #-}
mapM_ f = F.mapM_ f . Mono


imap :: (VectorMono v, VectorElm v ~ a) =>
    (Int -> a -> a) -> v -> v
{-# INLINE imap #-}
imap f = getMono . F.imap f . Mono

imapM :: (VectorMono v, VectorElm v ~ a, Monad m)
      => (Int -> a -> m a) -> v -> m v
{-# INLINE imapM #-}
imapM f v = getMono `liftM` F.imapM f (Mono v)

imapM_ :: (VectorMono v, VectorElm v ~ a, Monad m) => (Int -> a -> m b) -> v -> m ()
{-# INLINE imapM_ #-}
imapM_ f = F.imapM_ f . Mono


----------------------------------------------------------------

zipWith :: (VectorMono v, VectorElm v ~ a)
        => (a -> a -> a) -> v -> v -> v
{-# INLINE zipWith #-}
zipWith f v u = getMono $ F.zipWith f (Mono v) (Mono u)


zipWithM :: (VectorMono v, VectorElm v ~ a, Monad m)
         => (a -> a -> m a) -> v -> v -> m v
{-# INLINE zipWithM #-}
zipWithM f v u = getMono `liftM` F.zipWithM f (Mono v) (Mono u)

izipWith :: (VectorMono v, VectorElm v ~ a)
         => (Int -> a -> a -> a) -> v -> v -> v
{-# INLINE izipWith #-}
izipWith f v u = getMono $ F.izipWith f (Mono v) (Mono u)

izipWithM :: (VectorMono v, VectorElm v ~ a, Monad m)
          => (Int -> a -> a -> m a) -> v -> v -> m v
{-# INLINE izipWithM #-}
izipWithM f v u = getMono `liftM` F.izipWithM f (Mono v) (Mono u)



----------------------------------------------------------------

convert :: (VectorMono v, VectorMono w, VectorElm v ~ VectorElm w, DimMono v ~ DimMono w)
        => v -> w
{-# INLINE convert #-}
convert = getMono . F.convert . Mono

toList :: (VectorMono v, VectorElm v ~ a) => v -> [a]
toList = foldr (:) []

fromList :: (VectorMono v, VectorElm v ~ a) => [a] -> v
{-# INLINE fromList #-}
fromList = getMono . F.fromList

