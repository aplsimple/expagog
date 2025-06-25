###########################################################
# Name:    stat.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jan 20, 2025
# Brief:   Handles statistics of EG app.
# License: MIT.
###########################################################

# _________________________ stat ________________________ #

namespace eval stat {
  variable pobj ::stat::pavedObj
  variable win $::EG::WIN.stat
  variable date1 {}
  variable date2 {}
  variable aggrdata; array set aggrdata {}
  variable maxdiff 0.005
  variable fieldwidth 11  ;# defined by " yyyy/mm/dd" fields
  variable fmt0 [string repeat 9 $fieldwidth]
  variable fmt1 [string repeat 9 [expr {$fieldwidth-2}]].9
  variable fmt2 [string repeat 9 [expr {$fieldwidth-3}]].99
  variable fmtX [string repeat \r $fieldwidth]
  variable DS; set DS [dict create]
  variable Table1 {}
  variable Table2 {}
  variable TextCont {}
  variable fontsize 11
  variable tags {}
  variable tagsHtml {}
}

# ________________________ Common _________________________ #

proc stat::Fmt {val {fmt ""}} {
  # Formats value to display.
  #   val - value
  #   fmt - format

  variable fmt0
  if {$fmt eq {}} {set fmt 9999}
  set wd0 [string length $fmt]
  set wd1 [expr {$wd0-1}]
  set fill [string repeat { } $wd0]
  switch [string index $fmt 0] {
    9 { ;# number
      lassign [split $fmt .] intf decf
      if {$decf ne {}} {
        # - float
        set digits [string length $decf]
        set fill0 [string repeat 0 $digits]
        set val [EG::Round $val $digits]
        lassign [split $val .] int dec
        set val $int.[string range $dec$fill0 0 [incr digits -1]]
      } else {
        # - integer
        set val [expr {round($val)}]
      }
      set res [string range $fill$val end-$wd1 end]
    }
    \r { ;# text aligned to right
      set res [string range $fill$val end-$wd1 end]
    }
    default { ;# text aligned to left
      set res [string range $val$fill 0 $wd1]
    }
  }
  return $res
}
#_______________________

proc stat::FmtCnt {cnt} {
  # Formats count.
  #   cnt - count

  set c [Fmt $cnt]
  if {$cnt==0} {set c [string repeat { } [string length $c]]}
  return $c
}
#_______________________

proc stat::PutLine {varn line {tag ""}} {
  # Puts a line to statistics text.
  #   varn - variable's name to put the line into
  #   line - line's contents
  #   tag - tag of line

  upvar $varn var
  if {$tag ne {}} {set line <$tag>$line</$tag>}
  append var \ $line\n
}
#_______________________

proc stat::AggregateFormula {} {
  # Gets AggrEG formula.

  EG::CheckAggrEG
  return $::EG::D(AggrEG)
}
#_______________________

proc stat::CalculateByFormula {formula data {defvalue ""}} {
  # Calculates value by formula.
  #   formula - formula containing item names and/or $NN of items
  #   data - list of item values (in order of D(Items))
  #   defvalue - value at errors: "" or 0
  # Formula may contain overlapping item names,
  # so formula "P * 2 + Pa + $3" should be properly converted to
  #   ${P} * 2 + ${Pa} + ${item3}
  # instead of possible improper ${P} * 2 + ${P}a + ${item3}

  if {![info exists ::EG::D(F=$formula)]} {
    set lmap1 [list]
    set ir 0
    foreach item $::EG::D(Items) {
      set ln1 $item
      lappend lmap1 [list $ln1 $ir]
      incr ir
    }
    set lmap1 [lsort -decreasing -index 0 -command EG::stat::CompareIt $lmap1]
    set ::EG::D(F=$formula) $lmap1
  }
  set res 0
  foreach ln $::EG::D(F=$formula) {
    lassign $ln ln1 ln2
    set val [lindex $data $ln2]
    set lmap2 [list $ln1 $val \$[incr ln2] $val]
    catch {set formula [string map $lmap2 $formula]}
  }
  if {[catch {set res [expr $formula]}] || $res<0  || $res==Inf} {
    set res $defvalue
  }
  return $res
}
#_______________________

