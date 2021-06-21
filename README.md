# Production Planning
Production planning problem used in the ACAI'14 programming competition.

Created by: Alessio Bonfietti, Michele Lombardi, Pierre Schaus 

## Problem Details

In case handout was not informative enough: our task is to schedule production on the single assembly line. Every item has a specified type and deadline. Before producing an item, assembly line has to be configured specifically to the item's type. Also, every item has to be produced before its deadline.

We minimize two costs: 

- storage cost - we pay for every day the complete item is kept at the factory - so we want to produce items as late as possible.
- change cost - reconfiguring the assembly line is expensive and every configuration change costs value specified in a matrix (i.e. change from producing type 1 to type 2 costs such and such amount of money)

``data`` folder contains data files - there are two instances: 
- ``small`` just to check the model,
- ``big`` for the competition.

## Output

Below is an example output for the small instance, where ``-1`` means that the assembly line was idle at the time. ``0`` is item of type ``0``, etc. Notice that in the data file types start from ``1``, so you have to adjust them to the output requirements.

```
solution = [1, -1, -1, 9, 0, 6, 5, 7, 4, 10, 3, 11, 2, -1, 8]; 
obj = 1294;
```
