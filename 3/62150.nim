import math
import random

type
  Genome = object
    gene:seq[int]
    value:float64

  Point = object
    x:int
    y:int

proc DistanceTo(fr,to:Point):float64=
  var tmp:int=((fr.x-to.x)^2) + ((fr.y-to.y)^2)
  return sqrt(tmp.float)

proc Evaluate(g:Genome,table:seq[Point] ):float64=
  var acc:float64=0
  for cnt in 1..g.gene.high():
    acc = acc + DistanceTo(table[g.gene[cnt-1]],table[g.gene[cnt]])
  return acc

proc `==`(alpha,contender:Genome):bool=
  return alpha.value == contender.value

proc `<`(alpha,contender:Genome):bool=
  return alpha.value < contender.value

proc Mutate(g:Genome):Genome=
  var tmp:Genome
  var pos1:int
  var pos2:int
  deepCopy(tmp.gene,g.gene)
  while true:
    pos1 = rand(g.gene.high())
    pos2 = rand(g.gene.high())
    if pos1 != pos2:
      swap(tmp.gene[pos1],tmp.gene[pos2])
      return tmp

proc GenerateProgeny(Father:Genome,PopSize:int,table:seq[Point] ):seq[Genome]=
  var tmp : seq[Genome]
  tmp.setLen(PopSize)
  tmp[tmp.high()] = Father
  for i in 0..(tmp.high()-1):
    tmp[i] = Mutate(Father)
    tmp[i].value = tmp[i].Evaluate(table)
  return tmp

proc GenerateTable(len:int):seq[Point]=
  var tmp:seq[Point]
  tmp.setLen(len)
  for i in 0..tmp.high():
    tmp[i].x = rand(400)-200
    tmp[i].y = rand(400)-200
  return tmp

proc GetBest(s:seq[Genome],dgb:bool=false):Genome=
  var best:int =0
  for i in 0..s.high():
    if  s[i] > s[best]:
      best = i
  return s[best]

proc TravelingSalesman(PopSize,:int,table:seq[Point]):Genome{.discardable.}=
  var alpha:Genome
  var CrntAlpha:Genome
  var NPoints:int = table.len()
  var Adam:Genome
  var Archive:seq[seq[Genome]]
  var print_timer:int=10
  var print_times:int=4
  var Consec:int =4
  var evolved:bool=true

  Adam.gene.setLen(NPoints)
  for i in 0..Adam.gene.high():
    Adam.gene[i]=i
  shuffle(Adam.gene)
  Adam.value = Evaluate(Adam,table)

  Archive.add(GenerateProgeny(Adam,PopSize,table))
  alpha = GetBest(Archive[0],true)

  echo alpha.value
  while Consec > 0 or evolved:
    print_timer = print_timer - 1
    evolved = false
    Archive.add(GenerateProgeny(alpha,PopSize,table))
    CrntAlpha = GetBest(Archive[Archive.high()])
    if CrntAlpha == alpha:
      Consec = Consec - 1
    else:
      Consec = 4

    if CrntAlpha.value < alpha.value:
      alpha = CrntAlpha
      evolved = true

    if print_timer == 0 and print_times > 0:
      echo "============================"
      echo ("gen ",Archive.high())
      print_timer = rand(10..15)
      print_times = print_times - 1
      for i in items(Archive[Archive.high()]):
        echo i.gene,"  ",i.value
      echo "============================"

  echo "============================"
  echo ("gen ",Archive.high())
  for i in items(Archive[Archive.high()]):
    echo i.gene,i.value
  echo "============================"
  echo alpha.gene,"  ",alpha.value
  return alpha

if isMainModule:
  randomize(2103)
  var inp:int=20
  var kids:int=200
  var table=GenerateTable(inp)
  TravelingSalesman(kids,table)
