#! /usr/bin/env tclsh
###########################################################
# Name:    diagr.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Feb 10, 2025
# Brief:   Handles EG diagrams.
# License: MIT.
###########################################################

# ________________________ Common _________________________ #

namespace eval diagr {
  variable C             ;# diagram canvas's path
  variable cumulate      ;# mode "cumulate sums"
  variable byWeek        ;# mode "diagram for weeks (otherwise for days)"
  variable BarHeight 20  ;# height of week bar
  variable BarWidth      ;# width of week bar
  variable MnsHeight 30  ;# height of month bar
  variable BodyHeight    ;# height of diagram body
  variable HotColor      ;# color of layout titles and lines
  variable ColorBg       ;# color of week boxes #1
  variable ColorBg2      ;# color of week boxes #2
  variable ColorBg3      ;# color of week boxes #3
  variable idlist [list] ;# list of canvas item IDs
  variable NWeeks 53     ;# weeks for diagram
  variable x1list [list] ;# list of x-coordinates of weeks
  variable NDays [expr {$NWeeks*7}] ;# days for diagram
  variable Y1     ;# y-coordinate of 1st bar (weeks)
  variable Y2     ;# y-coordinate of 2nd bar (months)
  variable X0 2   ;# margin of diagram
  variable DS     ;# dictionary of item data
  variable TAGS   ;# text tags of items
  variable EOL    ;# eol of item's texts
  variable ydate1 ;# date of 1st week of Preferences' range
  variable ywday1 ;# date of 1st day of the week having ydate1
  variable xPREV  ;# used in DrawColumn
  variable yPREV  ;# used in DrawColumn
  variable DayColWidth 3  ;# width of day column
  variable WeekColWidth [expr {$DayColWidth*7}]  ;# width of week column
  variable UnderLine "\n_______________ \n"
  variable idDayLine {}
  variable WKcolor

}
#_______________________

proc diagr::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    variable C
    variable cumulate
    variable byWeek
    variable BarHeight
    variable BarWidth
    variable MnsHeight
    variable BodyHeight
    variable HotColor
    variable ColorBg
    variable ColorBg2
    variable ColorBg3
    variable idlist
    variable NWeeks
    variable x1list
    variable NDays
    variable Y1
    variable Y2
    variable X0
    variable DS
    variable TAGS
    variable EOL
    variable ydate1
    variable ywday1
    variable xPREV
    variable yPREV
    variable DayColWidth
    variable WeekColWidth
    variable UnderLine
    variable idDayLine
    variable WKcolor
  }
}
#_______________________

proc diagr::initVars {} {
  # Initializes diagr:: variables.

  fetchVars
  update
  set TAGS $::EG::D(TAGS)
  set EOL $::EG::D(EOL)
  set HotColor $::EG::Colors(fghot)
  set ColorBg $::EG::Colors(bg)
  set ColorBg2 $::EG::Colors(bg2)
  set ColorBg3 $::EG::Colors(bg3)
  set C $::EG::C
  set MnsHeight [lindex [[$::EG::EGOBJ EntDate] bbox 0] 3]
  if {$MnsHeight<20} {set MnsHeight 20}
  incr MnsHeight 8
  set cumulate $::EG::cumulate
  set byWeek $::EG::byWeek
  set BarWidth [expr {[ScrollSize w] - 2}]
  set BodyHeight [expr {[ScrollSize h] - $BarHeight - $MnsHeight}]
  set Y1 $BodyHeight
  set Y2 [expr {$Y1 + $BarHeight}]
  set ywday1 [EG::ScanDatePG $::EG::D(egdDate1)]
  set ydate1 [clock add $ywday1 6 days]
  foreach id $idlist {$C delete $id}
  set idlist [list]
  catch {array unset WKcolor}
  array set WKcolor [list]
}

# ________________________ Lay out _________________________ #

