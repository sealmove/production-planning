include "globals.mzn";

int: nbTypes;
int: nbTimeslots;
int: nbItems;
int: storageCost;

set of int: Types = 1..nbTypes;
set of int: Timeslots = 1..nbTimeslots;
set of int: Items = 1..nbItems;
int: scMax = storageCost * sum([dueTimeslots[i] | i in Items]);
var int: obj = storageCostF + changeCostF;

array[Types, Types] of int: changeCost;
array[Items] of Types:  types;
array[Items] of Timeslots: dueTimeslots;

array[Timeslots] of var Types: config;
array[Timeslots] of var bool: idle;

array[Timeslots] of var 0..nbItems: solution;
array[Timeslots] of var -1..nbItems-1: out;

var 0..scMax: storageCostF =
  storageCost * sum (t in Timeslots where not idle[t]) (
    (dueTimeslots[solution[t]] - t));

var 0..(nbItems-1)*max(changeCost): changeCostF =
  sum (t in Timeslots where t > 1) (changeCost[config[t-1], config[t]]);

constraint changeCostF >= nbTypes * min(changeCost);

% There are exactly (nbTimeslots - nbItems) idle timeslots
constraint count(idle, true, nbTimeslots - nbItems);
constraint count(solution, 0, nbTimeslots - nbItems); % Channeling

% Idle timeslots
constraint forall (t in Timeslots where idle[t]) (solution[t] = 0);
constraint forall (t in Timeslots) (idle[t] = (solution[t] = 0)); % Channeling

% In order to produce an item, the correct configuration must be in place
constraint forall (t in Timeslots where not idle[t]) (
  config[t] = types[solution[t]]);

% All the items must be produced exactly once
constraint alldifferent_except_0(solution);

% Every item has to be produced before its deadline
constraint forall (t in Timeslots where not idle[t]) (
  t <= dueTimeslots[solution[t]]);

% Each configuration appears at least once
constraint nvalue(config) = nbTypes;

solve minimize obj;
