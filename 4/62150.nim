import strutils
import rdstdin
import tables
import sequtils

const MAX_DEPTH =3

var player_O = 'O'
var player_X = 'X'
let empty = '-'
var players:Table[bool,char]

players[false] = player_O
players[true] = player_X


proc DisplayBoard(board:string)=
  echo ""
  for i in 0..board.high():
    stdout.write(" ")
    stdout.write(board[i])
    if (i+1) mod 3 == 0:
      stdout.write("\n")
      if i != board.high():
        echo "---+---+---"
    else:
      stdout.write(" |")

proc CheckPos(board:string,start,iter:int,pl:char):int=
  result = 0
  var pos:int = start
  var loops:int = 0
  var en = player_O
  if pl == en:
    en = player_X
  while pos<board.len() and loops<3:
    if board[pos] == pl:
      result = result + 1
    pos = pos + iter
    loops = loops+1

proc CheckIfWin(board:string,pl:char):bool=
  #checks collumns
  for i in 0..<3:
    if CheckPos(board,i,3,pl) == 3:
      return true
  #checks rows
  for i in 0..<3:
    if CheckPos(board,i*3,1,pl) == 3:
      return true
  #checks diagonals
  if CheckPos(board,0,4,pl) == 3:
    return true
  if CheckPos(board,2,2,pl) == 3:
    return true
  return false

proc CheckCanWin(board:string,start,iter:int,pl:char):bool=
  var pos:int = start
  var loops:int = 0
  var en = player_O
  if pl == en:
    en = player_X
  while loops<3:
    if board[pos + loops * iter ] == en :
      return false
    loops = loops+1
  return true

proc nWins(board:string,pl:char):int=
  #checks collumns
  result = 0
  for i in 0..<3:
    if CheckCanWin(board,i,3,pl):
      #    echo pl," can win on h1 ",i
      result = result + 1
  for i in 0..<3:
    if CheckCanWin(board,i*3,1,pl):
      #    echo pl," can win on h2 ",i
      result = result + 1
  if CheckCanWin(board,0,4,pl):
    #  echo pl," can win on h3"
    result = result + 1
  if CheckCanWin(board,2,2,pl):
    #  echo pl," can win on h4"
    result = result + 1
  #echo result
  return result

proc BitToString(state:Table[int,char]):string=
  var res:string="---------"
  for i in 0..8:
    if state.hasKey(i):
      res[i] = state[i]
  return res

proc MinMax(depth:int,player:bool,state:Table[int,char],alpha,beta:int):int=
  if depth == MAX_DEPTH:
    return nWins(BitToString(state),players[player])
  else:
    if CheckIfWin(BitToString(state),players[player]):
      if player:
        return 9
      return -1
    if CheckIfWin(BitToString(state),players[not player]):
      if not player:
        return -1
      return 9
  if player:
    var tmp:int= high(int)
    var tmp_beta:int=beta
    for possi in 0..8:
      if state.hasKey(possi) == false:
        var tmp_table = state
        tmp_table[possi] = players[player]
        tmp = min(tmp, MinMax(depth+1,not player,tmp_table,alpha,beta))
        tmp_beta = min(beta,tmp)
        if tmp_beta <= alpha:
          break
    return tmp_beta
  else:
    var tmp:int= low(int)
    var tmp_alpha:int=alpha
    for possi in 0..8:
      if state.hasKey(possi) == false:
        var tmp_table = state
        tmp_table[possi] = players[player]
        tmp = max(tmp, MinMax(depth+1,not player,tmp_table,alpha,beta))
        tmp_alpha = max(alpha,tmp)
        if beta <= tmp_alpha:
          break
    return tmp_alpha

proc IsValidMove(state:Table[int,char],move:int):bool=
  return not state.hasKey(move)

proc ComputerMakeMove(state:var Table[int,char],pl:bool)=
  var resulto:seq[int]
  var best:int = -1
  if pl:
    resulto = @[10,10,10, 10,10,10, 10,10,10]
  else:
    resulto = @[-2,-2,-2,-2,-2,-2,-2,-2,-2]

  block pp:
    if pl:
      for possi in 0..8:
        if state.hasKey(possi) == false:
          var tmp_table = state
          tmp_table[possi] = players[pl]
          resulto[possi] = MinMax(1,not pl,tmp_table,low(int),high(int))
      best = resulto.minIndex()
    else:
      for possi in 0..8:
        if state.hasKey(possi) == false:
          var tmp_table = state
          tmp_table[possi] = players[not pl]
          resulto[possi] = MinMax(1, pl,tmp_table,low(int),high(int))
      best = resulto.maxIndex()
  echo resulto, pl
  state[best] = players[pl]

if isMainModule == true:
  var line:string
  var player_first:bool = true
  var state:Table[int,char]
  var tr:bool
  var winner:bool = false
  if readLineFromStdin("Player is first ? [Y/N]", line) == true:
    if line == "Y":
      player_first = true
    else:
      player_first = false
  else:
    player_first = false
  if player_first:
    swap(player_O,player_X)

  while not winner:
    if player_first :
      tr =  readLineFromStdin("Your move[0~8] ",line)
      var move = parseInt(line)
      if -1 < move and move < 10 and IsValidMove(state,move):
        state[move] = players[player_first]
        DisplayBoard(BitToString(state))
      else:
        assert(false)
      if CheckIfWin(BitToString(state),players[player_first]):
        echo players[player_first]," wins"
        assert(false)
      ComputerMakeMove(state,not player_first)
      DisplayBoard(BitToString(state))
      if CheckIfWin(BitToString(state),players[not player_first]):
        echo players[player_first]," wins"
        assert(false)
    else:
      ComputerMakeMove(state,not player_first)
      if CheckIfWin(BitToString(state),players[not player_first]):
        echo players[not player_first]," wins"
        assert(false)
      DisplayBoard(BitToString(state))
      tr = readLineFromStdin("Your move[0~8] ",line)
      var move = parseInt(line)
      if -1 < move and move < 10 and IsValidMove(state,move):
        state[move] = players[player_first]
        DisplayBoard(BitToString(state))
      else:
        assert(false)
      if CheckIfWin(BitToString(state),players[player_first]):
        echo players[player_first]," wins"
        assert(false)