proc stat::CompareIt {it1 it2} {
  # Compares two items' values: first by their length, then by values.
  #   it1 - 1st item's value
  #   it2 - 2nd item's value

  set len1 [string length $it1]
  set len2 [string length $it2]
  if {$len1>$len2} {return 1}
  if {$len1<$len2} {return -1}
  if {$it1 > $it2} {return 1}
  if {$it1 < $it2} {return -1}
  return 0
}
#_______________________

proc stat::CheckCount0 {nval ncnt0} {
  # Checks if cell's value contributes to Count0 (at value<=0).
  #   nval - value variable
  #   ncnt0 - Count0 variable

  upvar $nval val $ncnt0 cnt0
  if {![string is double -strict $val]} {
    incr cnt0
    set val 0
  } elseif {$val<=0} {
    incr cnt0
  }
}

# ________________________ Processing data _________________________ #

proc stat::StatData {} {
  # Collects all data on items.
  # Results are collected in *DS* dict: as sums, counts and averages
  # on dates & items, i.e. "date1 {item1 {cnt cnt0 sum avg} ...} ...",
  # where date1 is 1st date of week.

  variable DS
  variable aggrdata
  set DS [dict create]
  set dkeys [EG::DatesKeys {} {} 0]
  # collect results
  EG::ForEach {} $dkeys {
    set k [string index %k 0]
    if {$k eq {v}} {
      set typ [string range %t 0 3]
      set val [EG::ItemValue $typ %v]
      set item [list %d %i]
      if {[dict exists $DS {*}$item]} {
        set res [dict get $DS {*}$item]
      } else {
        set res [list 0 0 0 0 0 0 0 0]
      }
      lassign $res cnt cnt0 sum
      incr cnt
      CheckCount0 val cnt0
      set sum [expr {$sum + $val}]
      if {[catch {set avg [expr {1.0*$sum/$cnt}]}] \
      || ![string is double -strict $avg]} {
        set avg 0
      }
      dict set DS {*}$item [list $cnt $cnt0 $sum $avg]
    }
  }
  set aggrdata(daysCnt) 0
  set aggrdata(daysCnt1) 0
  set aggrdata(daysCnt0) 0
  set aggrdata(Date1st) {}
  set aggrdata(DateLast) {}
  foreach day $dkeys {
    if {$aggrdata(DateLast) eq {}} {set aggrdata(DateLast) $day}
    set itv {0 0 0 0 0 0 0}
    catch {
      foreach {it val} [dict get $::EG::EGD $day] {
        lmap {k v} $val {set i [string index $k 1]; set itv [lreplace $itv $i $i 1]}
      }
    }
    foreach i $itv {
      if {$i} {incr aggrdata(daysCnt1)} {incr aggrdata(daysCnt0)}
    }
    incr aggrdata(daysCnt) 7
    set aggrdata(Date1st) $day
  }
  set aggrdata(daysAll) 0
  catch {
    set sec1 [EG::ScanDatePG $aggrdata(Date1st)]
    set sec2 [EG::ScanDatePG $aggrdata(DateLast)]
    set sec2 [clock add [EG::FirstWDay $sec2] +7 days]
    set aggrdata(daysAll) [expr {($sec2-$sec1)/86400}]
    set aggrdata(Date1st) [EG::FormatDatePG $sec1]
    set aggrdata(DateLast) [EG::FormatDatePG $sec2]
  }
}
#_______________________

proc stat::WeekData {{d1 0000/00/00} {d2 9999/99/99}} {
  # Collects data on weeks in range of dates.
  #   d1 - first week's date
  #   d2 - last week's date
  # Returns list of data, corresponding to EG items, where item data is
  # a list of counts, sum, average (cnt, cnt0, sum, avg).

  variable DS
  set results [list]
  foreach item $::EG::D(Items) itemtype $::EG::D(ItemsTypes) {
    set res {( NO DATA )}
    set cnt [set cnt0 0]
    set sum 0.0
    dict for {wdate wval} $DS {
      if {$d1 <= $wdate && $wdate < $d2} {
        foreach {it val} $wval {
          if {$it eq $item} {
            lassign $val wcnt wcnt0 wsum
            incr cnt $wcnt
            incr cnt0 $wcnt0
            set sum [expr {$sum + $wsum}]
          }
        }
      }
    }
    if {$cnt} {
      switch -glob $itemtype {
        calc* {
          set avg $itemtype
        }
        default {
          set avg [expr {1.0 * $sum / $cnt}]
        }
      }
      set res [list $cnt $cnt0 $sum $avg]
    }
    lappend results $res
  }
  set i 0
  foreach res $results {
    lassign $res cnt cnt0 sum avg
    if {[string match calc* $avg]} {
      set sum [EG::CalculatedValue $avg 2 $results]
      set avg [EG::CalculatedValue $avg 3 $results]
      set results [lreplace $results $i $i [list $cnt $cnt0 $sum $avg]]
    }
    incr i
  }
  return $results
}
#_______________________

