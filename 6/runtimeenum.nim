import strutils
import sequtils
import tables
import algorithm
import random

const file_name = "breast-cancer.data"

type
  frame* = object
    entries*:seq[seq[int]]
    enumeration*:seq[Table[string,int]]

proc ReadData*(file:string):seq[seq[string]]{.discardable.}=
  var data_source:File
  var res:seq[seq[string]]
  var line:string
  data_source = open(file)
  if data_source == nil:
    assert(false)
  while readLine(data_source,line):
    res.add(line.split(','))
  return res

proc Uniq*(raw_frame:seq[seq[string]],col:int):Table[string,int]=
  var res: Table[string,int]
  var counter = 0
  var unq:seq[string]

  for i in items(raw_frame):
    if i[col] notin unq:
      unq.add(i[col])
  unq.sort()
  for en in items(unq):
    res[en] = counter
    inc(counter)
  return res

proc AutoEnum*(raw_frame:seq[seq[string]],set_cols:seq[int]= @[]):frame{.discardable.}=
  randomize()
  var res:frame
  var collumns:seq[int] = set_cols
  res.enumeration.setLen(raw_frame[0].len())
  res.entries.setLen(raw_frame.len())
  if collumns == @[]:
    collumns = toSeq(0..raw_frame[0].high())
  for col in items(collumns):
    res.enumeration[col] = Uniq(raw_frame,col)
  for ent in 0..raw_frame.high():
    res.entries[ent].setLen(raw_frame[ent].len())
    for ind in 0..raw_frame[ent].high():
      res.entries[ent][ind] = res.enumeration[ind][raw_frame[ent][ind]]
  res.entries.shuffle()
  return res

proc PrimeForLearning*(fr:var frame,prc:int):frame=
  var res:frame
  var len:int = int((prc / 100) * fr.entries.len().float)
  res.enumeration = fr.enumeration
  res.entries = fr.entries[len..fr.entries.high()]
  fr.entries = fr.entries[0..len]
  return res

if isMainModule:
  var res = AutoEnum(ReadData(file_name))
  for i in items(res.enumeration):
    echo i
  for i in items(res.entries):
    echo i
