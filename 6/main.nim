import ./runtimeenum.nim
import tables
import math

const file_name:string = "./breast-cancer.data"

type
  node = ref object
    col:int
    value:int
    is_terminal:bool
    children:seq[node]
  
  section = tuple[col:int,value:int]

proc inside(vector:seq[int],criteria:seq[section]):bool=
  for i in items(criteria):
    if i.value == -1:
      continue
    if vector[i.col] != i.value:
      return false
  return true

proc Rad(x:float64):float64=
  return x * x.log2()

proc CalcEntropy(fr:frame,col:int,class:seq[section]= @[]):float{.discardable.}=
  var counts:seq[int]
  var length:int
  var res:float64 = 0
  counts.setLen(fr.enumeration[col].len())
  for i in items(fr.entries):
    if inside(i,class):
      inc(counts[i[col]])
  length = sum(counts)
  for i in 0..counts.high():
    if counts[i]!=0:
      res = res + Rad(counts[i]/length)
  return -res

proc MakeDescTree(fr:frame,target_class:section,class:seq[section]):node
  var children:seq[node]
  block usual_case:
    #calc entropy
    #get biggest
    return children
    #split for that
    #make nodes
    break usual_case
  return nil

if isMainModule:
  var res = AutoEnum(ReadData(file_name))
  #echo CalcEntropy(res,0,@[(0,1)])