proc stat::SetDates {} {
  # Initializes dates.

  variable date1
  variable date2
  set date1 [EG::FirstWDay [EG::ScanDate]]
  set date2 [clock add $date1 +1 week]
  set date1 [EG::FormatDate $date1]
  set date2 [EG::FormatDate $date2]
}

## ________________________ Filling tables _________________________ ##

proc stat::StartText {dotext} {
  # Initializes statistics.
  #   dotext - yes if show results in text widget

  variable pobj
  variable fontsize
  variable tags
  variable tagsHtml
  variable Table1
  variable Table2
  variable aggrdata
  array unset aggrdata
  array set aggrdata {}
  if {[obj csDark]} {
    set g #9dff9d
    set r #ff9696
  } else {
    set g green
    set r red
  }
  lassign [obj csGet] fga fg bga bg bgHL actbg actfg cursor greyed hot \
    emfg embg - menubg winfg winbg itemHL2
  set Table1 [set Table2 {}]
  set font [list -family [obj basicTextFont]]
  if {$dotext} {
    set ::EG::D(AggrEG) [[$pobj TexAggr] get 1.0 end]
    set ::EG::D(AggrEG) [string map [list \n { }] [string trim $::EG::D(AggrEG)]]
    if {$fontsize<8 || $fontsize>99} {set fontsize 11}
    set wtxt [$pobj Text]
    set font [list {*}[$wtxt cget -font]]
    $wtxt configure  -font "$font -size $fontsize"
    $pobj readonlyWidget $wtxt no
    $wtxt replace 1.0 end {}
  }
  EG::CheckAggrEG
  set tags [list \
    [list t "-foreground $::EG::Colors(fgit)"] \
    [list a "-background $bga"] \
    [list h "-background $itemHL2"] \
    [list g "-foreground $g"] \
    [list r "-foreground $r"] \
    [list s "-font {$font -size [expr {$fontsize-2}]}"] \
  ]
  set tagsHtml [list \
    [list t "color=#5a1a00"] \
    [list a "style=\"background-color:#ffffff\""] \
    [list h "style=\"background-color:#e2e2e2\""] \
    [list g "color=#006100"] \
    [list r "color=#ff0000"] \
    [list s "size=1"] \
  ]
}
#_______________________

proc stat::FinishText {dotext {wtmp ""}} {
  # Ends collecting statistics.
  #   dotext - yes if show results in text widget
  #   wtmp - temporary (invisible) text widget, for displayTaggedText
  # Returns statistics data formatted for html (if $dotext=false).

  variable pobj
  variable tags
  variable tagsHtml
  variable Table1
  variable Table2
  set ::EG::stat::TextCont ${Table1}[Legend1]\n\n${Table2}[Legend2]\n
  set res {}
  if {$dotext} {
    set wtxt [$pobj Text]
    $pobj displayTaggedText $wtxt ::EG::stat::TextCont $tags
    $pobj readonlyWidget $wtxt yes
    ::tk::TextSetCursor $wtxt 1.0
    [$pobj ButExpo] configure -state normal
  } else {
    set res $::EG::stat::TextCont
    foreach tagval $tagsHtml {
      lassign $tagval tag val
      set res [string map [list <$tag> "<font $val>" </$tag> </font>] $res]
    }
    obj displayTaggedText $wtmp ::EG::stat::TextCont $tags
  }
  return $res
}
#_______________________

proc stat::GetOptions {} {
  # Gets options of tables:
  #  - dates in internal EG format
  #  - width of item column
  #  - title for item column
  #  - filling spaces for item column

  variable date1
  variable date2
  set d1 0000/00/00
  set d2 9999/99/00
  if {$date1 ne {}} {set d1 [EG::FormatDatePG [EG::ScanDate $date1]]}
  if {$date2 ne {}} {set d2 [EG::FormatDatePG [EG::ScanDate $date2]]}
  set namlen 6
  foreach item $::EG::D(Items) {
    if {[set sl [string length $item]] > $namlen} {
      set namlen $sl
    }
  }
  set namfill [string repeat { } $namlen]
  set title [string range Topic$namfill 0 $namlen]
  list $d1 $d2 $namlen $title $namfill
}
#_______________________

