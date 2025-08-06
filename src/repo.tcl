###########################################################
# Name:    repo.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jan 20, 2025
# Brief:   Handles reports of EG app.
# License: MIT.
###########################################################

# _________________________ repo ________________________ #

namespace eval repo {
  variable pobj ::repo::pavedObj
  variable win $::EG::WIN.repo
  variable jsRepo {prntdir = '../../';}
  variable tplRepo [file join $::EG::DATATPL repo.html]
  variable outRepo [file join $::EG::USERDIR EGrepo.html]
  variable cssRepo {../../zoo/style.css}
  variable icoRepo {../../../zoo/favicon.jpg}
  variable file1Repo {../../../zoo/funcs.js}
  variable file2Repo {../../zoo/this.js}
  variable diagrRepo {}
  variable headRepo {}
  variable blackComment {}
  variable redComment {}
  variable Year {}
  variable fieldVars {jsRepo cssRepo icoRepo file1Repo file2Repo \
    headRepo blackComment redComment Year doDiagr doNotes}
  variable settingVars [list tplRepo outRepo {*}$fieldVars]
  variable settingsKey RepoPreferences
  variable Html
  variable Table
  variable Month
  variable Week
  variable Item
  variable idxAEG
  variable prevAEG
  variable RedColor #be0000
  variable YellowColor #6b6b00
  variable GreenColor #115111
  variable doDiagr 1 doNotes 1
}

# ________________________ Common _________________________ #

proc repo::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    variable win
    variable pobj
    variable jsRepo
    variable tplRepo
    variable outRepo
    variable cssRepo
    variable icoRepo
    variable file1Repo
    variable file2Repo
    variable diagrRepo
    variable headRepo
    variable blackComment
    variable redComment
    variable Year
    variable fieldVars
    variable settingVars
    variable settingsKey
    variable Html
    variable Table
    variable Month
    variable Week
    variable Item
    variable idxAEG
    variable prevAEG
    variable RedColor
    variable YellowColor
    variable GreenColor
    variable doDiagr
    variable doNotes
  }
}

#_______________________

proc repo::ReadPreferences {} {
  # Reads stand-alone fields from .rc file.

  fetchVars
  if {[llength [set values [EG::ResourceData $settingsKey]]]} {
    lassign $values {*}$settingVars
    foreach sv $settingVars {
      set $sv [EG::fromEOL [set $sv]]
    }
  }
  set Year [file root [file tail $::EG::D(FILE)]]
  set doDiagr [string is true $doDiagr]
  set doNotes [string is true $doNotes]
}
#_______________________

proc repo::SavePreferences {} {
  # Saves stand-alone fields to .rc file.

  fetchVars
  foreach {var tex} {jsRepo TexJS blackComment TexBlack redComment TexRed} {
    catch {set $var [string trimright [[$pobj $tex] get 1.0 end]]}
  }
  foreach fld $settingVars {
    lappend fieldValues [EG::toEOL [set $fld]]
  }
  EG::ResourceData $settingsKey {*}$fieldValues
}
#_______________________

#% doctest TagInfo
#< namespace eval repo {} ;# for doctest

proc repo::TagInfo {tag tplcont} {
  # Get tag's information in template.
  #   tag - tag name
  #   tplcont - template contents
  # Returns a list of sequential "pos1 pos2 contents": starting position,
  # ending position (i.e. range of the tag) and contents between these
  # positions in template. In template, tags are single {tag+-} or double
  # {tag+}...{tag-}. Example in doctest below.

  set res [list]
  set pos0 0
  set tag0 "{$tag+-}"
  set tag1 "{$tag+}"
  set tag2 "{$tag-}"
  set len0 [string length $tag0]
  set len1 [string length $tag1]
  set len2 [string length $tag2]
  while {1} {
    if {$tag0 ne {}} {
      # first, find all single tags {tag+-}
      set pos1 [string first $tag0 $tplcont $pos0]
      if {$pos1>-1} {
        set pos2 [expr {$pos1+$len0-1}]
        set cont {}
      } else {
        set tag0 {}
        set pos0 0
        continue
      }
    } else {
      # then find double tags {tag+}...{tag-}
      set pos1 [string first $tag1 $tplcont $pos0]
      set pos2 [string first $tag2 $tplcont $pos0]
      if {$pos1<0 || $pos1>$pos2} break
      set cont [string range $tplcont $pos1+$len1 $pos2-1]
      set pos2 [expr {$pos2+$len2-1}]
    }
    set pos0 $pos2
    lappend res $pos1 $pos2 $cont
  }
  return $res
}
#< set tpl {012 {nam+}cont end!!!{nam-}..{nam+-}..{nam+}second cont{nam-}?{nam+-}?}
#< puts $tpl
#< puts 0123456789012345678901234567890123456789012345678901234567890123456789

