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
  pnt_s = object
    x,y:float64
    cluster_prob:seq[float]

var max_data_x:float64
var max_data_y:float64
var min_data_x:float64
var min_data_y:float64

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
proc ReadFileSoft(file:string,line_sep:char,n_cl:int):seq[pnt_s]{.discardable.}=
  var res:seq[pnt_s]
  var f:File
  var line:string
  if f.open(file) == false:
    return res
  while f.readLine(line):
    let tmp:seq[float64] = line.split(line_sep).map(parseFloat)
    var pn:pnt_s
    pn.x = tmp[0]
    pn.y = tmp[1]
    pn.cluster_prob = repeat(0.0,n_cl)
    res.add(pn)
  f.close()
  return res
#def update_centers(x, r, K):
#    N, D = x.shape
#    centers = np.zeros((K, D))
#    for k in range(K):
#        centers[k] = r[:, k].dot(x) / r[:, k].sum()
#    return centers
#
#def square_dist(a, b):
#    return (a - b) ** 2
#
#def cost_func(x, r, centers, K):
#    
#    cost = 0
#    for k in range(K):
#        norm = np.linalg.norm(x - centers[k], 2)
#        cost += (norm * np.expand_dims(r[:, k], axis=1) ).sum()
#    return cost
#
#
#def cluster_responsibilities(centers, x, beta):
#    N, _ = x.shape
#    K, D = centers.shape
#    R = np.zeros((N, K))
#
#    for n in range(N):        
#        R[n] = np.exp(-beta * np.linalg.norm(centers - x[n], 2, axis=1)) 
#    R /= R.sum(axis=1, keepdims=True)
#    print("r ",R)
#
#    return R
#
proc DistanceBetween(data_point, center:pnt|pnt_s):float64=
  return sqrt( (data_point.x - center.x) ^ 2 + (data_point.y - center.y) ^ 2 )


proc SoftCluster(data:var seq[pnt_s],centers:seq[pnt_s],beta:float)=
  for n in 0..data.high():
    for i in 0..centers.high():
      data[n].cluster_prob[i] = exp( -beta * DistanceBetween(centers[i],data[n]))
    var sm = sum(data[n].cluster_prob)
    for i in 0..centers.high():
      data[n].cluster_prob[i] = data[n].cluster_prob[i] / sm 

proc SoftUpdate(data: seq[pnt_s],centers:var seq[pnt_s])=
  var res:seq[FlowVar[pnt]]
  res.setLen(centers.len)
  var sums:seq[float]
  sums.setlen(centers.len)
  for cen in 0..high(centers):
    for poi in 0..high(data):
      sums[cen] = sums[cen] + data[poi].cluster_prob[cen]
  for cen in 0..high(centers):
    for poi in 0..high(data):
      centers[cen].x += data[poi].cluster_prob[cen] * data[poi].x
      centers[cen].y += data[poi].cluster_prob[cen] * data[poi].y
    centers[cen].x = centers[cen].x / sums[cen]

#def soft_k_means(x, K, max_iters=20, beta=1.):
#    centers = initialize_centers(x, K)
#    print(centers)
#    prev_cost = 0
#    for _ in range(max_iters):
#        r = cluster_responsibilities(centers, x, beta)
#        centers = update_centers(x, r, K)
#        cost = cost_func(x, r, centers, K)
#        if np.abs(cost - prev_cost) < 1e-5:
#            break
#        prev_cost = cost
#        
#    plot_k_means(x, r, K)


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

#proc MergeClusters(points,clusters:var seq[pnt],to:int,fr:int)=
#  for ind in 0..points.high():
#    if points[ind].cluster == fr:
#      points[ind].cluster = to
#
#  clusters[fr].x = float(rand(round(max_data_x - min_data_x).int) + int(min_data_x))
#  clusters[fr].y = float(rand(round(max_data_y - min_data_y).int) + int(min_data_y))
#
#  return

proc IndexOfClosestCenter(data_point:pnt,centers:seq[pnt]):int=
  var min_res:float64 = high(float64)
  var lengths:seq[float64] = repeat(0.0,len(centers))
  var percent:seq[float64] = repeat(0.0,len(centers))

  for i in 0..centers.high():
    lengths[i] = DistanceBetween(data_point,centers[i])
  return lengths.minIndex()


proc SetToNearest(data:var seq[pnt],centers:seq[pnt]):bool{.discardable.}=
  var res_cluster:int
  var changed:bool = true
  for ind in 0..data.high():
    res_cluster = IndexOfClosestCenter(data[ind],centers)
    if data[ind].cluster != res_cluster:
      changed = false
    data[ind].cluster = res_cluster
  return changed


proc Total(data:var seq[pnt],centers:seq[pnt]):float64{.discardable.}=
  var sm:float64 = 0
  for ind in 0..data.high():
    sm = sm +  DistanceBetween(data[ind],centers[data[ind].cluster])
  return sm


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
  var res:seq[FlowVar[pnt]]
  res.setLen(centers.len)
  for i in 0..high(centers):
   res[i] = spawn CalcNewCluster(data,centers[i])
  for i in 0..high(centers):
    centers[i] = ^res[i]

#proc CompareClusterTo(data:seq[pnt],stats:seq[seq[float]],fr,to:int):float64=
#  var count:int
#  var sum:float64
#  for i in 0..data.high():
#    if data[i].cluster == fr:
#      sum = sum + stats[i][to]
#  return sum / count.float

#proc ReviewClusters(data: seq[pnt],centers:seq[pnt]):seq[int]=
#  var stats:seq[seq[float]]
#  stats.setLen(data.len())
#  var merge_into:seq[int] = repeat(-1,centers.len())
#  for i in 0..data.high():
#    stats[i] = IndexPercents(data[i],centers)
#  for base in 0..(centers.high()-1):
#    for to in (base+1)..centers.high():
#      var to_loc:float64 = CompareClusterTo(data,stats,base,to)
#      var fr_loc:float64 = CompareClusterTo(data,stats,to,base)
#
#  return merge_into

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
  var best_data:seq[pnt]
  var best_centers:seq[pnt]
  var centers:seq[pnt]
  var iterations:int = 1000
  var rand_rest= 10
  centers.setLen(clusters)
  GetDataLimits(data)

# random split
  for i in 0..centers.high():
    centers[i] = sample(data)
    centers[i].cluster = i

  for i in 0..iterations:
    if SetToNearest(data,centers):
      echo "no more clustering at iteration ",i
      break
    RecalculateCenters(data,centers)
  best_data = data
  best_centers = centers
  for i in 0..rand_rest:
    for i in 0..centers.high():
      centers[i] = sample(data)
      centers[i].cluster = i
    for i in 0..iterations:
      if SetToNearest(data,centers):
        echo "no more clustering at iteration ",i
        break
      RecalculateCenters(data,centers)
    echo "finished ", i
    var crnt:float64 = Total(data,centers)
    var best:float64 = Total(best_data,centers)
    echo crnt ," ", best
    if  crnt < best  :
      best_data = data
      best_centers = centers

  Print(centers)
  ExportToCsv(best_data,"interm.csv")
  ExportToCsv(best_centers,"clusters.csv")
