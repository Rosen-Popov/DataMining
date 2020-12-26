import ./runtimeenum.nim
import tables
import math

const file_name:string = "./breast-cancer.data"

type
  node = object
    col:int
    value:int
    is_terminal:bool
    children:seq[ref node]
  section = object

proc Rad(x:float64):float64=
  return x * x.log2()

proc CalcEntropy(fr:frame,col:int,class:seq[int]= @[]):float{.discardable.}=
  var counts:seq[int]
  var length:int = fr.entries.len()
  var res:float64 = 0
  counts.setLen(fr.enumeration[0].len())
  for i in items(fr.entries):
    if class.len() == 0:
      inc(counts[i[col]])
    elif i[col] in class:
      inc(counts[i[col]])
  for i in 0..counts.high():
    if class.len() == 0:
      res = res + Rad(counts[i]/length)
    elif i in class:
      res = res + Rad(counts[i]/length)
  return -res


proc MakeDescTree(fr:frame,target_col:int,taken_cols:seq[int]):ref node=
  return nil

if isMainModule:
  var res = AutoEnum(ReadData(file_name))