#% repo::TagInfo nam $tpl
#> 29 35 {} 62 68 {} 4 26 {cont end!!!} 38 60 {second cont}
#> doctest

#_______________________

#% doctest RelativePath
#< namespace eval repo {} ;# for doctest

proc repo::RelativePath {path1 path2} {
  # Gets a relative path of file.
  #   path1 - path of file which refers to *path2*
  #   path2 - full path (it has to be used in *path1* as relative)
  # Examples in doctests below.

  set res $path2
  set lpor1 [file split $path1]
  set lpor2 [file split $path2]
  set l1 [llength $lpor1]
  set l2 [llength $lpor2]
  if {$l2>1} {
    foreach por1 $lpor1 por2 $lpor2 {
      incr k
      if {$por1 ne $por2 || $k==$l2} {
        if {$l1<$l2} {
          set prev [expr {$k>1 ? 1 : 0}]
          set next [expr {$l2 - $l1}]
          set udir [string repeat . $prev]
          set res [file join {*}$udir {*}[lrange $lpor2 end-$next end]]
        } elseif {$k>2} {
          set prev [expr {$l1 - $k}]
          set next [expr {abs($prev ? $prev + $l2 - $l1 : 0)}]
          set udir [split [string repeat ../ $prev] /]
          set res [file join {*}$udir {*}[lrange $lpor2 end-$next end]]
        }
        break
      }
    }
  }
  return $res
}

#% repo::RelativePath \
/home/apl/PG/github/io/en/tcl/alited/index.html \
/home/apl/PG/github/io/zoo/funcs.js
#> ../../../zoo/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/io/en/tcl/index.html \
/home/apl/PG/github/io/zoo/funcs.js
#> ../../zoo/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/io/en/index.html \
/home/apl/PG/github/io/zoo/funcs.js
#> ../zoo/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/io/en/index.html \
/home/apl/PG/github/io/funcs.js
#> ../funcs.js

#% repo::RelativePath \
/home/apl/PG/github/io/index.html \
/home/apl/PG/github/io/funcs.js
#> funcs.js

#% repo::RelativePath \
/home/apl/PG/github/index.html \
/home/apl/PG/github/io/funcs.js
#> ./io/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/index.html \
/home/apl/PG/github/io/en/funcs.js
#> ./io/en/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/index.html \
/home/apl/PG/github/io/en/zoo/funcs.js
#> ./io/en/zoo/funcs.js

#% repo::RelativePath \
/home/apl/PG/github/index.html \
funcs.js
#> funcs.js

#% repo::RelativePath \
/home/apl/PG/github/index.html \
/usr/bin/tclsh
#> /usr/bin/tclsh

#% repo::RelativePath \
/home/apl/PG/github/index.html \
{}
#>

#% repo::RelativePath \
index.html \
funcs.js
#> funcs.js

#% repo::RelativePath \
/home/apl/PG/github/expagog/.bak/egd/EGrepo.html \
/home/apl/PG/github/aplsimple.github.io/ru/zoo/style.css
#> ../../../aplsimple.github.io/ru/zoo/style.css

#> doctest

#_______________________

proc repo::TextContent {val} {
  # Gets text content keeping linefeeds and left spaces.
  #   val - text

  set val [EG::fromEOL $val]
  set mlist [list]
  string map [list \n <br>] [string trim $val]
}
#_______________________

proc repo::Message {msg {wait 0}} {
  # Shows message.
  #   msg - message
  #   wait - waiting pause in seconds

  fetchVars
  set lab [$pobj LaBMess]
  $lab configure -foreground $::EG::Colors(fghot) -font {-weight bold}
  EG::Message $msg $wait $lab
}
#_______________________

