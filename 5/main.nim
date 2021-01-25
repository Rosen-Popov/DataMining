import os
import strutils
import lists
import sequtils
import strformat
import random
import times

const source:string = "./house-votes-84.data"
const Republican:int = 1
const Democrat:int = 0
const yes:int = 1
const no:int = -1
const fuck_if_i_know = 0

const party:int = 0
const handicapped_infants:int=1
const water_project_cost_sharing:int=2
const adoption_of_the_budget_resolution:int=3
const physician_fee_freeze:int=4
const el_salvador_aid:int=5
const religious_groups_in_schools:int=6
const anti_satellite_test_ban:int=7
const aid_to_nicaraguan_contras:int=8
const mx_missile:int=9
const immigration:int=10
const synfuels_corporation_cutback:int=11
const education_spending:int=12
const superfund_right_to_sue:int=13
const crime:int=14
const duty_free_exports:int=15
const export_administration_act_south_africa:int=16
const ALL_TRAITS = 17

let identifiers:seq[int] = @[
  party,
  handicapped_infants,
  water_project_cost_sharing,
  adoption_of_the_budget_resolution,
  physician_fee_freeze,
  el_salvador_aid,
  religious_groups_in_schools,
  anti_satellite_test_ban,
  aid_to_nicaraguan_contras,
  mx_missile,
  immigration,
  synfuels_corporation_cutback,
  education_spending,
  superfund_right_to_sue,
  crime,
  duty_free_exports,
  export_administration_act_south_africa]

type
  senator = object
    repr:seq[int]
  stats = object
    dem_yes:seq[float64]
    dem_no:seq[float64]
    dem_abs:seq[float64]
    rep_yes:seq[float64]
    rep_no:seq[float64]
    rep_abs:seq[float64]


proc ReaData(file:string):seq[senator]{.discardable.}=
  var data_source:File
  var res:seq[senator]
  var line:string
  data_source = open(file)
  if data_source == nil:
    assert(false)
  while readLine(data_source,line):
    var crnt:senator
    crnt.repr.setLen(ALL_TRAITS)
    var cnt:int = 0
    for i in line.split(','):
      case i:
        of "democrat":
          crnt.repr[cnt] = Democrat
        of "republican":
          crnt.repr[cnt] = Republican
        of "y":
          crnt.repr[cnt] = yes
        of "n":
          crnt.repr[cnt] = no
        else:
          crnt.repr[cnt] = fuck_if_i_know
      inc(cnt)
    res.add(crnt)
    randomize()
    res.shuffle()
  return res

proc CountFor(set:seq[senator],par,value_id,value_val:int):float64=
  var cnt:int=1
  var all_values:int=1
  for i in items(set):
    if par == i.repr[party]:
      if i.repr[value_id] == value_val:
        inc(cnt)
      inc(all_values)
  return cnt.float64/all_values.float64

proc PartyChance(set:seq[senator],party:int):float64=
  var count:int =1 
  for i in items(set):
    if i.repr[0] == party:
      inc(count)
  return float64(count) / float64(set.len() + 1)

proc GetStats(set:seq[senator]):stats{.discardable.}=
  var count:stats
  count.dem_no.setLen(ALL_TRAITS)
  count.dem_yes.setLen(ALL_TRAITS)
  count.dem_abs.setLen(ALL_TRAITS)
  count.rep_no.setLen(ALL_TRAITS)
  count.rep_yes.setLen(ALL_TRAITS)
  count.rep_abs.setLen(ALL_TRAITS)
  for i in 1..<ALL_TRAITS:
    count.dem_no[i] = CountFor(set,Democrat,i,no)
    count.dem_yes[i] = CountFor(set,Democrat,i,yes)
    count.dem_abs[i] = CountFor(set,Democrat,i,fuck_if_i_know)
    count.rep_no[i] = CountFor(set,Republican,i,no)
    count.rep_yes[i] = CountFor(set,Republican,i,yes)
    count.rep_abs[i] = CountFor(set,Republican,i,fuck_if_i_know)
  count.dem_yes[0] = PartyChance(set,Democrat)
  count.rep_yes[0] = PartyChance(set,Republican)

  return count

proc Splice(origin:senator,yes_val,no_val,abs_val:seq[float64]):seq[float64]=
  var res:seq[float]
  res.setLen(origin.repr.len())
  res[0] = 1
  for i in 1..origin.repr.high():
    case origin.repr[i]:
      of yes:
        res[i] = yes_val[i]
      of no:
        res[i] = no_val[i]
      else:
        res[i] = abs_val[i]
  return res

proc mult(x:seq[float64]):float64=
  var res:float64 =1
  for i in items(x):
    res = res*i
  return res

proc Check(set:seq[seq[senator]],ind:int):string=
  var summary:stats=GetStats(set[ind])
  var succ:int=0
  var all:int=0
  var dem:float
  var rep:float
  var metric:float64

  for i in 0..set.high():
    if i == ind:
      continue
    for j in set[i].items():
      rep = mult(Splice(j,summary.rep_yes,summary.rep_no,summary.rep_abs))/summary.rep_yes[0]
      dem = mult(Splice(j,summary.dem_yes,summary.dem_no,summary.dem_abs))/summary.dem_yes[0]
      if dem < rep and j.repr[0] == Republican:
        inc(succ)
      if rep < dem and j.repr[0] == Democrat:
        inc(succ)
    all = set[i].len()+all
    metric = succ.float64/all.float64
  return fmt"{succ} of {all} coverage:{metric}"


if isMainModule == true:
  var TrainingSets:seq[seq[senator]] = distribute(ReaData(source),10)
  for i in 0..TrainingSets.high():
    echo(i," ",Check(TrainingSets,i))