proc stat::TableValue {itemtype val {len 0}} {
  # Formats a value for table.
  #   itemtype - type of value
  #   val - value
  #   len - value width

  variable fmt0
  variable fmt1
  variable fmt2
  variable fmtX
  switch -glob $itemtype {
    time {
      set val [EG::TimeSym [Fmt $val $fmt2]]
      set val [Fmt $val $fmtX]
    }
    \r*           {set val [Fmt $val $fmtX]}
    AggrEG        {set val [Fmt $val $fmt1]}
    9*.9* - calc* {set val [Fmt $val $fmt2]}
    default       {set val [Fmt $val $fmt0]}
  }
  if {$len} {set val [string range $val end-$len end]}
  return $val
}
#_______________________

proc stat::Table2Value {nrow ncol nsum nprevsum nitemtype nchprev nrlen nres} {
  # Gets value for Table2.
  #   nrow - row of table
  #   ncol - column of table
  #   nsum - value
  #   nprevsum - previous value
  #   nitemtype - item type
  #   nchprev - flag "check previous sum"
  #   nrlen - width of table line
  #   nres - result part in the table line

  upvar $nrow row $ncol col $nsum sum $nprevsum prevsum \
    $nitemtype itemtype $nchprev chprev $nrlen rlen $nres res
  variable fmtX
  variable aggrdata
  variable maxdiff
  set t1 [set t2 {}]
  if {$chprev && [string is double -strict $sum] && \
  [string is double -strict $prevsum] && $sum!=0 && $prevsum!=0} {
    set s1 [TableValue $itemtype $sum]
    set s2 [TableValue $itemtype $prevsum]
    if {$s1 ne $s2} {
      set diff [expr {($sum - $prevsum) / $sum}]
      if {abs($diff)>$maxdiff} {
        if {$sum > $prevsum} {
          set t1 <g>  ;# green
          set t2 </g>
        } else {
          set t1 <r>  ;# red
          set t2 </r>
        }
      }
    }
  }
  if {![string is double -strict $sum] || $sum==0} {
    set ittype $fmtX
    set sum {}
    set prevsum 0
  } else {
    set ittype $itemtype
    set prevsum $sum
  }
  append res { } $t1[TableValue $ittype $sum]$t2
  incr rlen [string length $t1$t2]
  set aggrdata($row,$col) $prevsum
  incr col
}
#_______________________

proc stat::Table1LinePart1 {resfill item} {
  # Gets part 1 of table-1 line.
  #   resfill - filling string
  #   item - item name

  return <t>[string range $resfill$item end-$::EG::NAMEWIDTH end]\ |</t>
}
#_______________________

proc stat::Table1LinePart2 {resfill item namlen} {
  # Gets part 2 of table-1 line.
  #   resfill - filling string
  #   item - item name
  #   namlen - name length

  return " <t>| [string range $item$resfill 0 $namlen]</t> "
}
#_______________________

proc stat::Table1LinePart3 {itemtype cnt cnt0 sum avg fmt2} {
  #   # Gets part 3 of table-1 line.
  #   itemtype - item type
  #   cnt - Count value
  #   cnt0 - Count0 value
  #   sum - sum value
  #   avg - average value
  #   fmt2 - format for average value

  set sum [TableValue $itemtype $sum 7]
  set avg [TableValue $fmt2 $avg 9]
  return "[FmtCnt $cnt]   [FmtCnt $cnt0]$sum$avg"
}
#_______________________