proc repo::InitialDir {var} {
  # Gets -initialdir option of file dialog.
  #   var - variable of chosen file path
  # The result is taken from *outRepo* variable by trimming ../ parts of $var.

  set res [file dirname $::EG::repo::outRepo]
  catch {
    set res2 [file dirname [set ::EG::repo::$var]]
    set dir1 [file split $res]
    set dir2 [file split $res2]
    foreach d1 $dir1 d2 $dir2 {
      if {$d2 eq {..}} {
        incr iup
      } else {
        if {[info exists iup]} {
          set res [lrange $dir1 0 end-$iup]
          lappend res {*}[lrange $dir2 $iup end]
          set res [file join {*}$res]
        }
        break
      }
    }
  }
  return $res
}
#_______________________

proc repo::CheckNotes {} {
  # Enables/disables "notes" fields depending on doNotes value.

  fetchVars
  if {$doNotes} {set st normal} {set st disabled}
  foreach fld {TexBlack TexRed} {
    [$pobj $fld] configure -state $st
  }
  $pobj themeNonThemed $win
}

# ________________________ Processing data _________________________ #

proc repo::PutValue {tplcont args} {
  # Puts stand-alone filed values to template.
  #   tplcont - template contents
  #   args - list of pairs "tag value"

  foreach {tag value} $args {
    lappend pairs "{$tag+-}" $value
  }
  string map $pairs $tplcont
}
#_______________________

proc repo::PutRange {tplcont tag value} {
  # Puts a range to template.
  #   tplcont - template contents
  #   tag - tag of value
  #   value - value

  lassign [TagInfo $tag $tplcont] pos1 pos2
  if {[catch {set res [string replace $tplcont $pos1 $pos2 $value]}]} {
    set res $tplcont
  }
  return $res
}
#_______________________

proc repo::PutItemData {date1 tplweek itemdata} {
  # Puts item data to week template.
  #   date1 - date of week
  #   tplweek - week template
  #   itemdata - item data

  fetchVars
  if {$tplweek eq {} || ![llength $itemdata]} {return $tplweek}
  set dt1 [EG::ScanDatePG $date1]
  set outitems [set textval {}]
  set lsttext [list]
  set end 9999
  lassign $::EG::D(WeeklyITEM) weeklyItem
  set weekly {}
  foreach item $::EG::D(Items) itemtype $::EG::D(ItemsTypes) {
    set tplitem [PutValue $Item ItemName [incr itIdx].\ <b>$item</b>]
    foreach data $itemdata {
      lassign $data it valdata  ;# e.g. {Dist {v2 9} Time {v2 0:50}}
      if {$it ne $item} {
        if {$it eq $weeklyItem} {set weekly $valdata}
        continue
      }
      foreach {key val} $valdata {
        lassign [split $key {}] k d  ;# v1 => v 1
        switch $k {
          t {
            if {[string match $::EG::D(TAGS)* $val]} {
              set i1 [string length $::EG::D(TAGS)]
              set i2 [string first $::EG::D(EOL) $val]
              if {$i2<0} {set i2 [string first \n $val]}
              if {$i2<0} {set i2 $end}
              set tags [string range $val $i1 $i2-1]
              set ltags [split $tags]
              set rtags [string range $val $i2 $end]
              foreach {cnam cval} "Red $RedColor Yellow $YellowColor Green $GreenColor" {
                if {$cnam in $ltags} {
                  set font "<font color=$cval>"
                  set val $font$::EG::D(TAGS)$tags$rtags</font>
                  break
                }
              }
            }
            lappend lsttext $d $item $val
          }
          v {
            # fill a cell for item and week day
            set val [string map {ques ?} $val]
            if {$itemtype eq {chk} && $val ne {?}} {
              set val [EG::ButtonValue $val]
            }
            if {$item eq {EG}} {set val <b>$val</b>}
            set tplitem [PutValue $tplitem ItemD$d $val]
          }
        }
      }
    }
    foreach d {0 1 2 3 4 5 6} {
      # clear cells which are not filled
      set tplitem [PutValue $tplitem ItemD$d {}]
    }
    append outitems \n $tplitem
  }
  set curdd {}
  set lsttext [lsort -stride 3 $lsttext]
  foreach {dd item val} $lsttext {
    if {$dd ne $curdd} {
      set dat [EG::FormatDateUser [clock add $dt1 $dd days]]
      append textval "\n\n<b>$dat</b>"
    }
    set lp [string length $item]
    set pad [string repeat "&nbsp;" [incr lp 3]]
    set val [string map [list \n \n$pad] $val]
    set val [string map [list $::EG::D(EOL) \n$pad] $val]
    append textval "\n <i>$item</i>: $val"
    set curdd $dd
  }
  set outweek [PutRange $tplweek Item $outitems]
  set outweek [PutValue $outweek CommItem [TextContent $textval]]
  set aeg [EG::GetAggrEG $date1]
  set font {font size=3}
  if {$idxAEG && $aeg!=0 && $prevAEG!=0} {
    set diff [expr {($aeg - $prevAEG) / $aeg}]
    if {abs($diff)>$::EG::stat::maxdiff} {
      if {$aeg > $prevAEG} {
        append font " color=$GreenColor"
      } else {
        append font " color=$RedColor"
      }
    }
  }
  set prevAEG $aeg
  incr idxAEG
  set aeg <$font>$aeg</font>
  if {[set weeklyKeyVal $weekly] ne {}} {
    if {$textval eq {}} {set weekly {}} {set weekly \n<hr>}
    append weekly [EG::fromEOL [lindex $weeklyKeyVal 1]]
  }
  set outweek [PutValue $outweek Weekly $weekly]
  set outweek [PutValue $outweek AggrEGvalue $aeg]
  set outweek [PutValue $outweek AggrEGformula [EG::stat::AggregateFormula]]
  return $outweek
}
#_______________________

