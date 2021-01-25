import math
import random
import strutils
import threadpool

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

proc RibLengths(g:Genome,table:seq[Point] ):seq[float64]=
  var res:seq[float64]
  res.setLen(g.gene.high())
  for cnt in 1..g.gene.high():
    res[cnt-1] = DistanceTo(table[g.gene[cnt-1]],table[g.gene[cnt]])
  return res

proc `==`(alpha,contender:Genome):bool=
  return alpha.value == contender.value

proc `<`(alpha,contender:Genome):bool=
  return alpha.value < contender.value

proc Mutate(g:Genome):seq[int]=
  var tmp:seq[int]
  var pos1:int
  var pos2:int
  tmp=g.gene
  while true:
    pos1 = rand(g.gene.high())
    pos2 = rand(g.gene.high())
    if pos1 != pos2:
      swap(tmp[pos1],tmp[pos2])
      return tmp

proc SofiMarinova(g:Genome,f:Genome):seq[int]=
  if g.gene == f.gene:
    return g.gene
  var pos1:int
  var pos2:int
  while true:
    pos1 = rand(g.gene.high())
    pos2 = rand(g.gene.high())
    if pos1 != pos2:
      if pos1 > pos2:
        swap(pos1,pos2)
      return g.gene[0..<pos1] & f.gene[pos1..<pos2] & g.gene[pos2..f.gene.high]

proc GenerateProgeny(Father:Genome,PopSize:int,table:seq[Point],prv_pop:seq[Genome] = @[]):seq[Genome]=
  var tmp : seq[Genome]
  tmp.setLen(PopSize)
  tmp[tmp.high()] = Father
  for i in 0..(tmp.high()-1):
    tmp[i].gene = Mutate(Father)
    tmp[i].value = tmp[i].Evaluate(table)
  return tmp

#proc BestTrait(g:Genome,table:seq[Point]):seq[Slice]=
#  var res:seq[float] = RibLengths(g,table)
#  var mean:float = sum(res) / res.len().float
#  var ratio:float = res.max() / mean
#  var good:seq[Slice]
#  var cnt = 1
#  var lower = 0
#  for i in mitems(res):
#    if i * ratio > mean:
#      i = 0
#  for i in items(res):
#    if i == 0:
#      if lower - cnt > 2:
#        good.add(Slice(lower:lower,upper: cnt))
#      lower = cnt
#    inc(cnt) 
#  return good

##proc SweetHomeAlabama(Father:Genome,PopSize:int,table:seq[Point],prv_pop:seq[Genome]):seq[Genome]=
#  var tmp : seq[Genome]
#  tmp.setLen(PopSize)
#  tmp[tmp.high()] = Father
#  for i in 0..tmp.high()-1:
#    tmp[i].gene = Mutate(tmp[i])
#    tmp[i].gene = SofiMarinova(prv_pop[i],Father)
#    tmp[i].value = tmp[i].Evaluate(table)
#  return tmp

#proc HabsburgDynasty(Father:Genome,PopSize:int,table:seq[Point],prv_pop:seq[Genome]):seq[Genome]=
#  var tmp : seq[Genome]
#  tmp.setLen(PopSize)
#  tmp[tmp.high()] = Father
#  for i in 0..(tmp.high()-1):
#    tmp[i].gene = Mutate(tmp[i])
#    tmp[i].gene = SofiMarinova(tmp[i],Father)
#    tmp[i].gene = Mutate(tmp[i])
#    tmp[i].value = tmp[i].Evaluate(table)
#  return tmp

proc GenerateTable(len:int):seq[Point]=
  var tmp:seq[Point]
  tmp.setLen(len)
  for i in 0..tmp.high():
    tmp[i].x = rand(100)-50
    tmp[i].y = rand(100)-50
  return tmp

proc GetBest(s:seq[Genome],dgb:bool=false):Genome=
  var best:int =0
  for i in 0..s.high():
    if  s[i] < s[best]:
      best = i
  return s[best]

proc TravelingSalesman(PopSize,:int,table:seq[Point],procreate:proc (Father:Genome,PopSize:int,table:seq[Point],prv_pop:seq[Genome]):seq[Genome,],fname:string):string{.discardable.}=
  var alpha:Genome
  var CrntAlpha:Genome
  var NPoints:int = table.len()
  var Adam:Genome
  var Archive:seq[seq[Genome]]
  var print_timer:int=10
  var print_times:int=4
  #var Consec:int =0
  var Consec:int =4
  var evolved:bool=true
  var itr:int = 20000
  var starter:float64

  Adam.gene.setLen(NPoints)
  for i in 0..Adam.gene.high():
    Adam.gene[i]=i
  shuffle(Adam.gene)
  Adam.value = Evaluate(Adam,table)

  Archive.add(GenerateProgeny(Adam,PopSize,table))
  alpha = GetBest(Archive[0],true)

  var conv:int =0
  echo alpha.value
  starter = alpha.value

  for i in 0..itr:
    print_timer = print_timer - 1
    Archive.add(procreate(alpha,PopSize,table,Archive[Archive.high]))
    CrntAlpha = GetBest(Archive[Archive.high()])

    if CrntAlpha.value < alpha.value:
      alpha = CrntAlpha
      conv = i
    if print_timer == 0 and print_times > 0:
      echo "============================"
      echo ("gen ",Archive.high())
      print_timer = rand(10..15)
      print_times = print_times - 1
      #for i in items(Archive[Archive.high()]):
      #  echo i.gene,"  ",i.value
      echo CrntAlpha
      echo "============================"

  echo ("gen ",Archive.high())
  for i in items(Archive[Archive.high()]):
    echo i.gene,i.value

  result = "starts with " & $starter & " shortened to "& $alpha.value & "\n" & "\nwith" & fname & "\n"
 
if isMainModule:
  #randomize(42069)
  randomize(100)
  var inp:int=100
  var kids:int=100
  var table=GenerateTable(inp)

  echo TravelingSalesman(kids,table,GenerateProgeny,"random swap")



