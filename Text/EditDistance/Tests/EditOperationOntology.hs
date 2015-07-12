{-# LANGUAGE PatternGuards #-}
module Text.EditDistance.Tests.EditOperationOntology where

import Text.EditDistance.EditCosts

import Test.QuickCheck
import Control.Monad

class Arbitrary ops => EditOperation ops where
    edit :: String -> ops -> Gen (String, EditCosts -> Int)
    containsTransposition :: ops -> Bool

instance EditOperation op => EditOperation [op] where
   edit ys ops = foldM (\(xs, c) op -> fmap (\(xs', cost') -> (xs', \ecs -> c ecs + cost' ecs)) $ edit xs op) (ys, const 0) ops
   containsTransposition = any containsTransposition


data EditedString ops = MkEditedString {
    oldString :: String,
    newString :: String,
    operations :: ops,
    esCost :: EditCosts -> Int
}

instance Show ops => Show (EditedString ops) where
    show (MkEditedString old_string new_string ops _cost) = show old_string ++ " ==> " ++ show new_string ++ " (by " ++ show ops ++ ")"

instance EditOperation ops => Arbitrary (EditedString ops) where
    arbitrary = do
        old_string <- arbitrary
        edit_operations <- arbitrary
        (new_string, cost) <- edit old_string edit_operations
        return $ MkEditedString {
            oldString = old_string,
            newString = new_string,
            operations = edit_operations,
            esCost = cost
        }


data ExtendedEditOperation = Deletion
                           | Insertion Char
                           | Substitution Char
                           | Transposition
                           deriving (Show)

instance Arbitrary ExtendedEditOperation where
    arbitrary = oneof [return Deletion, fmap Insertion arbitrary, fmap Substitution arbitrary, return Transposition]

instance EditOperation ExtendedEditOperation where
    edit str op = do
        let max_split_ix | Transposition <- op = length str - 1
                         | otherwise           = length str
        split_ix <- choose (1, max_split_ix)
        let (str_l, str_r) = splitAt split_ix str
            non_null = not $ null str
            transposable = length str > 1
        case op of
            Deletion | non_null -> do
                let old_ch = last str_l
                return (init str_l ++ str_r, \ec -> deletionCost ec old_ch)
            Insertion new_ch | non_null -> do
                return (str_l ++ new_ch : str_r, \ec -> insertionCost ec new_ch)
            Insertion new_ch | otherwise -> return ([new_ch], \ec -> insertionCost ec new_ch)   -- Need special case because randomR (1, 0) is undefined
            Substitution new_ch | non_null -> do
                let old_ch = last str_l
                return (init str_l ++ new_ch : str_r, \ec -> substitutionCost ec old_ch new_ch)
            Transposition | transposable -> do                  -- Need transposable rather than non_null because randomR (1, 0) is undefined
                let backwards_ch = head str_r
                    forwards_ch = last str_l
                return (init str_l ++ backwards_ch : forwards_ch : tail str_r, \ec -> transpositionCost ec backwards_ch forwards_ch)
            _ -> return (str, const 0)

    containsTransposition Transposition = True
    containsTransposition _             = False


-- This all really sucks but I can't think of something better right now
newtype BasicEditOperation = MkBasic ExtendedEditOperation

instance Show BasicEditOperation where
    show (MkBasic x) = show x

instance Arbitrary BasicEditOperation where
    arbitrary = fmap MkBasic $ oneof [return Deletion, fmap Insertion arbitrary, fmap Substitution arbitrary]

instance EditOperation BasicEditOperation where
    edit str (MkBasic op) = edit str op
    containsTransposition _ = False