proc stat::DoTable1 {} {
  # Makes 1st table (data on counts, totals and averages).

  variable date1
  variable date2
  variable fmt1
  variable fmt2
  variable fmtX
  variable DS
  variable aggrdata
  variable Table1
  lassign [GetOptions] d1 d2 namlen namttl namfill
  set title "NN.       $d1 :"
  foreach wd {0 1 2 3 4 5 6} {
    append title "   [lindex $::EG::D(WeekDays) $wd]"
  }
  append title " | ${namttl}Cells Cells0   Total   Average"
  set reslen0 [expr {[string length $title] - $namlen - 64}]
  set under [string repeat - [string length $title]]
  set reslen [expr {$reslen0 + 79}]
  set resfill [string repeat { } $reslen]
  set fmtx [string repeat x $reslen]
  PutLine Table1 "<t>Current      : from Date1 \[</t> $date1 <t>to Date2</t> $date2\
    <t>\)</t>\n"
  PutLine Table1 "<t>Data range   : \[</t> $aggrdata(Date1st) <t>-</t>\
    $aggrdata(DateLast) <t>\)</t>"
  PutLine Table1 "<t>Data days    :</t> $aggrdata(daysAll)\n"
  set todoweeks [expr {($aggrdata(daysCnt)+6)/7}]
  PutLine Table1 "<t>Planned days :</t> $aggrdata(daysCnt)\
    <t>(planned weeks :</t> $todoweeks<t>)</t>"
  PutLine Table1 "<t>Checked days :</t> $aggrdata(daysCnt1)"
  PutLine Table1 "<t>Empty days   :</t> $aggrdata(daysCnt0)\n"
  PutLine Table1 $title t
  PutLine Table1 $under t
  set weekdata [WeekData $d1 $d2]
  set lastweek [EG::WeekValue $d1]
  array set wddata {}
  foreach item $::EG::D(Items) itemtype $::EG::D(ItemsTypes) result $weekdata {
    set res [Table1LinePart1 $resfill $item]
    foreach wd {0 1 2 3 4 5 6} {
      if {[dict exists $lastweek $item v$wd]} {
        set v [string trim [dict get $lastweek $item v$wd]]
        set vdec [EG::ItemValue $itemtype $v]
        if {$itemtype eq {chk} && $v ne {?}} {
          set v [EG::ButtonValue $v]
        }
        set v [string range $v 0 4]
        set v [string range "     $v" end-4 end]
      } else {
        set v {     }
        set vdec 0
      }
      append res " $v"
      set wddata($wd,$item) $vdec
    }
    append res [Table1LinePart2 $resfill $item $namlen]
    lassign $result cnt cnt0 sum avg
    if {[string is double -strict $avg]} {
      append res [Table1LinePart3 $itemtype $cnt $cnt0 $sum $avg $fmt2]
    } else {
      append res [Fmt $result $fmtx]
    }
    append item $namfill
    append res $resfill
    incr NN
    set sn [string range " $NN" end-1 end]
    set line "$sn. [string range $res 0 $reslen]"
    if {$NN%2} {set tag {}} {set tag h}
    PutLine Table1 $line $tag
  }
  PutLine Table1 $under t
  set res [Table1LinePart1 $resfill AggrEG]
  set sum 0
  foreach wd {0 1 2 3 4 5 6} {
    set data [list]
    foreach item $::EG::D(Items) {
      lappend data $wddata($wd,$item)
    }
    set v [CalculateByFormula $::EG::D(AggrEG) $data 0.0]
    set sum [expr {$sum + $v}]
    set v [Fmt $v $fmt1]
    if {$wd==0 || $v==$prev || $v==0.0} {
      set tag [set untag {}]
    } elseif {$v > $prev} {
      set tag <g>
      set untag </g>
    } else {
      set tag <r>
      set untag </r>
    }
    append res $tag[string range "     $v" end-5 end]$untag
    set prev $v
  }
  append res [Table1LinePart2 $resfill AggrEG $namlen]
  append res [Table1LinePart3 $fmt2 7 0 $sum [expr {$sum/7}] $fmt2]
  PutLine Table1 "    [string trimright $res]"
  PutLine Table1 $under t
}
#_______________________