proc repo::FillTable {} {

  fetchVars
  EG::AllWeekData
  set idxAEG [set prevAEG 0]
  lassign {} outtable currweek currmonth outmonth outweek itemdata date1 date2
  EG::ForEach {} [EG::DatesKeys] {
    set dt [EG::ScanDatePG %d]
    set y [clock format $dt -format %%Y]
    set d [clock format $dt -format %%d]
    set m [clock format $dt -format %%N]
    set w [clock format $dt -format %%V]
    set month [EG::MonthFull $m]\ $y
    set date1 %d
    if {$currweek ne $w} {
      if {$date2 ne {}} {
        set outweek [PutItemData $date2 $outweek $itemdata]
        append outtable \n $outweek
      }
      set currweek $w
      set outweek [PutValue $Week WeekN $currweek]
      set outweek [PutValue $outweek WeekDate1 [EG::FormatDateUser $dt]]
      foreach wday {0 1 2 3 4 5 6} {
        set wval [EG::FormatDateUser [clock add $dt $wday days]]
        set outweek [PutValue $outweek WD$wday $wval]
      }
      set itemdata [list]
    }
    if {$currmonth ne $month} {
      set currmonth $month
      set outmonth [PutValue $Month MonthFull $currmonth]
      append outtable \n $outmonth
    }
    lappend itemdata [list %i %V]
    set date2 $date1
  }
  if {$date2 ne {}} {
    set outweek [PutItemData $date2 $outweek $itemdata]
  }
  append outtable \n $outweek
  set Html [PutRange $Html Table $outtable]
}
#_______________________

proc repo::FillFields {} {
  # Fills stand-alone fields in report.

  fetchVars
  foreach fld $fieldVars {
    if {$fld ni {blackComment redComment} || $doNotes} {
      set val [TextContent [set $fld]]
    } else {
      set val {}
    }
    lappend pairs $fld $val
  }
  if {[winfo exists $::EG::stat::win]} {
    # run from Statistics dialogue -> rebuild statistics of its week range
    lappend pairs statRepo [EG::stat::Calculate]
  } else {
    # run from Report dialogue by itself -> build statistics of current week
    set wtmp [$pobj TexTmp]
    $wtmp replace 1.0 end {}
    lappend pairs statRepo [EG::stat::Calculate no $wtmp]
  }
  set Notes {}
  if {$doNotes} {
    foreach n $::EG::NOTESN {
      if {[set note [EG::note::OpenNoteText $n]] ne {}} {
        append Notes <p><b>[EG::note::NoteName $n]</b><br>$note</p>
      }
    }
  }
  lappend pairs Notes $Notes
  if {$doDiagr} {
    set diagram "<br><br><img src=\"$diagrRepo\"><br><br><br>"
  } else {
    set diagram {}
  }
  lappend pairs Diagram $diagram
  set Html [PutValue $Html {*}$pairs]
}