proc diagr::Layout {} {
  # Creates weeks/days/months bars

  fetchVars
  set dx [expr {$WeekColWidth/2 + 4}]
  set dy [expr {$Y2 + $MnsHeight/2}]
  set month 0
  set x1list [list]
  for {set iw 0} {$iw < $NWeeks} {incr iw} {
    set x1 [expr {$X0 + $iw*$WeekColWidth}]
    set x2 [expr {$x1 + $WeekColWidth}]
    set weekid [$C create polygon $x1 $Y1 $x2 $Y1 $x2 $Y2 $x1 $Y2 \
      -outline $HotColor -fill $ColorBg2 -tag WK$iw]
    set dt [clock add $ydate1 [expr {$iw*7}] days]
    set day1 [EG::FirstWDay $dt]
    set tip [EG::FormatDate $day1]
    lappend x1list [list $x1 [EG::FormatDatePG $day1] $day1 $tip]
    ::baltip::tip $C $tip -ctag WK$iw
    $C bind $weekid <Button-1> [list EG::MoveToDay $day1]
    lappend idlist $weekid
    set m [clock format $dt -format %N]
    if {$m != $month} {
      lappend idlist [$C create text [expr {$x1 + $dx}] $dy \
        -text [EG::MonthShort $m] -fill $HotColor -font $::apave::FONTMAIN]
      set month $m
    }
  }
  set scw [ScrollSize w]
  set BarWidth [expr {$scw - 2}]
  lappend idlist [$C create polygon $X0 $Y1 $BarWidth $Y1 -outline $HotColor]
  lappend idlist [$C create polygon $X0 $Y2 $BarWidth $Y2 -outline $HotColor]
  if {$cumulate} {
    foreach percent {0.25 0.5 0.75} {
      set y [expr {$percent*$Y1}]
      lappend idlist [$C create polygon 0 $y $scw $y \
        -outline $::EG::Colors(grey) -dash {1 6}]
    }
  }
}
#_______________________

proc diagr::WeekX1 {dt} {
  # Gets week's starting position in diagram layout.
  #   dt - date

  fetchVars
  foreach datex1 [lreverse $x1list] {
    incr i
    lassign $datex1 x1 day1
    if {$dt>=$day1} {return $x1}
  }
  return 0
}
#_______________________

proc diagr::Title {{lab ""}} {
  # Shows diagram label.
  #   lab - label

  if {$lab eq {}} {set lab $::EG::Opcvar}
  set w1 [$::EG::EGOBJ LabTtl]
  set w2 [$::EG::EGOBJ EntTtl]
  if {$lab eq {AggrEG}} {
    if {![winfo ismapped $w2]} {
      pack $w2 -expand 1 -fill x -side left
    }
  } else {
    pack $w1 -expand 1 -side left
    pack forget $w2
  }
  after 200 [list after idle \
    [list $w1 configure -text $lab -foreground $::EG::Colors(fgit)]]
}
#_______________________

proc diagr::DayLine {} {
  # Draws a vertical line of current day.

  fetchVars
  if {[catch {
    set day1 [EG::ScanDatePG $::EG::D(egdDate1)]
    set day2 [EG::ScanDate]
    set dd [expr {($day2 - $day1)/86400}]
    set x [expr {$dd*$DayColWidth + $X0 + $DayColWidth/2 + 1}]
    catch {$C delete $idDayLine}
    set idDayLine [$C create polygon $x 0 $x [expr {$BodyHeight + $BarHeight}]\
      -outline $::EG::Colors(fgsel) -width 2 -dash {2 7}]
  }]} {
    after 200 EG::diagr::DayLine
  }
}

# ________________________ Scroll _________________________ #

proc diagr::ScrollSize {what} {
  # Gets scroll width or height.
  #   what - "w" for width or "h" for height

  fetchVars
  lassign [split [winfo geometry $C] x+] w h
  if {$what eq {w}} {
    set res [expr {$X0*2 + $NWeeks*$WeekColWidth}]
  } else {
    set res $h
  }
  return $res
}
#_______________________

proc diagr::Scroll {to {what units}} {
  # Scrolls canvas left/right.
  #   to - -1 for left, 1 for right

  fetchVars
  catch {$C xview scroll $to $what}
}

# ________________________ Draw _________________________ #

