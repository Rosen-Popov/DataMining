#!/usr/bin/python3
import os
import math
import sequtils
import lists
import strutils
import sets
import algorithm
import heapqueue
import random

const FOUND:int = -1
const NOT_FOUND:int = -2

const up:int     = 1
const down:int   = 2
const left:int   = 3
const right:int  = 4

const isUsed    = 1
const isInHist  = 2
const isPossi   = 0


var solution_state: seq[int]

type
  MoveState = ref object
    move:int
    used:int
    state:seq[int]
#  MoveStateTreeNode = ref object
#    parent: MoveStateTreeNode
#    children:seq[ MoveStateTreeNode]
#    board_state:MoveState
#    heur:int

  PossiChain = ref object
    states:seq[MoveState]
    n_states:int
    position:int

#proc PosiChToTreeNode(parent:var MoveStateTreeNode,pos:PossiChain,heuristic:int)=
#  parent.children = @[]
#  for i in mitems(pos.):


proc Get(nd: PossiChain):MoveState=
  if nd.position < nd.states.len():
    return nd.states[nd.position]
  else:
    return nil

proc Next(nd:var PossiChain)=
  inc(nd.position)

proc RemoveFromHistory(nd: PossiChain, hist:var HashSet[seq[int]])=
  for i in items(nd.states):
    if i.used == isUsed:
      hist.excl(i.state)

proc index[T](src:seq[T],item:T):int=
  for i in 0..src.len():
    if src[i] == item:
      return i

proc manhatan_distance(crnt,sol_state:seq[int]):int=
  let b_len:int = int(pow(crnt.len().float,0.5))
  result = 0
  var pos_fr:int = 0
  var pos_to:int = 0
  for i_crnt in 0..crnt.high():
    pos_fr = i_crnt
    pos_to = sol_state.index(crnt[i_crnt])
    result = result + abs((pos_fr div b_len) - (pos_to div b_len))
    result = result + abs((pos_fr mod b_len) - (pos_to mod b_len))
  return result


proc swap_gen_new(board:seq[int], fr,to:int ):seq[int]=
  var tmp:seq[int]=board
  swap(tmp[fr],tmp[to])
  return tmp

proc Hsort(board1,board2:MoveState):int=
  if manhatan_distance(board1.state,solution_state) >= manhatan_distance(board2.state,solution_state):
    return 1
  return -1
proc BaseState(base:seq[int]): PossiChain=
  var res = new(PossiChain)
  res.n_states = 1
  res.position = 0
  res.states = @[new(MoveState)]
  res.states[0].state = base
  res.states[0].move = 0
  res.states[0].used = 0
  return res


proc gen_possi(board:MoveState): PossiChain=
  var res:PossiChain = PossiChain()

  res.states = @[MoveState(),MoveState(),MoveState(),MoveState()]

  res.n_states = 0
  let b_len:int = int(pow(board.state.len().float,0.5))
  let zero_pos = board.state.index(0)
  let x_p = zero_pos div b_len
  let y_p = zero_pos mod b_len
  var i:int = 0

  if x_p > 0 and board.move != down:
    res.states[i].move = up
    res.states[i].state = swap_gen_new(board.state,zero_pos,zero_pos-b_len)
    inc(i)

  if x_p < b_len-1 and board.move != up :
    res.states[i].move = down
    res.states[i].state = swap_gen_new(board.state,zero_pos,zero_pos+b_len)
    inc(i)

  if y_p > 0 and board.move != right:
    res.states[i].move = left
    res.states[i].state = swap_gen_new(board.state,zero_pos,zero_pos-1)
    inc(i)

  if y_p < b_len-1 and board.move != left:
    res.states[i].move = right
    res.states[i].state = swap_gen_new(board.state,zero_pos,zero_pos+1)
    inc(i)
  res.states.setLen(i)

  sort(res.states,Hsort)

  return res

proc gen_sol_state(size, zer_pos:int):seq[int]=
  var res:seq[int]
  for i in 1..(size):
    if i == zer_pos:
      res.add(0)
    res.add(i)
  if 0 notin res:
    res.add(0)
  solution_state = res
  return res

proc PrintSquare(tbl: seq[int])=
  var root:int =int(sqrt(tbl.len().float))
  var tmp: int = 0
  while tmp < tbl.len():
    echo  tbl[tmp..<(tmp + root)].map(proc (x:int):string = $x) .map(proc(x:string):string= align(x,3)).foldl(a & b)
    inc(tmp,root)

#proc Shmoves(store:var WeirdListSetQueThing)=
#  store.move_que.remove(store.move_que.head)
#  var len:int
#  for i in nodes(store.move_que):
#    inc(len)
#  echo len
#  for i in items(store.move_que):
#    case i:
#      of 1:
#        echo "up"
#      of 2:
#        echo "down"
#      of 3:
#        echo "right"
#      of 4:
#        echo "left"
#      else:
#        echo ""
type
  Board = object
    b_len:int
    board:seq[int]
    sol_state:seq[int]