proc stat::DoTable2 {} {
  # Makes 2nd table (data on previous, current and next weeks).

  variable date1
  variable fmt2
  variable fmtX
  variable DS
  variable Table2
  # show table's head
  foreach w {1 2 3 4} {
    set dp$w [EG::FormatDatePG [clock add [EG::ScanDate $date1] -$w week]]
  }
  lassign [GetOptions] d1 d2 namlen title namfill
  set title1 "$title|    Previous [Fmt $dp4 $fmtX] [Fmt $dp3 $fmtX]\
    [Fmt $dp2 $fmtX] [Fmt $dp1 $fmtX]  $d1       Next  |      Total |     \
    Average     Average     Average     Average"
  set title2 "       |       weeks   (-4 week)   (-3 week)   (-2 week)  \
    (-1 week)  $d2       weeks |            |     previous     current       \
    next       total"
  set under [string repeat - [string length $title1]]
  set reslen [expr {[string length $title1] - $namlen + 4}]
  set resfill [string repeat { } $reslen]
  PutLine Table2 $title1 t
  PutLine Table2 $title2 t
  PutLine Table2 $under t
  # collect table's data
  array set weekdata {}
  set weekdata(prev) [list [WeekData {} $dp4] 0]
  set weekdata(dp-4) [list [WeekData $dp4 $dp3] 1]
  set weekdata(dp-3) [list [WeekData $dp3 $dp2] 1]
  set weekdata(dp-2) [list [WeekData $dp2 $dp1] 1]
  set weekdata(dp-1) [list [WeekData $dp1 $d1] 1]
  set weekdata(dp-0) [list [WeekData $d1 $d2] 1]
  set weekdata(next) [list [WeekData $d2] 1]
  set weekdata(current) [list [WeekData $dp4 $d2] 1]
  set weekdata(total) [list [WeekData] 1]
  # get total sums, for the calculated totals
  set Totals [list]
  set irow 0
  # ... firstly, collect all total sums
  foreach itemtype $::EG::D(ItemsTypes) {
    set totsum 0
    foreach wd {prev dp-4 dp-3 dp-2 dp-1 dp-0 next} {
      lassign $weekdata($wd) data
      lassign [lindex $data $irow] - - sum
      catch {set totsum [expr {$totsum+$sum}]}
    }
    lappend Totals [list $itemtype $totsum]
    incr irow
  }
  set i 0
  # ... secondly, calculate the calculated totals
  foreach res $Totals {
    lassign $res itemtype totsum
    if {[string match calc* $itemtype]} {
      set totsum [EG::CalculatedValue $itemtype 1 $Totals]
      if {![string is double -strict $totsum]} {set totsum 0}
      set Totals [lreplace $Totals $i $i [list $itemtype $totsum]]
    }
    incr i
  }
  # show data
  set irow [set totalsum 0]
  foreach item $::EG::D(Items) itemtype $::EG::D(ItemsTypes) {
    append item $namfill
    set line <t>[string range $item 0 $namlen]|</t>
    set rlen $reslen
    # left part of table
    set res {}
    set prevsum 0
    set icol 0
    foreach wd {prev dp-4 dp-3 dp-2 dp-1 dp-0 next} {
      lassign $weekdata($wd) data chprev
      lassign [lindex $data $irow] cnt cnt0 sum avg
      Table2Value irow icol sum prevsum itemtype chprev rlen res
    }
    set totsum [lindex $Totals $irow 1]
    set totalsum [expr {$totalsum + $totsum}]
    # right part of table
    append res " <t>|[TableValue $itemtype $totsum] | </t>"
    set prevsum 0
    foreach wd {prev current next total} {
      lassign $weekdata($wd) data chprev
      lassign [lindex $data $irow] cnt cnt0 sum avg
      Table2Value irow icol avg prevsum fmt2 chprev rlen res
    }
    append res $resfill
    append line [string range $res 0 $rlen]
    if {[incr tagtik]%2} {set tag {}} {set tag h}
    PutLine Table2 $line $tag
    incr irow
  }
  PutLine Table2 $under t
  # AggrEG values
  set line <t>[string range AggrEG$namfill 0 $namlen]|</t>
  set rlen $reslen
  set prevsum [set itmp1 [set itmp2 0]]
  set itemtype AggrEG
  set res {}
  for {set ic 0} {$ic<$icol} {incr ic} {
    set aeg [AggregateValue $ic]
    if {$ic==($icol-4)} {
      append res " <t>|[TableValue $fmt2 $totalsum]*| </t>"
    }
    Table2Value itmp1 itmp2 aeg prevsum itemtype ic rlen res
  }
  append res $resfill
  append line [string range $res 0 $rlen]
  PutLine Table2 $line
  PutLine Table2 $under t
}
#_______________________

proc stat::AggregateValue {ic} {
  # Gets agregate value (AggrEG) from *aggrdata* array and *aggregate* formula.
  #   ic - index of column in *aggrdata* array

  variable aggrdata
  EG::CheckAggrEG
  set data [list]
  set ir 0
  foreach item $::EG::D(Items) {
    lappend data $aggrdata($ir,$ic)
    incr ir
  }
  CalculateByFormula $::EG::D(AggrEG) $data
}
#_______________________

