#!/usr/bin/env -S nim --hints:off
# Pass an intermediate solution that uses indices to stdin
import strutils, strformat, strscans, random, math

const
  nbTimeslots = 150
  solver = "'org.ortools.ortools'"
  data = "data/big.dzn"
  # Starting Percentage of numbers to search for
  startingPercentage = 0.10
  # Increases after `loops` loops
  loops = 50
  # By `increment`
  increment = 0.01

let
  input = slurp(data).splitLines[23]
  start = find(input, '[')
  finish = find(input, ']')
  typesTxt = input[start + 1 .. finish - 1].split(", ")
var types = newSeq[int]()
for n in typesTxt:
  types.add(parseInt(n))

proc parse(s: string): tuple[s: seq[int], o: int] =
  let
    lines = s.splitLines
    solution = lines[0]
    start = find(solution, '[')
    finish = find(solution, ']')
    numbers = solution[start + 1 .. finish - 1].split(", ")
  var obj: int
  discard scanf(lines[1], "obj = $i", result.o)
  for n in numbers:
    result.s.add(parseInt(n))

proc compose(s: seq[int], o: int): string =
  result = &"solutionI = [{s.join(\", \")}];\nobjI = {o};"

var
  (solution, obj) = parse(readAllFromStdin())
  iterations = 1
  newObj: int
  percentage = startingPercentage
  solutionC = solution

iterator randomIndices(p: float): tuple[f, s: int] =
  let nrand = round(p * nbTimeslots.float).int
  var
    indices = newSeq[int]()
    a, b: int
  for i in 0 ..< nbTimeslots:
    indices.add(i)
  while indices.len > nbTimeslots - nrand:
    var r = rand(indices.len - 1)
    a = indices[r]
    indices.delete(r)
    b = a
    while solutionC[b] != -1 and solutionC[a] != -1 and types[solutionC[b]] == types[solutionC[a]]:
      r = rand(indices.len - 1)
      b = indices[r]
    indices.delete(r)
    yield (a, b)

while true:
  if iterations > loops:
    iterations = 0
    percentage += increment
  for (f, s) in randomIndices(percentage):
    solution[f] = -2
    solution[s] = -2
  let cmd = &"minizinc production-planning-lns.mzn -d {data} " &
            &"-D \"{compose(solution, obj)}\" --solver {solver} -p8"
  let output = gorge(cmd)
  echo output
  echo &"using {int(100*percentage)}% of variables"
  echo &"{iterations} iterations without new result"
  (solution, newObj) = parse(output)
  if newObj == obj:
    inc iterations
  else:
    iterations = 0
    obj = newObj