proc SumToInd(heu_chain:var seq[int],ind:int):int=
  result = 0
  for i in 0..ind:
    result = heu_chain[i] + result
  return result

proc `<`(board1,board2:MoveState):bool= manhatan_distance(board1.state,solution_state) < manhatan_distance(board2.state,solution_state)

proc sec(data:Board,bound:int,crnt_path:seq[PossiChain]):seq[PossiChain]{.discardable.}=
  var MovePath:seq[PossiChain] = @[]
  var heuristic:seq[int]
  var hist:HashSet[seq[int]]
  var len:int = 0
  MovePath.add(BaseState(data.board))
  var minpath_heu:int= high(int)
  var minpath:seq[PossiChain]

  heuristic.add(manhatan_distance(data.board,solution_state))
  var local_state:  MoveState
  var last:  PossiChain 
  var heuristic_path:int

  while true:
    last = MovePath[len]
    heuristic_path = SumToInd(heuristic,len)

    local_state = Get(last)
    if local_state == nil:
      MovePath[len] = nil
      dec(len)
      MovePath[len].Next()
    elif local_state.state == solution_state:
      return MovePath
    elif hist.contains(local_state.state):
      last.states[last.position].used = isInHist
      last.Next()
    else:
      last.states[last.position].used = isUsed
      hist.incl(local_state.state)
      var tmp: PossiChain
      tmp= gen_possi(local_state)
      tmp.position = 0
      inc(len)
      if len == MovePath.len():
        MovePath.add(tmp)
      else:
        MovePath[len]= tmp
    if len  == 0:
      return MovePath

proc SmartAppendToSeq[T](sq:var seq[T], item:T,ind:int)=
  if ind >= sq.high():
    if int(float(ind) * 1.3) == ind:
      sq.setLen(ind+10)
    else:
      sq.setLen(int(float(ind) * 1.3))
    sq[ind] = item
  else:
    sq[ind] = item

proc chk(ite:MoveState,sq:seq[MoveState]):bool=
  for l in items(sq):
    echo ite.state 
    echo l.state 
    if ite.state == l.state:
      return false
  return true
  
var bef:HashSet[seq[int]]
proc cpy(path,ans:var seq[MoveState],len:int)=
  ans.setLen(len)
  for i in 0..ans.high():
    ans[i] = path[i]

proc search(path:var seq[MoveState], g, bound,depth:int,ans_path:var seq[MoveState]):int=
  var node = path[depth-1]
  var f :int= g + manhatan_distance(node.state,solution_state)
  if f > bound:
    return f
  if node.state  == solution_state:
    ans_path = path 
    ans_path.setLen(depth)
    return FOUND
  var min:int= high(int)
  for succ in items(gen_possi(node).states):
    if succ.state notin bef:
      bef.incl(succ.state)
      SmartAppendToSeq(path,succ,depth)
      var res:int= search(path, g + 1, bound,depth+1,ans_path)
      if res == FOUND: 
        return FOUND
      if res < min:
        cpy(path,ans_path,depth+1)
        min = res
      bef.excl(succ.state)
  return min

proc ida_star(root:MoveState):seq[MoveState]=
    var bound = 0#manhatan_distance(root.state,solution_state)
    var path:seq[MoveState] = @[root]
    var ans:seq[MoveState] = @[root]
    while true:
      var s_res = search(path, 0, bound,ans.high(),ans)
      path = ans
      for i in items(ans):
        bef.incl(i.state)
      if s_res == FOUND:
        return ans
      if s_res == high(int):
        return @[]
      bound = s_res

if isMainModule:
  #var tmp_board:seq[int] = @[1,2,3,4,5,6,7,8,0]
  #var tmp_board:seq[int] = @[2,3,1,6,5,0,8,7,4]
  var tmp_board:seq[int] = @[2,3,1,6,5,0,8,7,4]
  #var tmp_board = toSeq(0..15)
  randomize()
  tmp_board.shuffle
  var zero_pos = 1
  var size = 8
  var expl = true
  var sol:Board
  sol.b_len = len(tmp_board)
  sol.board = tmp_board
  sol.sol_state = gen_sol_state(tmp_board.high,-1)
  var res =  BaseState(tmp_board).states[0].ida_star()
  for i in items(res):
    if expl==true:
      echo "====================="
      PrintSquare(i.state)
    case i.move:
      of up:
        echo "up"
      of down:
        echo "down"
      of right:
        echo "right"
      of left:
        echo "left"
      else:
        echo ""
