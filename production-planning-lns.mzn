include "globals.mzn";
include "production-planning-model.mzn";

array[Timeslots] of var -2..nbItems-1: solutionI; % input (intermediate) solution
int: objI; % input (intermediate) objective

% Fix solution numbers according to intermediate solution
constraint forall (t in Timeslots where solutionI[t] != -2) (
  solution[t] = solutionI[t] + 1);

% Output objective should not be worse than intermediate objective
constraint obj <= objI;

constraint forall (t in Timeslots) (out[t] = solution[t] - 1);
output ["solution = " ++ show(out) ++ ";\nobj = " ++ show(obj) ++ ";"];
