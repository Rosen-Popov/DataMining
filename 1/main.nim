#!/usr/bin/python3
import os
import math
import sequtils
import lists
import strutils
import sets
import algorithm


let FOUND = -1
let NOT_FOUND = -2
const FORWARD: int = 1
const BACKWARD:int = -1
const up:int     = 1
const down:int   = 2
const left:int   = 3
const right:int  = 4

const isUsed    = 1
const isInHist  = 2
const isPossi   = 0

var solution_state: seq[int]

#===============================
type
  MoveState = ref object
    move:int
    used:int
    state:seq[int]
  PossiChain = ref object
    states:seq[MoveState]
    n_states:int
    position:int

proc Get(nd: PossiChain):MoveState=
  if nd.position < nd.states.len():
    return nd.states[nd.position]
  else:
    return nil

proc Next(nd:var PossiChain)=
  inc(nd.position)


#func End(nd: PossiChain):bool = (nd.position < nd.states.states.high())

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
#proc AddTo(store:var WeirdListSetQueThing,state:seq[int],move:int)=
#  store.que.append(state)
#  store.move_que.append(move)
#
#proc PopLast(store:var WeirdListSetQueThing)=
#  store.que.remove(store.que.tail)
#  store.move_que.remove(store.move_que.tail)
#proc GetLast(store:WeirdListSetQueThing):pair=
#  var tmp: pair
#  tmp.brd= store.que.head.value
#  tmp.mv= store.move_que.head.value
#  return tmp
#
#proc WasAState(store: WeirdListSetQueThing,state:seq[int]):bool=
#  return store.que.contains(state)

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

#proc MakeBoard(size:int, cfgs:seq[int] ,zero_pos:int):=
#  var path:WeirdListSetQueThing
#  path.que = initDoublyLinkedList[seq[int]]()
#  path.que.append(cfgs)
#  path.move_que = initDoublyLinkedList[int]()
#  path.move_que.append(0)
#  var res:Board
#  res.path = path
#  res.b_len = int(sqrt (size + 1).float)
#  res.board = cfgs
#  res.sol_state = gen_sol_state(size,zero_pos)
#  solution_state = res.sol_state


#def dai_edna_cigara_te_ea_u_zwezdata(root,path,goal):
#  bound = manhatan_distance(root,goal)
#  while 1:
#    t = search(path, 0, bound,goal)
#      if t == FOUND:
#        path.Show()
#          return [path, bound]
#      if t == INF:
#        print("No Solution")
#          return NOT_FOUND
#      bound = t
#
proc sec(data:Board):seq[ PossiChain]{.discardable.}=

  var MovePath:seq[PossiChain] = @[]
  var hist:HashSet[seq[int]]
  var len:int = 0
  #var start_state:MoveState = MoveState()
  #start_state.move = 0
  #start_state.state = data.board

  #base.states = gen_possi(start_state)
  #base.position = 0
  #MovePath[len].states.n_states = 1
  MovePath.add(BaseState(data.board))

  var local_state:  MoveState
  var last:  PossiChain 

  while true:
    last = MovePath[len]

    #echo "============================================"
    #echo solution_state
    #echo "++++++++++++++++++++++++++++++++++++++++++++"
    #for i in items(last.states):
    #  echo i.state
    #echo "--------------------------------------------"
    #for i in items(hist):
    #  echo i
    #echo "============================================"
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


    #var tmp = readLine(stdin)
    if len  == 0:
      return MovePath

if isMainModule:
#  size = int (input())
#  zero_pos = int(input())
#  tmp_board = []
#  for i in range(int((size+1)**0.5)):
#    tmp_board.extend( [pl for pl in (input().split(" ")) if pl !=" "] )
#  for i in range(len(tmp_board)):
#    tmp_board[i]=int(tmp_board[i])
#
#
  var tmp_board:seq[int] = @[2,3,1,6,5,0,8,7,4]
  var zero_pos = 1
  var size = 8
  var sol:Board
  sol.b_len = 9
  sol.board = tmp_board
  sol.sol_state = gen_sol_state(8,-1)
  var res = sol.sec()
  for i in items(res):