proc stat::Legend1 {} {
  # Gets Table1's legend.

  return "<s>\n\
    Cells   - all cells to be checked\n\
    Cells0  - cells non-checked (\"?\") or failed (value<=0) \n\
    Total   - total sum of values\n\
    Average - Total / Cells\n\
    The marks \"?\" stand for cells to be checked on Date1.\n</s>"
}
#_______________________

proc stat::Legend2 {} {
  # Gets Table2's legend.

  variable maxdiff
  return " <t>AggrEG formula:</t> $::EG::D(AggrEG)\n\
    <s>\n\
    Previous weeks   - total sum for weeks before \"Date (-4 week)\"\n\
    Date (-4 week)   - total sum for week \"Date1 -4 week\"\n\
    Date (-3 week)   - total sum for week \"Date1 -3 week\"\n\
    Date (-2 week)   - total sum for week \"Date1 -2 week\"\n\
    Date (-1 week)   - total sum for week \"Date1 -1 week\"\n\
    Date1-Date2      - total sum for week \"Date1 - Date2\"\n\
    Next weeks       - total sum for weeks after \"Date1 - Date2\"\n\
    Total*           - rather \"total activity\" than anything real\n\
    Average previous - average for \"Previous weeks\"\n\
    Average current  - average for \"Date1 -4 week\" to Date2\n\
    Average next     - average for \"Next weeks\"\n\
    Average total    - average for all weeks\n\
    --------------------------------------------------------------\n\
    AggrEG - the aggregate estimate calculated from the formula\n\
    that can include \$NN and Topic links, e.g. EG+PG/2+\$8*2.\n\
    --------------------------------------------------------------\n\
    The <r>red</r> / <g>green</g> values mean:\n\
    - a value is <r>lesser</r> / <g>greater</g> than previous one by\
    [expr {$maxdiff*100}]% or more.</s>"
}

# ________________________ Actions _________________________ #

proc stat::ChooseWeek {dtvar ent} {
  # Calls a calendar to pick a date.
  #   dtvar - date variable name
  #   ent - date entry's path

  variable date1
  variable date2
  variable win
  set dt [EG::ChooseDay ::EG::stat::$dtvar -entry $ent -parent $win]
  if {$dt ne {}} {
    set ::EG::stat::$dtvar [EG::FormatDate [EG::FirstWDay $dt]]
    set dt1 [EG::ScanDate $date1]
    set dt2 [EG::ScanDate $date2]
    if {$dt1>$dt2} {
      if {$dtvar eq {date1}} {set date2 $date1} {set date1 $date2}
    }
  }
}
#_______________________

proc stat::Report {} {
  # Outputs text to html.

  variable win
  EG::Source repo
  set savedtpl $::EG::repo::tplRepo
  set savednotes $::EG::repo::doNotes
  set tpl [file join $::EG::DATATPL repo_statistics.html]
  EG::repo::_run $tpl 0 $win yes
  set ::EG::repo::tplRepo $savedtpl
  set ::EG::repo::doNotes $savednotes
  EG::repo::SavePreferences
}
#_______________________

proc stat::Help {} {
  # Shows help on statistics.

  variable win
  EG::Help stat -width 64 -height 32 -parent $win
}
#_______________________

proc stat::Calculate {{dotext yes} {wtmp ""}} {
  # Calculates statistics, showing results in text widget at need.
  #   dotext - yes if show results in text widget
  #   wtmp - temporary (invisible) text widget, for displayTaggedText

  variable date1
  variable date2
  if {!$dotext} {
    set date1sav $date1
    set date2sav $date2
    set date1 ""
    set date2 ""
    SetDates
  }
  StartText $dotext
  StatData
  DoTable1
  DoTable2
  if {!$dotext} {
    set date1 $date1sav
    set date2 $date2sav
  }
  set res [FinishText $dotext $wtmp]
  return $res
}
#_______________________

proc stat::SaveOptions {} {
  # Saves options and dialog's geometry.

  variable win
  variable fontsize
  EG::ResourceData StatGeom [wm geometry $win]
  EG::ResourceData StatFS $fontsize
  EG::SaveDataFile

}
#_______________________

proc stat::OK {} {
  # Handles pressing "Calculate" button.

  Calculate
  SaveOptions
}
#_______________________

