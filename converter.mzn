int: nbTypes;
int: nbTimeslots;
int: nbItems;
int: storageCost;
int: obj;

set of int: Types = 1..nbTypes;
set of int: Timeslots = 1..nbTimeslots;
set of int: Items = 1..nbItems;

array[Types, Types] of int: changeCost;
array[Items] of Types:  types;
array[Items] of Timeslots: dueTimeslots;

array[Timeslots] of var -2..nbItems-1: solution;
array[Timeslots] of var -1..nbTypes: out;

constraint forall (t in Timeslots where solution[t] != -1) (
  out[t] = types[solution[t] + 1] - 1);

output ["solution = " ++ show(out) ++ ";\nobj = " ++ show(obj) ++ ";"];