# ________________________ Actions _________________________ #

proc repo::Report {} {
  # Outputs text to html.

  fetchVars
  set tplRepo [file normalize $tplRepo]
  set outRepo  [file normalize $outRepo]
  if {$tplRepo eq $outRepo} {
    return
  }
  Message "Making report... Wait please." 10
  set diagrRepo [file rootname $outRepo].png
  if {$doDiagr} {
    catch {
      # save the diagram to a file, to show it in the report
      EG::diagr::Draw
      set img [canvas::snap $::EG::C]
      $img write $diagrRepo
      set diagrRepo [file tail $diagrRepo]
      EG::diagr::Draw yes ;# the diagram is scrolled by canvas::snap
    }
  }
  foreach fn {cssRepo icoRepo file1Repo file2Repo} {
    set fname [set $fn]
    if {[string first .. $fname]!=0} {
      set fname [file normalize $fname]
      set $fn [RelativePath $outRepo $fname]
    }
  }
  EG::CheckAggrEG
  SavePreferences
  set Html [apave::readTextFile $tplRepo]
  if {$Html eq {}} {
    bell
    Message "Error of $tplRepo"
    return
  }
  lassign [TagInfo Table $Html] - - Table
  lassign [TagInfo Month $Table] - - Month
  lassign [TagInfo Week $Table] - - Week
  lassign [TagInfo Item $Week] - - Item
  FillTable
  FillFields
  apave::writeTextFile $outRepo ::EG::repo::Html
  openDoc $outRepo
}
#_______________________

proc repo::Help {} {
  # Shows help on report.

  fetchVars
  EG::Help repo -width 59 -height 32 -parent $win
}
#_______________________

proc repo::Cancel {args} {
  # Closes the dialog.

  fetchVars
  $pobj res $win 0
}

# ________________________ GUI _________________________ #

