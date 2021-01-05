import strutils
import strformat
import sequtils
import random
import math
import threadpool
import os

let filename:string = "unbalance.txt"
let sep:char=','
type
  pnt = object
    x,y:float64
    cluster:int

var max_data_x:float64
var max_data_y:float64
var min_data_x:float64
var min_data_y:float64
var closeness:float = 1.1

proc pnt_cmp(x,y:pnt):int=
  if x.x < y.x:
    return -1
  elif x.x == y.x:
    return 0
  else:
    return -1

proc ReadFile(file:string,line_sep:char):seq[pnt]{.discardable.}=
  var res:seq[pnt]
  var f:File
  var line:string
  if f.open(file) == false:
    return res
  while f.readLine(line):
    let tmp:seq[float64] = line.split(line_sep).map(parseFloat)
    var pn:pnt 
    pn.x = tmp[0]
    pn.y = tmp[1]
    pn.cluster = 0 
    res.add(pn)
  f.close()
  return res

proc DistanceBetween(data_point, center:pnt):float64=
  return sqrt( (data_point.x - center.x) ^ 2 + (data_point.y - center.y) ^ 2 )

proc GetDataLimits(data:seq[pnt])=
  max_data_x = data[0].x
  min_data_x = data[0].x
  for i in items(data):
    if max_data_x < i.x :
      max_data_x = i.x 
    if i.x < min_data_x:
      min_data_x = i.x 

  max_data_y = data[0].y
  min_data_y = data[0].y
  for i in items(data):
    if max_data_y < i.y:
      max_data_y = i.y 
    if i.y < min_data_y:
      min_data_y = i.y 

proc MergeClusters(points,clusters:var seq[pnt],to:int,fr:int)=
  for ind in 0..points.high():
    if points[ind].cluster == fr:
      points[ind].cluster = to

  clusters[fr].x = float(rand(round(max_data_x - min_data_x).int) + int(min_data_x))
  clusters[fr].y = float(rand(round(max_data_y - min_data_y).int) + int(min_data_y))

  return

proc IndexOfClosestCenter(data_point:pnt,centers:seq[pnt]):int=
  var min_res:float64 = high(float64)
  var lengths:seq[float64] = repeat(0.0,len(centers))
  var percent:seq[float64] = repeat(0.0,len(centers))

  for i in 0..centers.high():
    lengths[i] = DistanceBetween(data_point,centers[i])
  return lengths.minIndex()

proc IndexPercents(data_point:pnt,centers:seq[pnt]):seq[float]=
  var min_res:float64 = high(float64)
  var lengths:seq[float64] = repeat(0.0,len(centers))
  var percent:seq[float64] = repeat(0.0,len(centers))
  var min_ind:int
  for i in 0..centers.high():
    lengths[i] = DistanceBetween(data_point,centers[i])
  min_ind = lengths.minIndex()
  for i in 0..centers.high():
    percent[i] = lengths[i] / lengths[min_ind]
  return percent

proc SetToNearest(data:var seq[pnt],centers:seq[pnt]):bool{.discardable.}=
  var res_cluster:int
  var changed:bool = true
  for ind in 0..data.high():
    res_cluster = IndexOfClosestCenter(data[ind],centers)
    if data[ind].cluster != res_cluster:
      changed = false
    data[ind].cluster = res_cluster
  return changed

proc PrintData[T](data:seq[T])=
  for i in items(data):
    echo i
proc Print(data:seq[pnt])=
  echo "x\t\t\t\t\ty\t\t\tcluster"
  for i in items(data):
    echo i.x,"\t\t",i.y,"\t\t\t",i.cluster

proc CalcNewCluster(data:seq[pnt],center:pnt):pnt=
  var x_sum:seq[float64]
  var y_sum:seq[float64]
  var items:int = 0
  var res:pnt = center
  for i in 0..data.high():
    if data[i].cluster == center.cluster:
      inc(items)
      x_sum.add(data[i].x)
      y_sum.add(data[i].y)
  x_sum.apply(proc(x:var float64) = x = x / items.float)
  y_sum.apply(proc(x:var float64) = x = x / items.float)
  res.x = x_sum.sum()
  res.y = y_sum.sum()
  return res

proc RecalculateCenters(data: seq[pnt],centers:var seq[pnt])=
  #what do
  var res:seq[FlowVar[pnt]]
  res.setLen(centers.len)
  for i in 0..high(centers):
   res[i] = spawn CalcNewCluster(data,centers[i])
  for i in 0..high(centers):
    centers[i] = ^res[i]

proc CompareClusterTo(data:seq[pnt],stats:seq[seq[float]],fr,to:int):float64=
  var count:int
  var sum:float64
  for i in 0..data.high():
    if data[i].cluster == fr:
      sum = sum + stats[i][to]
  return sum / count.float

proc ReviewClusters(data: seq[pnt],centers:seq[pnt]):seq[int]=
  var stats:seq[seq[float]]
  stats.setLen(data.len())
  var merge_into:seq[int] = repeat(-1,centers.len())
  for i in 0..data.high():
    stats[i] = IndexPercents(data[i],centers)
  for base in 0..(centers.high()-1):
    for to in (base+1)..centers.high():
      var to_loc:float64 = CompareClusterTo(data,stats,base,to)
      var fr_loc:float64 = CompareClusterTo(data,stats,to,base)




  return merge_into

proc ExportToCsv(data:seq[pnt],name:string) =
  var f:File 
  if f.open(name,fmWrite) == false:
    echo "could not write"
    return
  for i in items(data):
    f.writeLine(fmt"{i.x},{i.y},{i.cluster}")
  f.close()

if isMainModule:
  #var fname:string = commandLineParams()[0]
  #var clusters:int =  commandLineParams()[1].parseInt
  randomize()
  var fname:string = filename
  var clusters:int = 8
  var data:seq[pnt] = ReadFile(fname,sep)
  var centers:seq[pnt]
  var iterations:int = 1000
  centers.setLen(clusters)
  GetDataLimits(data)

# random split
  for i in 0..centers.high():
    centers[i] = sample(data)
    centers[i].cluster = i
# more equal split 
  #for i in 0..centers.high():
  #  var ind = i * (data.len() div centers.len())
  #  centers[i] = data[ind]
  #  centers[i].cluster = i
  #  echo centers[i]," ",ind


  for i in 0..iterations:
    if SetToNearest(data,centers):
      echo "no more clustering at iteration ",i
      break
    RecalculateCenters(data,centers)

  #centers.sort(pnt_cmp)
  Print(centers)
  ExportToCsv(data,"interm.csv")
  ExportToCsv(centers,"clusters.csv")
