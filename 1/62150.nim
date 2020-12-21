#!/usr/bin/python3
import os
import math
import sequtils


let FOUND = -1
let NOT_FOUND = -2
const up:int     = 1
const down:int   = 2
const left:int   = 3
const right:int  = 4

#===============================
type
  MoveState = object
    move:int
    state:seq[int]
  Possi = object
    states:seq[MoveState]
    n_states:int

proc index[T](src:seq[T],item:T):int=
  for i in 0..src.len():
    if src[i] == item:
      return i

proc manhatan_distance(crnt,sol_state:seq[int]):int=
  let b_len:int = int(pow(crnt.len().float,0.5))
  result = 0
  var pos_fr:int = 0
  var pos_to:int = 0
  for i_crnt in 0..crnt.len():
    pos_fr = i_crnt
    pos_to = sol_state.index(crnt[i_crnt])
    result = result + abs((pos_fr div b_len) - (pos_to div b_len))
    result = result + abs((pos_fr mod b_len) - (pos_to mod b_len))
  return result


proc swap_gen_new(board:seq[int], fr,to:int ):seq[int]=
  var tmp:seq[int]=board
  swap(tmp[fr],tmp[to])
  return tmp

proc gen_possi(board:MoveState):Possi=
  var res:Possi
  res.states.setlen(4)
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

  return res

proc gen_sol_state(size, zer_pos:int):seq[int]=
  var res:seq[int]
  res.setlen(size+1)
  var i:int = 0 

  while i < size+1:
    if i == zer_pos:
      res[i] = 0
      inc(i)
    res[i] = i+1
    inc(i)
  if 0 notin res:
    res[i] = 0
  return res


class WeirdListSetQueThing:
  def __init__(self,start):
  self._que = [start]
      self._move_que = [0]

  def AddTo(self,state,move):
    self._que.append(state)
      self._move_que.append(move)

  def RemoveLast(self):
    tmp = self._que[len(self._que)-1]
      self._que.pop(len(self._que)-1)
      self._move_que.pop(len(self._move_que)-1)
  def GetLast(self):
    self._que[len(self._que)-1]
      self._move_que[len(self._move_que)-1]
      result = [ self._move_que[len(self._move_que)-1], self._que[len(self._que)-1]]
      return result
  def Show(self):
    self._move_que.pop(0)
      print(len(self._move_que))
      moves = {0:"",1:"up",2:"down",3:"right",4:"left"}
      for i in self._move_que:
        print(moves[i])

      #for i in self._que:
      #    print(i[0],i[1],i[2])
      #    print(i[3],i[4],i[5])
      #    print(i[6],i[7],i[8])
      #    print("============")

  def In(self,target):
    return target in self._que


def dai_edna_cigara_te_ea_u_zwezdata(root,path,goal):
  bound = manhatan_distance(root,goal)
  while 1:
    t = search(path, 0, bound,goal)
      if t == FOUND:
        path.Show()
          return [path, bound]
      if t == INF:
        print("No Solution")
          return NOT_FOUND
      bound = t

def search(path, g, bound,goal):
  node = path.GetLast()
  f = g + manhatan_distance(node[1],goal)
  if f > bound:
    return f
  if node[1] == goal:
    return FOUND
  min = INF
  for succ in gen_possi(node[1]):
    if not path.In(succ[1]):
      path.AddTo(succ[1],succ[0])
      t = search(path, g + 1, bound,goal)
      if t == FOUND:
        return FOUND
      if t < min:
        min = t
      path.RemoveLast()
  return min

class Board:
  def __init__(self, size , cfg ,zero_pos):
    self.b_len = int(((size + 1 )** 0.5))
    self.board = cfg
    self.sol_state = gen_sol_state(size,zero_pos)
    self.path = WeirdListSetQueThing(cfg)

  def Solve(self):
    return dai_edna_cigara_te_ea_u_zwezdata(self.board,self.path,self.sol_state)

if __name__ == "__main__":
  size = int (input())
  zero_pos = int(input())
  tmp_board = []
  for i in range(int((size+1)**0.5)):
    tmp_board.extend( [pl for pl in (input().split(" ")) if pl !=" "] )
  for i in range(len(tmp_board)):
    tmp_board[i]=int(tmp_board[i])


# tmp_board = [1,2,3,4,5,6,0,7,8]
    # zero_pos = 1
    # size = 8
    sol = Board(size,tmp_board,zero_pos)
    sol.Solve()
