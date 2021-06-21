include "production-planning-model.mzn";

% Symmetry breaking: failed to apply this to the big instance
constraint forall (t in Types) (
  increasing (i in Items where types[i] = t) (solution[i]));

constraint forall (t in Timeslots where idle[t]) (out[t] = -1);
constraint forall (t in Timeslots where not idle[t]) (
  out[t] = types[solution[t]] - 1);
output ["solution = " ++ show(out) ++ ";\nobj = " ++ show(obj) ++ ";"];
