import bitops
import strutils
import rdstdin

const MAX_DEPTH =3

var player_O = 'O'
var player_X = 'X'
let empty = '-'

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

#proc BitToString(us:int,them:int,us_id:char):string=
#  var res:string="---------"
#  if us_id == player_X:
#    for i in 0..8:
#      if bitand(us,1 shl (8-i))>0:
#        res[i] = player_X
#      if bitand(them,1 shl (8-i))>0:
#        res[i] = player_O
#  else:
#    for i in 0..8:
#      if bitand(us,1 shl (8-i))>0:
#        res[i] = player_O
#      if bitand(them,1 shl (8-i))>0:
#        res[i] = player_X
#  #DisplayBoard(res)
#  return res

proc BitToString(us:int,them:int):string=
  var res:string="---------"
  for i in 0..8:
    if bitand(us,1 shl (8-i))>0:
      res[i] = player_X
    if bitand(them,1 shl (8-i))>0:
      res[i] = player_O
  return res

proc MinMax(depth:int,player:char,pl_X:int,pl_O,alpha,beta:int):int=
  if player == player_O:
    if depth == MAX_DEPTH or bitor(pl_O,pl_X) == 511:
      return nWins(BitToString(pl_O,pl_X),player)
    else:
      if CheckIfWin(BitToString(pl_O,pl_X),player):
        return 10
      if CheckIfWin(BitToString(pl_O,pl_X),player_X):
        return 0
  else:
    if depth == MAX_DEPTH or bitor(pl_O,pl_X) == 511:
      return nWins(BitToString(pl_X,pl_O),player)
    else:
      if CheckIfWin(BitToString(pl_O,pl_X),player):
        return 10
      if CheckIfWin(BitToString(pl_O,pl_X),player_O):
        return 0
  if player == player_O:
    #echo "here"
    var tmp:int= high(int)
    var tmp_beta:int=beta
    var al:int=bitor(pl_O,pl_X)
    var possi:int = 1
    while possi < (1 shl 9):
      if bitor(possi,al) != al:
        tmp = min(tmp, MinMax(depth+1,player_X,pl_X,bitor(pl_O,possi),alpha,tmp_beta))
        tmp_beta = min(beta,tmp)
        if tmp_beta <= alpha:
          break
      possi = possi shl 1
    return tmp_beta
  else:
    var tmp:int= low(int)
    var tmp_alpha:int=alpha
    var al:int=bitor(pl_O,pl_X)
    var possi:int = 1
    while possi < 1 shl 9:
      if bitor(possi,al) != al:
        tmp = max(tmp, MinMax(depth+1,player_O,bitor(pl_X,possi),pl_O,alpha,beta))
        tmp_alpha = max(alpha,tmp)
        if beta <= tmp_alpha:
          break
      possi = possi shl 1
    return tmp_alpha

proc IsValidMove(first,second,move:int):bool=
  var c:int=bitor(first,second)
  if bitor(c,(1 shl (8-move))) == c:
    return false
  return true

proc ComputerMakeMove(first,second:int,plId:char):int=
  var best_value:int = -1
  var tmp_value:int = -1
  var best_move:int = 0
  for i in 0..8:
    if IsValidMove(first,second,i):
      tmp_value = MinMax(0, player_O, first, bitor(second,(1 shl (8-i))), low(int), high(int))
      if tmp_value > best_value:
        best_value = tmp_value
        best_move = (1 shl (8-i))
  echo best_move, " " ,best_value
  return bitor(second,best_move)
#  else:
#    for i in 0..8:
#      if IsValidMove(first,second,i):
#        echo i
#        tmp_value = MinMax(1, player_O, bitor(first,(1 shl (8-i))), second, low(int), high(int))
#        if tmp_value > best_value:
#          best_value = tmp_value
#          best_move = (1 shl (8-i))
#    echo best_move, " " ,best_value
#    return bitor(first,best_move)

if isMainModule == true:
  var line:string
  var player_first:bool = true
  var first:int=0
  var second:int=0
  var tr:bool
  if readLineFromStdin("Player is first ? [Y/N]", line) == true:
    if line == "Y":
      player_first = true
    else:
      player_first = false
  else:
    player_first = false
  if player_first:
    swap(player_O,player_X)

  while bitor(first,second) != 511:
    if player_first :
      tr =  readLineFromStdin("Your move[0~8] ",line)
      var move = parseInt(line)
      if -1 < move and move < 10 and  IsValidMove(first,second,move):
        first = bitor(first,(1 shl (8-move)))
        echo BitToString(first,second)
        DisplayBoard(BitToString(first,second))
      else:
        assert(false)
      second = ComputerMakeMove(first,second,player_X)
      #echo first," ",second," ",bitor(first,second)
      #echo BitToString(first,second)
      DisplayBoard(BitToString(first,second))
    else:
      first = ComputerMakeMove(second,first,player_X)
      #echo BitToString(first,second)
      DisplayBoard(BitToString(first,second))
      tr = readLineFromStdin("Your move[0~8] ",line)
      var move = parseInt(line)
      if -1 < move and move < 10 and  IsValidMove(first,second,move):
        second = bitor(second,(1 shl (8-move)))
        echo BitToString(first,second)
        DisplayBoard(BitToString(first,second))
      else:
        assert(false)
      echo first.toBin(9),"\n",second.toBin(9),"\n",bitor(first,second).toBin(9)