proc diagr::DrawDiagram {item {ispoly 0}} {
  # Draws polygon/histogram for an item.
  #  item - item name
  #  ispoly - true for drawing polygon

  fetchVars
  set maxsum -999999999
  set cumulatedsum 0
  set coldata [list]
  # collect data
  foreach {dk data} $::EG::LS {
    set date [EG::ScanDatePG $dk]
    set x1 [WeekX1 $dk]
    if {$x1==0} {
      puts "EG: $dk date not found. Error of data?"
      continue
    }
    if {!$byWeek} {
      set wday [clock format $date -format %u]
      set x1 [expr {$x1 + $DayColWidth*($wday-1)}]
    }
    lassign [EG::Week1Data $data $item] cnt cnt0 sum color tagcmnt
    lappend coldata [list $x1 $cnt $cnt0 $sum $color $date $tagcmnt]
    if {$cumulate} {
      set cumulatedsum [expr {$cumulatedsum + $sum}]
      set sum $cumulatedsum
    }
    if {$sum > $maxsum} {set maxsum $sum}
  }
  # ready to show data in diagram
  set colWidth [expr {$byWeek ? $WeekColWidth : $DayColWidth}]
  set colorCol [EG::ItemColor $item $ColorBg3]
  set x1prev [set xPREV 0]
  if {$maxsum>0} {
    set itemtype [EG::ItemType $item]
    set cumulatedsum 0
    set cumulatedcnt 0
    foreach data $coldata {
      lassign $data x1 cnt cnt0 sum color day1 tagcmnt
      set iw [expr {$x1/$WeekColWidth}]
      set colorname [EG::ColorName $color]
      if {![info exists WKcolor($iw)] || $WKcolor($iw) eq {} ||
      $colorname eq {Red} || ($colorname eq {Yellow} && $WKcolor($iw) ne {Red})} {
        set WKcolor($iw) $colorname
        set tip [EG::FormatDate $day1]
        if {$tagcmnt ne {}} {append tip [string trimright $UnderLine\n$tagcmnt]}
        lset x1list $iw 3 $tip
        ::baltip::tip $C $tip -ctag WK$iw
      } else {
        set color {}
      }
      if {$cumulate} {
        set cumulatedsum [expr {$cumulatedsum + $sum}]
        incr cumulatedcnt $cnt
        set sum $cumulatedsum
        set cnt $cumulatedcnt
        set emptywidth [expr {$x1 - $x1prev - $colWidth}]
        if {$x1prev && $emptywidth>0} { ;# fill previous empty column(s)
          incr x1prev $colWidth
          if {$item eq {EG}} {
            set color2 $::EG::Colors(fgsel)
          } elseif {$ispoly} {
            set color2 $colorCol
          } else {
            set color2 $ColorBg2
          }
          set tag [DrawColumn $item $iw $x1prev $emptywidth $colHeight \
            $color $color2 $ispoly]
          set moveday [expr {$emptywidth / $colWidth}]
          if {!$ispoly} {
            ::baltip::tip $C {NO DATA} -ctag $tag
            $C bind $tag <Button-1> [list EG::MoveToWeek -$moveday $day1]
          }
        }
        set x1prev $x1
      }
      set colHeight [expr {$BodyHeight * $sum / $maxsum - 1}]
      if {$item eq {EG}} {
        set color2 $::EG::Colors(fgsel)
      } else {
        set color2 $colorCol
      }
      set tag [DrawColumn $item $iw $x1 $colWidth $colHeight \
        $color $color2 $ispoly]
      set tip "[EG::FormatDate $day1]$UnderLine"
      if {$ispoly} {append tip \n\"$item\"}
      append tip "\nSum: [EG::Round $sum 2]\nCells: $cnt"
      ::baltip::tip $C $tip -ctag $tag -per10 4000
      $C bind $tag <Button-1> [list EG::MoveToDay $day1]
    }
  }
}
#_______________________

proc diagr::DrawPolygons {} {
  # Draws polygons for all items.

  set i 0
  foreach item $::EG::D(Items) {
    if {$::EG::D(poly,$i)} {
      DrawDiagram $item 1
      set done 1
    }
    incr i
  }
  if {![info exist done]} {
    EG::Message "No item checked. Check at least one!"
  }
}
#_______________________

proc diagr::DrawColumn {item idx x1 colWidth colHeight color colorCol ispoly} {
  # Draws a column of polygon or histogram.
  #   item - item name
  #   idx - week index
  #   x1 - starting X-coordinate
  #   colWidth - column's width
  #   colHeight - column's height
  #   color - color for week cell
  #   colorCol - color for column
  #   ispoly - true for drawing polygon

  fetchVars
  set colHeight [expr {max(0,$colHeight - 2)}]
  set y2 [expr {$Y1 - $colHeight - 2}]
  set x2 [expr {$x1 + $colWidth}]
  if {$color ne {}} {
    $C itemconfigure WK$idx -fill $color
  }
  set tag WC$x1[EG::NormItem $item]
  if {$ispoly} {
    # polygon
    set x2 [expr {($x1+$x2)/2}]
    set opts [list -outline $colorCol -tag $tag -width 2]
    if {$xPREV} {
      lappend idlist [$C create polygon $xPREV $yPREV $x2 $y2 {*}$opts]
    } else {
      lappend idlist [$C create polygon $x2 $y2 {*}$opts]
    }
    set xPREV $x2
    set yPREV $y2
  } else {
    # histogram
    lappend idlist [$C create polygon $x1 $Y1 $x1 $y2 $x2 $y2 $x2 $Y1 $x1 $Y1 \
      -outline $HotColor -fill $colorCol -tag $tag]
  }
  return $tag
}
#_______________________

proc diagr::DrawWeekNN {} {
  # Draws week numbers.

  fetchVars
  set sh 10
  set y1 [expr {$Y1 + $sh}]
  set fs [dict get $::apave::FONTMAIN -size]
  set font $::apave::FONTMAIN
  lassign [apave::InvertBg $ColorBg2] defcolor
  append font " -size [expr {int($fs/2)}]"
  for {set iw 0} {$iw < $NWeeks} {incr iw} {
    lassign [lindex $x1list $iw] x1 - day1 tip
    set wN [clock format $day1 -format %V]
    incr x1 $sh
    set fcolor $defcolor
    catch {
      if {[set bg $::EG::Colors($WKcolor($iw))] ne {}} {
        lassign [apave::InvertBg $bg] fcolor
      }
    }
    set id [$C create text $x1 $y1 -text $wN -font $font -fill $fcolor -tag WN$iw]
    lappend idlist $id
    $C bind $id <Button-1> [list EG::MoveToDay $day1]
    ::baltip::tip $C $tip -ctag WN$iw
  }
}
#_______________________

proc diagr::Drawing {atStart} {
  # Runs drawing diagram/polygon.
  #   atStart - yes if run at start of EG

  initVars
  fetchVars
  EG::StoreItem
  if {!$atStart} EG::SaveAllData
  Title
  Layout
  EG::AllWeekData
  after idle EG::diagr::DayLine
  $C configure -scrollregion [list 1 1 [ScrollSize w] [ScrollSize h]]
  switch -glob -- $::EG::Opcvar {
    All {
      DrawPolygons
      return 1
    }
    AggrEG {
      EG::stat::AggregateFormula
      set item $::EG::Opcvar
    }
    Totals  {set item {}}
    Polygon {
      DrawPolygons
      return 0
    }
    default {set item $::EG::Opcvar}
  }
  DrawDiagram $item
  if {$atStart} {
    # at start, scroll to current week
    Scroll -8 pages
    set w1 [EG::Oct2Dec [clock format [EG::ScanDatePG $::EG::D(egdDate1)] -format %V]]
    set w2 [EG::Oct2Dec [clock format [EG::ScanDate] -format %V]]
    set curweek [expr {$w2 - $w1 + 1}]
    foreach _ {1 2 3 4} {
      lassign [$C xview] fr1 fr2
      set week2 [expr {$NWeeks*$fr2}]
      if {$curweek > $week2} {
        Scroll 1 pages
      } else {
        break
      }
    }
  }
  return 1
}
#_______________________

proc diagr::Draw {{atStart no}} {
  # Draws diagram/polygon.
  #   atStart - yes if run at start of EG

  set res [Drawing $atStart]
  DrawWeekNN
  return $res
}
