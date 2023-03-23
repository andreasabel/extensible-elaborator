{-# LANGUAGE TypeApplications #-}
module TypeCheck.Solver.Identity (identityPlugin) where

import qualified Unbound.Generics.LocallyNameless as Unbound (aeq)

import           Syntax.Internal (CheckForMetas(hasMetas))
import           TypeCheck.Constraints ( (:<:)
                                       , EqualityConstraint(..)
                                       , match
                                       )

import TypeCheck.Solver.Base

identityEqualityHandler :: HandlerType EqualityConstraint cs
identityEqualityHandler constr = do
  let eqcm = match @EqualityConstraint constr
  case eqcm of
    Just (EqualityConstraint t1 t2 ty src) -> return $
      if hasMetas t1 && hasMetas t2
      then False
      else Unbound.aeq t1 t2
    Nothing -> return False

identityEqualitySolver :: SolverType EqualityConstraint cs
identityEqualitySolver constr = return True

identityPlugin :: forall cs. (EqualityConstraint :<: cs) =>
                  Plugin EqualityConstraint cs
identityPlugin = Plugin {
  solver = identityEqualitySolver,
  handler = identityEqualityHandler,
  symbol = "identity equality solver",
  pre = [],
  suc = []
  }
