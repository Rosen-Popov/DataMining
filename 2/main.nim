import random
import parseutils
import rdstdin
import times

type
  Board = object
    Queens:seq[int]
    DiagLeft:seq[int]
    DiagRight:seq[int]
    RowConf:seq[int]
    Conf:seq[int]

proc SetVals(s:var Board) =
  var maxq = s.Queens.len() - 1
  for pos in 0..maxq:
    s.Queens[pos] = rand(maxq)

proc calculateConflicts(s:var Board)=
  var j :int
  var maxq = s.Queens.len()
  for pos in 0..<maxq:
    j = s.Queens[pos]
    s.DiagLeft[maxq - (j - pos + 1)] += 1
    s.DiagRight[j + pos] += 1
    s.RowConf[pos] += 1

proc Setup(s:var Board,size:int64) =
  s.Queens.setLen(size)
  s.RowConf.setLen(size)
  s.Conf.setLen(size)
  SetVals(s)
  s.DiagLeft.setLen((size*2) - 1)
  s.DiagRight.setLen((size*2) - 1)
  s.calculateConflicts()

proc Reset(s:var Board) =
  SetVals(s)
  s.calculateConflicts()


proc ifconflicts(s:var Board):bool=
  var maxq = s.Queens.len()
  var max = s.DiagLeft.len()
  for pos in 0..<maxq:
    if pos < max:
      if s.RowConf[pos] > 1:
        return true
    if s.DiagRight[pos] > 1:
      return true
    if s.DiagLeft[pos] > 1:
      return true
  return false

proc ClcConf(s:var Board,c1,c2:int):int=
  return s.RowConf[c1] + s.DiagLeft[s.Queens.len() - (c1 - c2 + 1)] + s.DiagRight[c1 + c2]

proc GetMinConfRow(s:var Board,col:int):int=
  var low:int=high(int)
  var maxq = s.Queens.len()
  var tmp:int
  for pos in 0..<maxq:
    tmp = s.ClcConf(pos, col)
    if(tmp < low):
      low  = tmp
    s.Conf[pos] = tmp
  var minim:seq[int]
  for pos in 0..<maxq:
    if s.Conf[pos] == low:
      minim.add(pos)
  result = minim[rand(minim.len()-1)]


proc GetHihConfRow(s:var Board):int=
  var highest:int = low(int)
  var maxq = s.Queens.len()
  var tmp:int
  var res:int
  for pos in 0..<maxq:
    tmp = s.RowConf[s.Queens[pos]] + s.DiagLeft[maxq - (s.Queens[pos] - pos + 1)] + s.DiagRight[s.Queens[pos] + pos] - 3
    if tmp > highest:
      res = pos
      highest = tmp
    s.Conf[pos] = tmp
  if highest == 0:
    return -1
  var minim:seq[int]
  for pos in 0..<maxq:
    if s.Conf[pos] == highest:
      minim.add(pos)
  result = minim[rand(minim.len()-1)]

proc Move(s:var Board,col:int)=
  var old = s.Queens[col]
  var new = s.GetMinConfRow(col)

  s.Queens[col] = new;

  s.RowConf[old] -= 1
  s.DiagLeft[s.Queens.len() - (old - col + 1)] -= 1
  s.DiagRight[old + col] -= 1

  s.RowConf[new] += 1
  s.DiagLeft[s.Queens.len()  - (new - col + 1)] += 1
  s.DiagRight[new + col] += 1

proc Print(s:var Board)=
  when defined(print):
    for i in 0..<s.Queens.len():
      for j in 0..<s.Queens.len():
        if s.Queens[i] == j:
          stdout.write('*')
        else:
          stdout.write('_')
      stdout.write('\n')

proc Solve(s:var Board): float {.discardable.}=
  if s.ifconflicts() == true:
    while true :
      var maxColumn = s.GetHihConfRow()
      if maxColumn == -1:
        echo "kurec"
        break
      s.Move(maxColumn)
      if s.ifconflicts() == false:
        result = cpuTime()
        s.Print()
        break
  else:
    result = cpuTime()
    s.Print()
    echo "Vlado Randoma ftw"

if isMainModule == true:
  var inp:int
  var p = parseInt(readLineFromStdin(""),inp)
  assert(inp>3)
  var sol:Board
  sol.Setup(inp)
  let time = cpuTime()
  let over = sol.Solve()
  echo "Time taken: ", over - time
