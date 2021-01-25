import tables
import sequtils
import math
import ./runtimeenum.nim

let file_name:string = "./breast-cancer.data"
let set_limiter:int = 5
let AnySection:int= -1
let LearningPart:int = 80
let TARGET_CLASS:int = 0
var ignore_classes:seq[int] = @[5,3,8,7,6,2,1] #wut?


type
  node = ref object
    col:int
    value:int
    is_terminal:bool
    children:seq[node]

  section = tuple[col:int,value:int]

var tree_sequence:seq[int] = @[]

proc inside(vector:seq[int],criteria:seq[section]):bool=
  for i in items(criteria):
    if i.value == AnySection:
      continue
    if vector[i.col] != i.value:
      return false
  return true

proc unused(vector:seq[int],criteria:seq[section]):seq[int]=
  var tmp:seq[int]
  tmp = toSeq(0..vector.high())
  for i in items(criteria):
    tmp[i.col] = -1
  return tmp

proc Rad(x:float64):float64=
  return x * x.log2()

proc CalcFrequency (fr:frame,col:int,class:seq[section]= @[],safe:bool=true):seq[int]{.discardable.}=
  var counts:seq[int]
  var length:int
  counts.setLen(fr.enumeration[col].len())
  for i in items(fr.entries):
    if inside(i,class):
      inc(counts[i[col]])
  length = sum(counts)
  if length < set_limiter and safe:
    return @[]
  return counts

proc CalcEntropyFeature(fr:frame,col:int,class:seq[section]= @[]):float64{.discardable.}=
  var counts:seq[int] = CalcFrequency(fr,col,class)
  var res:seq[float64] = @[]
  var length:int = sum(counts)
  res.setLen(fr.enumeration[col].len())
  for i in 0..counts.high():
    if counts[i]!=0:
      res[i] = abs(Rad(counts[i]/length))
  return res.sum()


proc CalcWeightedAvg(fr:frame,col:int,class:seq[section]= @[]):float64{.discardable.}=
  var counts:seq[int] = CalcFrequency(fr,col,class)
  var res:seq[float64] = @[]
  var length:int = sum(counts)
  res.setLen(fr.enumeration[col].len())
  for i in 0..counts.high():
    if counts[i]!=0:
      res[i] = abs((counts[i]/length) * Rad(counts[i]/length))
  return res.sum()

proc CalcIg(fr:frame,target_class:section,col:int,class:seq[section]= @[]):float64{.discardable.}=
  return CalcEntropyFeature(fr,target_class.col,class) - CalcWeightedAvg(fr,col,class)

proc MakeDescTree(fr:frame,target_class:section,class:seq[section],depth:int = 0):seq[node]{.discardable.}=
  var children:seq[node]
  var max_entropy:float = 0
  var best_seed_ind:int = 0
  var tmpEntropy:seq[float]
  var tmpIG:seq[float]
  var choice:seq[int] = fr.entries[0].unused(concat(@[target_class],class))
  tmpEntropy.setLen(fr.entries[0].len())
  tmpIG.setLen(fr.entries[0].len())
  for i in 0..choice.high():
    if choice[i] > -1 and i notin ignore_classes:
      tmpEntropy[i] = CalcEntropyFeature(fr,i,class)
      tmpIG[i] = CalcIg(fr,target_class,i)
  max_entropy = tmpIG.max()
  best_seed_ind = tmpIG.maxIndex()
  children.setLen(fr.enumeration[best_seed_ind].len)
  echo class

  if tree_sequence[depth] == -1:
    tree_sequence[depth] = best_seed_ind

  for i in 0..<fr.enumeration[best_seed_ind].len:
    children[i] = node()

  for i in 0..children.high():
    if CalcEntropyFeature(fr,target_class.col,concat(class,@[(best_seed_ind,i)]))==0:
      children[i].col = best_seed_ind
      children[i].is_terminal = true
      children[i].value = CalcFrequency(fr,target_class.col,concat(class,@[(best_seed_ind,i)]),false).maxIndex()
      children[i].children = @[]
    else:
      children[i].is_terminal = false
      children[i].children = MakeDescTree(fr,target_class,concat(class,@[(best_seed_ind,i)]),depth+1)
  return children

proc GetClassFromTree(to_be_tested:seq[int],crnt_node:seq[node]):int=
  var nod:node
  var nod_children:seq[node] = crnt_node
  for crnt in items(tree_sequence):
    nod = nod_children[to_be_tested[crnt]]
    if nod.is_terminal:
      return nod.value
    elif nod.children.len() > 0:
      nod_children = nod.children
    else:
      echo "oh no"
      return -1
  return -1

proc CheckTree(cross_frame:frame,target_col:int,tree:seq[node]):float=
  var right:int = 0
  var result_for_check:int
  for i in items(cross_frame.entries):
    result_for_check = GetClassFromTree(i,tree)
    if result_for_check == -1:
      echo "oh noes"
    else:
      if result_for_check == i[target_col]:
        inc(right)
  return right / cross_frame.entries.len()

if isMainModule:
  var res = AutoEnum(ReadData(file_name))
  var cross = PrimeForLearning(res,LearningPart)
  tree_sequence = repeat(-1,res.entries[0].len)
  var tree:seq[node]=MakeDescTree(res,(TARGET_CLASS,AnySection),@[])
  tree_sequence = tree_sequence[0..<tree_sequence.minIndex()]
  echo "with ignoring: ", ignore_classes," res is ", CheckTree(cross,TARGET_CLASS,tree)