proc repo::_create {parent} {
  # Creates "Report" dialogue.
  #   parent - parent window's path

  fetchVars
  catch {$pobj destroy}
  if {[catch {package require canvas::snap}]} {
    set diagrst disabled
    set doDiagr 0
  } else {
    set diagrst normal
  }
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra Report
  $pobj paveWindow $win.fra {
    {fra1 - - - - {-st nsew}}
    {.v_ - - - - {-pady 8}}
    {.lab0 + T 1 1 {-st es -cw 1 -padx 4} {-t {From template file:} -anchor e}}
    {.FilIn + L 1 1 {-st swe} {-w 63 -tvar ::EG::repo::tplRepo
      -tip "expagog/data/tpl/repo.html\nby default"}}
    {.lab1 .lab0 T 1 1 {-st es -padx 4} {-t {To resulting .html:} -anchor e}}
    {.fisOut + L 1 1 {-st swe} {-w 63 -tvar ::EG::repo::outRepo}}
    {.v_1 .lab1 T 1 1 {-pady 8}}
    {.lab2 + T 1 1 {-st en} {-t {Include diagram:} -anchor e}}
    {.chbDiagr + L 2 99 {-st nw} {-var ::EG::repo::doDiagr -state $diagrst}}
    {.v_2 .lab2 T 1 1 {-pady 8}}
    {.lab3 + T 1 1 {-st es -padx 4} {-t {Css file:} -anchor e}}
    {.filCss + L 1 1 {-st swe} {-w 63 -tvar ::EG::repo::cssRepo
      -initialdir {::EG::repo::InitialDir cssRepo}}}
    {.lab4 .lab3 T 1 1 {-st es -padx 4} {-t {Icon file:} -anchor e}}
    {.filIco + L 1 1 {-st swe} {-w 63 -tvar ::EG::repo::icoRepo
      -initialdir {::EG::repo::InitialDir icoRepo}}}
    {.v_3 .lab4 T 1 1 {-pady 8}}
    {lfr + T 1 2 {-st nswe} {-t Optional}}
    {.lab5 + T 1 1 {-st es -padx 4} {-t {1st .js file:} -anchor e}}
    {.filJS1 + L 1 1 {-st swe} {-w 70 -tvar ::EG::repo::file1Repo
      -initialdir {::EG::repo::InitialDir file1Repo}}}
    {.lab6 .lab5 T 1 1 {-st es -padx 4} {-t {2nd .js file:} -anchor e}}
    {.filJS2 + L 1 1 {-st swe} {-w 70 -tvar ::EG::repo::file2Repo
      -initialdir {::EG::repo::InitialDir file2Repo}}}
    {.v_4 .lab6 T 1 1 {-pady 8}}
    {.lab7 + T 1 1 {-st en} {-t {JS code:} -anchor e}}
    {.TexJS + L 2 99 {-st nswe} {-w 70 -h 4 -tabnext *.entHead}}
    {lfr2 lfr T 1 2 {-st nswe} {-t Heading}}
    {.lab - - - - {-st en -padx 4} {-t Title: -anchor e}}
    {.entHead + L 1 1 {-st swe} {-w 74 -tvar ::EG::repo::headRepo}}
    {.lab1 .lab T 1 1 {-st en} {-t {Include notes:} -anchor e}}
    {.chbNotes + L 1 1 {-st nw} {-var ::EG::repo::doNotes -com EG::repo::CheckNotes}}
    {.lab2 .lab1 T 1 1 {-st en -padx 4} {-t {Normal note:} -anchor e}}
    {.TexBlack + L 2 99 {-st nswe} {-w 74 -h 4 -tabnext *.texRed}}
    {.v_4 .lab2 T 1 1 {-pady 8}}
    {.lab3 + T 1 1 {-st en} {-t {Red note:} -anchor e}}
    {.TexRed + L 2 99 {-st nswe} {-w 74 -h 4 -tabnext *.butExpo}}
    {seh lfr2 T 1 2 {-pady 8 -st ew}}
    {frabot + T 1 2 {-st ew} {}}
    {.TexTmp - - - - {pack forget -side left}}
    {.ButHelp - - - - {pack -side left}
      {-text Help -com EG::repo::Help -takefocus 0}}
    {.LaBMess + L 1 1 {pack -side left -expand 1 -fill x}}
    {.ButExpo + L 1 1 {pack -side left} {-text Report
      -image mnu_print -compound left -com EG::repo::Report}}
    {.butCancel + L 1 1 {pack -side left -padx 4} {-text Cancel -com EG::repo::Cancel}}
  }
  CheckNotes
  bind $win <F1> "[$pobj ButHelp] invoke"
  bind $win <F7> "[$pobj ButExpo] invoke"
  $pobj displayTaggedText [$pobj TexJS] jsRepo
  $pobj displayTaggedText [$pobj TexBlack] blackComment
  $pobj displayTaggedText [$pobj TexRed] redComment
  set res [$pobj showModal $win -parent $parent -resizable 0 \
     -focus [$pobj chooserPath FilIn] -onclose EG::repo::Cancel]
  catch {destroy $win}
  catch {$pobj destroy}
}
#_______________________

proc repo::_run {{tplrepo ""} {donotes -1} {parent ""} {doit no}} {
  # Runs "Report" dialogue.
  #   tplrepo - if not "", defines tplRepo's value
  #   donotes - if not -1, defines doNotes's value
  #   parent - parent window's path
  #   doit - if no, restarts after idle

  fetchVars
  if {!$doit} {
    after idle [list EG::repo::_run $tplrepo $donotes $parent yes]
    return
  }
  EG::SaveAllData
  ReadPreferences
  if {$tplrepo ne {}} {set tplRepo $tplrepo}
  if {$donotes != -1} {set doNotes $donotes}
  if {$parent eq {}} {set parent $::EG::WIN}
  _create $parent
}