proc stat::Cancel {args} {
  # Closes Find dialog.

  variable win
  variable pobj
  $pobj res $win 0
}

# ________________________ GUI _________________________ #

proc stat::_create {} {
  # Creates "Statistics" dialogue.

  variable pobj
  variable win
  variable date1
  variable date2
  variable fontsize
  catch {$pobj destroy}
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra Statistics
  $pobj paveWindow $win.fra {
    {fra1 - - - - {-st nsew -cw 1}}
    {.v_ - - - - {-pady 8}}
    {.lab1 + T 1 1 {-st es} {-t "Current: \[" -anchor e}}
    {.entDat1 + L 1 1 {-st ws -padx 4} {-w 11 -justify center
      -tvar ::EG::stat::date1 -tip "Click to choose a week@@ -under 5"
      -state readonly -takefocus 0 -onevent {<Button> {EG::stat::ChooseWeek date1 %w}}}}
    {.fradat2 + L 1 99 {-st ws -padx 0}}
    {.fradat2.lab1 - - - - {-st ws} {-t to -anchor e}}
    {.fradat2.entDat2 + L 1 1 {-st ws -padx 4} {-w 11 -justify center
      -tvar ::EG::stat::date2 -tip "Click to choose a week@@ -under 5"
      -state readonly -takefocus 0 -onevent {<Button> {EG::stat::ChooseWeek date2 %w}}}}
    {.fradat2.lab2 + L 1 1 {-st ws} {-t \) -anchor e}}
    {.v_2 .lab1 T 1 1 {-pady 8}}
    {.lab3 + T 1 1 {-st es} {-t AggrEG -anchor e}}
    {.TexAggr + L 2 99 {-st nswe} {-w 70 -h 2 -tabnext *.entfs}}
    {.lab4 .lab3 T 1 1 {-st es} {-t formula: -anchor e}}
    {.v_3 + T 1 4 {-pady 8}}
    {.labfs + T 1 1 {-st es} {-t {Font size:}}}
    {.entfs + L 1 1 {-st ws -padx 4} {-w 3 -tvar ::EG::stat::fontsize
      -justify center -tabnext *.butOK}}
    {lfrtex fra1 T 1 5 {-st nsew -cw 1 -rw 1} {-t Results -labelanchor n}}
    {.Text - - - - {pack -side left -expand 1  -fill both}
      {-wrap none -tabnext *.butOK -ro 1 -w 40}}
    {.sbv + L 1 1 {pack -side left -after %w}}
    {.sbh .text T 1 1 {pack -side left -before %w}}
    {seh lfrtex T 1 5 {-pady 8 -st ew -cw 1}}
    {frabot + T 1 5 {-st ew} {}}
    {.ButHelp - - - - {pack -side left}
      {-text Help -com EG::stat::Help -takefocus 0}}
    {.h_ + L 1 1 {pack -side left -expand 1 -fill x}}
    {.ButOK + L 1 1 {pack -side left} {-text Calculate -com EG::stat::OK}}
    {.ButExpo + L 1 1 {pack -side left} {-text Report -state disabled
      -image mnu_print -compound left -com EG::stat::Report}}
    {.butCancel + L 1 1 {pack -side left -padx 4} {-text Cancel
      -com EG::stat::Cancel -tabnext *.texAggr}}
  }
  bind $win <F1> "[$pobj ButHelp] invoke"
  bind $win <F6> "[$pobj ButOK] invoke"
  bind $win <F7> "[$pobj ButExpo] invoke"
  set fontsize [EG::ResourceData StatFS]
  set geo [EG::ResourceData StatGeom]
  AggregateFormula
  $pobj displayTaggedText [$pobj TexAggr] ::EG::D(AggrEG)
  if {$geo ne {}} {set geo "-geometry $geo"}
  after 10 after idle {after 10 after idle {after 10 after idle {
    after 10 after idle EG::stat::OK}}}
  set res [$pobj showModal $win -parent $::EG::WIN -focus [$pobj Text] \
    -minsize {300 300} -onclose EG::stat::Cancel {*}$geo]
  catch {SaveOptions}
  catch {destroy $win}
  catch {$pobj destroy}
}
#_______________________

proc stat::_run {{doit no}} {
  # Runs "Statistics" dialogue.

  if {!$doit} {
    after idle {EG::stat::_run yes}
    return
  }
  EG::SaveAllData
  SetDates
  _create
}
