import bitops

const MAX_DEPTH = 1

let player_O = 'O'
let player_X = 'X'
let empty = ' '


proc DisplayBoard(board:string)=
  stdout.write("\t")
  for i in 0..board.high():
    stdout.write(board[i])
    if (i+1) mod 3 == 0:
      stdout.write("\n\t")

proc CheckPos(board:string,start,iter:int,pl:char):int=
  result = 0
  var pos:int = start
  while pos<=board.high():
    if board[pos] == pl:
      result = result + 1
    pos = pos + iter

proc CheckIfWin(board:string,pl:char):bool=
  #checks collumns
  for i in 0..3:
    if CheckPos(board,i,3,pl) == 3:
      return true
  #checks rows
  for i in 0..3:
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
  while pos<=board.high():
    if board[pos] != pl and board[pos] != empty :
      return false
    pos = pos + iter
  return true

proc nWins(board:string,pl:char):int=
  #checks collumns
  result = 0
  for i in 0..3:
    if CheckCanWin(board,i,3,pl):
      result = result + 1
  #checks rows
  for i in 0..3:
    if CheckCanWin(board,i*3,1,pl):
      result = result + 1
  #checks diagonals
  if CheckCanWin(board,0,4,pl):
    result = result + 1
  if CheckCanWin(board,2,2,pl):
    result = result + 1

proc BitToString(us:int,them:int,us_id:char):string=
  var res:string="---------"
  if us_id == player_X:
    for i in 0..8:
      if bitand(us,1 shl i)>0:
        res[i] = player_X
      if bitand(them,1 shl i)>0:
        res[i] = player_O
  else:
    for i in 0..8:
      if bitand(us,1 shl i)>0:
        res[i] = player_O
      if bitand(them,1 shl i)>0:
        res[i] = player_X
  return res

proc MinMax(depth:int,player:char,pl_X:int,pl_O,alpha,beta:int):int=
  if depth == MAX_DEPTH or bitor(pl_O,pl_X) == 511:
    if player == player_O:
      return nWins(BitToString(pl_O,pl_X,player),player)
    else:
      return nWins(BitToString(pl_X,pl_O,player),player)
  if player == player_O:
    echo "here"
    var tmp:int= high(int)
    var tmp_beta:int=beta
    var al:int=bitor(pl_O,pl_X)
    var possi:int = 1
    while possi < 1 shl 9:
      if bitor(possi,al) == al:
        tmp = min(tmp, MinMax(depth,player_X,pl_X,bitor(pl_O,possi),alpha,tmp_beta))
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
      if bitor(possi,al) == al:
        tmp = max(tmp, MinMax(depth,player_O,bitor(pl_X,possi),pl_O,alpha,beta))
        tmp_alpha = max(alpha,tmp)
        if tmp_alpha <= alpha:
          break
      possi = possi shl 1
    return tmp_alpha

if isMainModule == true:
  var field:string = "--O-O-O--"
  DisplayBoard( field)
  echo MinMax(1,player_O,0,0,low(int),high(int))
  echo ""
