#! /usr/bin/env tclsh
###########################################################
# Name:    EG.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jan 02, 2025
# Brief:   Handles experimenta-gogical main script.
# License: MIT.
###########################################################

package require Tk
wm withdraw .

# ______________________ Remove installed (perhaps) packages ____________________ #

foreach _ {apave baltip bartabs hl_tcl} {
  set __ [package versions $_]
  catch {
    package forget $_
    namespace delete ::$_
    puts "alited: clearing $_ $__"
  }
  unset __
}

# ________________________ EG _________________________ #

namespace eval EG {

  variable VERSION {}
  variable EGICON \
{iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAMAAABiM0N1AAAABlBMVEUUqHtCxf8p2J+gAAAAAnRS
TlMA/1uRIrUAAAD7SURBVFjD3dhLEoQgDATQ7vtfejaz0IGEdGhKa7LzU09LAyEA/xiky6GJMUD8
hkfZc3gNC9KGOAkLojsMw4IoEOlwuA4TU4HocUgLRHogk0N6oCccNhx4PjM86fN7ujsowtPq/Nf4
1Oec5tR4ylmkZxlaZHnVQduB5PC8A5cDgbE5NWjTwdscuBy4HOSOuJZKi4jobK/w1k4ZMq04c+eZ
dXRUjAzdwbGGZ7g4v3f5IsNTmEPlRi94slIcsgayWGWiI6nNLUHCpF6CIEMc39MB1Wf14WiWoEQD
um2x6A3TPI+k8jDLSHWjhMEYUf58Nmp1p1xhX7EjlYxiNT517QfiEN3VuQAAAABJRU5ErkJggg==}

  proc readPolyFlags {} {
    # Fills polygon flags from saved ones.

    variable D
    set i 0
    foreach flag [split $D(poly) {}] {
      set D(poly,$i) $flag
      incr i
    }
  }
  #_______________________

  proc savePolyFlags {} {
    # Fills saved flags from polygon ones.

    variable D
    for {set i 0; set D(poly) {}} {$i<$D(MAXITEMS)} {incr i} {
      append D(poly) $D(poly,$i)
    }
  }

  ## __________________ Main constants __________________ ##

  variable TITLE expagog
  variable WIN .eg
  variable EGOBJ ::EG::mainobj
  variable ICONTYPE middle
  variable COMMONTYPE _EG_
  variable ITWIDTH 4
  variable NOTESN [list 1 2 3 4 5 6 7 8]
  variable MONTHSHORT [list Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
  variable MONTHSFULL [list January February March April May June July August\
    September October November December]
  variable EMPTY ?
  variable YESVAL 2
  variable LAMPVAL 1
  variable NOVAL -1
  variable QUESVAL 0
  variable TAGOPCLEN 16
  variable NAMEWIDTH 15

  variable Colors;  ;# item colors
  array set Colors [list pending #ffff00 failed #ff0000 done #80ff80 \
    my1 #804000 my2 #800080 my3 #004080 my4  #008080 my5  #296929 my6  #808000 \
    my7 #ffa9ff my8 #ffff7f my9 #8dff8d my10 #8bffff my11 #a5a5ff my12 #aaaaaa \
    my13 #474700 my14 #004000 my15 #4b0b00 my16 #0000ff]
  set Colors(fgsel) #ff4b4b  ;# fg of selection
  set Colors(bgtex) #1b5b9b  ;# bg of item with text
  set Colors(Red) #ff0000    ;# Red tag color
  set Colors(Yellow) #ffff00 ;# Yellow tag color
  set Colors(Green) #008000  ;# Green tag color

  variable D; array set D {}
  set D(Items)      {Dist Time Speed Math DEF Eco R}
  set D(ItemsTypes) [list 999.99 time {calc:99.99:$1/$2} time time chk chk]
  set D(Icons) {hamburger previous previous2 next next2 date home exit
    SaveFile info lock find print}
  set D(DateUser) "%e %b %Y" ;# date format for head date
  set D(DateUser2) "%e %b"   ;# date format for status bar
  set D(DateUser3) "%e %B, %A"   ;# date format for text title
  set D(DatePG) %Y/%m/%d  ;# internal date format
  set D(Theme) darkbrown  ;# used theme
  set D(CS) 29       ;# used color scheme
  set D(Hue) 0       ;# used hue
  set D(MAXITEMS) 16 ;# maximum of items
  set D(EOL) {@~}    ;# end-of-line
  set D(TAGS) TAGS:  ;# tags' prompt
  set D(FILEBAK) {}  ;# backup file
  set D(AUTOBAK) 0   ;# auto-backup flag
  set D(WeeklyITEM) {_TI_ 0} ;# item name & day for weekly text
  set D(WeeklyKEY) W ;# key for weekly text

  ## ________________________ Main variables ______________________ ##

  variable EGD; set EGD [dict create] ;# EG data of current week
  set D(Zoom) 3       ;# "zoom" (affects font size)
  set D(MsgFont) {}   ;# font of messages
  set D(TextTags) {}  ;# text tags
  set D(Date1) {}     ;# current date (of EG main window)
  set D(egdDate1) {}  ;# Date1 (included) of current .egd data
  set D(egdDate2) {}  ;# Date2 (excluded) of current .egd data
  set D(previtem) ""  ;# previous choosen item
  set D(curritem) ""  ;# current choosen item
  set D(currwday) ""  ;# current week day
  set D(WeekDays) {}  ;# week day names
  set D(poly) 1[string repeat 0 $D(MAXITEMS)] ;# saved flags of polygons
  readPolyFlags
  set D(NoteOnTop) 0  ;# yes for notes to be topmost
  set D(DefFont) {}   ;# default font
  set D(TexFont) {}   ;# text font
  set D(TabFiles) {}  ;# file names of tab bar
  set D(AggrEG) EG    ;# aggregate formula
  set D(FindStrs) {}  ;# list of strings to find
  variable C          ;# canvas' path
  variable Opcvar     ;# option cascade var
  variable OpcItems   ;# option cascade list
  variable byWeek 1   ;# diagram for weeks
  variable cumulate 0 ;# cumulative diagram
  variable LS         ;# list of item data
  variable itwidth 0  ;# item width
  variable InpItem {} ;# input item to go to
  variable InpDate {} ;# input date to go to
  variable TestMode 0 ;# allows no changes to data

  ## ________________________ Pathes ________________________ ##

  variable SCRIPT [info script]
  variable SCRIPTNORMAL [file normalize $SCRIPT]
  variable SCRDIR [file dirname $SCRIPTNORMAL]
  variable DIR [file dirname $SCRDIR]
  variable LIBDIR [file join $DIR lib]
  variable DATADIR [file join $DIR data]
  variable DATATPL [file join $DATADIR tpl]
  variable PAVEDIR [file join $LIBDIR apave]

  variable HOMEDIR ~
  if {[catch {set HOMEDIR [file home]}] && [info exists ::env(HOME)]} {
    set HOMEDIR $::env(HOME)
  }

  variable USERDIR [file join $HOMEDIR .config]
  if {![file exists $USERDIR] && \
  ($::tcl_platform(platform) eq {windows} || [info exists ::env(LOCALAPPDATA)])} {
    if {[info exists ::env(LOCALAPPDATA)]} {
      set USERDIR $::env(LOCALAPPDATA)
    } else {
      set USERDIR [file join $HOMEDIR AppData Local]
    }
  }
  set USERDIR [file join $USERDIR $TITLE egd]
  if {![file exists $USERDIR]} {file mkdir $USERDIR}
  variable USERDIRPG $USERDIR
  variable USERFILEPG {}
}

# _____________________ Source & import ______________________ #

source [file join $::EG::PAVEDIR apave.tcl]
source [file join $::EG::LIBDIR bartabs bartabs.tcl]
namespace import ::apave::*
apave::initStyles
namespace eval EG {
  source [file join $::EG::SCRDIR note.tcl]
  source [file join $::EG::SCRDIR stat.tcl]
  source [file join $::EG::SCRDIR diagr.tcl]
}

#_______________________

proc EG::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    variable VERSION
    variable TITLE
    variable WIN
    variable EGOBJ
    variable EGD
    variable ICONTYPE
    variable COMMONTYPE
    variable ITWIDTH
    variable EMPTY
    variable Colors
    variable C
    variable D
    variable Opcvar
    variable OpcItems
    variable byWeek
    variable cumulate
    variable TAGOPCLEN
    variable LS
    variable SCRIPT
    variable SCRIPTNORMAL
    variable SCRDIR
    variable DIR
    variable LIBDIR
    variable DATADIR
    variable USERDIR
    variable USERDIRPG
    variable USERFILEPG
    variable PAVEDIR
    variable NOTESN
    variable FILEBAK
    variable AUTOBAK
    variable itwidth
    variable TestMode
    variable InpItem
    variable InpDate
  }
}
#_______________________

proc EG::Source {scriptname} {
  # Sources a Tcl script.
  #   scriptname - script name

  fetchVars
  if {![namespace exists $scriptname]} {
    source [file join $SCRDIR $scriptname.tcl]
  }
}

# ________________________ Common procs _________________________ #

proc EG::TimeValue {tm} {
  # Converts time to decimal.
  #  tm - time value (of format hh:mm or hh.mm)

  if {[catch {
    lassign [split $tm :] hh mm
    if {$mm eq {}} {
      set res [expr {int($hh) + ($hh - int($hh))*10./6.}]
    } else {
      set res [expr $hh. + $mm./60.]  ;# octals may mix it up
    }
  }]} then {
    set res 0.0
  }
  return $res
}
#_______________________

proc EG::ButtonValue {icon} {
  # Gets decimal value ("weight") of button "chk" item.
  #   icon - name of icon

  switch $icon {
    Y - yes  {set val $::EG::YESVAL}
    N - no   {set val $::EG::NOVAL}
    L - lamp {set val $::EG::LAMPVAL}
    default  {set val $::EG::QUESVAL}
  }
  return $val
}
#_______________________

proc EG::Round {value digits} {
  # Rounds *value* to *digits* after point.

  set mult [expr {10.0**$digits}]
  expr {int($value*$mult+0.5)/$mult}
}
#_______________________

proc EG::TimeSym {tm} {
  # Converts time to symbolic hh:mm.
  #  tm - decimal time value

  lassign [split $tm .] hh mm
  set mm [string range ${mm}00 0 1]
  if {[catch {set mm [expr $mm.*60./100.]}]} {set mm 0}
  set mm [string range 00[expr {round($mm)}] end-1 end]
  return $hh:$mm
}
#_______________________

proc EG::NormItem {item} {
  # Normalizes item name, making it fit for widgets.
  #   item - item name

  string map {{ } {} . {}} [apave::NormalizeFileName $item]
}
#_______________________

proc EG::FormatDate {{dt ""}} {
  # Formats date.
  #   dt - clock time

  fetchVars
  if {$dt eq {}} {set dt [Date1Seconds]}
  string trim [clock format $dt -format $D(DateUser)]
}
#_______________________

proc EG::FormatDatePG {{dt ""}} {
  # Formats date to internal form.
  #   dt - clock time

  fetchVars
  if {$dt eq {}} {set dt [Date1Seconds]}
  clock format $dt -format $D(DatePG)
}
#_______________________

proc EG::FormatDateUser {{dt ""}} {
  # Formats date to user's form.
  #   dt - clock time

  fetchVars
  if {$dt eq {}} {set dt [Date1Seconds]}
  string trim [clock format $dt -format $D(DateUser2)]
}
#_______________________

proc EG::ScanDate {{dt ""}} {
  # Gets date in seconds from user format date.
  #   dt - user format date

  fetchVars
  if {$dt eq {}} {set dt $D(Date1)}
  clock scan $dt -format $D(DateUser)
}
#_______________________

proc EG::ScanDatePG {{dt ""}} {
  # Gets date in seconds from internal format date.
  #   dt - internal format date

  fetchVars
  if {$dt eq {}} {return [ScanDate]}
  clock scan $dt -format $D(DatePG)
}
#_______________________

proc EG::CurrentYear {{fromdate1 no}} {
  # Gets current year (from date entry).
  #   fromdate1 - yes if get the year from the date entry

  if {$fromdate1} {
    return [clock format [ScanDate] -format %Y]
  }
  return [clock format [Date1Seconds] -format %Y]
}
#_______________________

proc EG::Field {item iday} {
  # Gets entry field path from item&day.
  #   item - item name
  #   iday - day index

  fetchVars
  if {[catch {
    set it [NormItem $item]
    set res [$EGOBJ $D(fld${it},$iday)]
  }]} then {
    set res {}
  }
  return $res
}
#_______________________

proc EG::FirstCell {} {
  # Gets 1st cell for -tabnext option of text.

  fetchVars
  Field [lindex $D(Items) 0] 0
}
#_______________________

proc EG::MonthShort {month} {
  # Gets short month name.
  #   month - month number

  lindex $::EG::MONTHSHORT [expr $month-1]
}
#_______________________

proc EG::MonthFull {month} {
  # Gets full month name.
  #   month - month number

  lindex $::EG::MONTHSFULL [expr $month-1]
}
#_______________________

proc EG::toEOL {line} {
  # Transforms \n of line to $D(EOL).
  #   line - line to be transformed

  string map [list \n $::EG::D(EOL)] $line
}
#_______________________

proc EG::fromEOL {line} {
  # Transforms $D(EOL) of line to \n.
  #   line - line to be transformed

  string map [list $::EG::D(EOL) \n] $line
}
#_______________________

proc EG::InitThemeEG {} {
  # Initializes EG theme.

  fetchVars
  catch {
    apave::InitTheme $D(Theme) $LIBDIR
    apave::initWM -theme $D(Theme) -cs $D(CS) -cursorwidth 2 -labelborder 2
  }
}
#_______________________

proc EG::GeItemsNumber {} {
  # Gets number of items.

  variable D
  set D(Curritems) [expr {min( $D(MAXITEMS), \
    [llength $D(Items)], [llength $D(ItemsTypes)])}]
}
#_______________________

proc EG::WriteTextFile {fname contVar} {
  # Writes contents to a file.
  #   fname - file name
  #   contVar - variable for contents

  variable TestMode
  upvar $contVar cont
  if {![IsLockedBase]} {
    set tmpcont $cont
    apave::writeTextFile $fname tmpcont
  }
}
#_______________________

proc EG::ColorName {color} {
  # Gets a color name from color value.
  #   color - color value

  variable Colors
  foreach cn {Red Yellow Green} {
    if {$color eq $Colors($cn)} {return $cn}
  }
  return {}
}
#_______________________

proc EG::Oct2Dec {oct} {
  # Converts octal to decimal.
  #   oct - octal value

  set res [string trimleft $oct 0]
  if {![string is digit -strict $res]} {set res 0}
  return $res
}

# ________________________ Items _________________________ #

proc EG::ValidIt {wid type item wday P V} {
  # Handles item value changed in its widget.
  #   wid - item widget
  #   type - item type
  #   item - item name
  #   wday - week day (field index)
  #   P - %P wildcard of entry command
  #   V - %V wildcard of entry command

  if {$V ni {key %V}} {return 1}
  if {[LockedChanges]} {return 0}
  fetchVars
  Message ""
  set w [$EGOBJ $wid]
  set typ $type
  set P [string trimleft $P]
  if {$P ne $EMPTY} {
    set input $P
    switch -glob $type {
      calc* {
        Message {Calculated cell}
        return 0
      }
      chk {
        set im none
        set val {}
        switch [$w cget -image] {
          none {set im [set val ques]}
          ques {set im [set val yes]}
          yes  {set im [set val lamp]}
          lamp {set im [set val no]}
        }
        $w configure -image $im
        focus $w
        after idle [list EG::StoreData v $val $item $wday]
      }
      9* - time {
        $w configure -validate key
        if {$type eq "time"} {set typ 99.99}
        set err no
        set P [string map {: .} $P]
        set li [string length $typ]
        set lj [string length $P]
        set i [string last . $typ]
        set j [string last . $P]
        lassign [split $typ .] d1 d2
        lassign [split $P .] h m
        if {$h eq {}} {set h 0}
        if {$type eq "time"} {
          if {$P ne {} && ($h<0 || "$h.$m">24) || $m ne {} && ($m<0 || $m>59)} {
            set P ?
          }
        }
        if {($i==-1 && $j>-1) || [string length $h]>[string length $d1]
        || [string length $m]>[string length $d2] || ![string is digit $h]
        || ![string is digit $m]} {
          set P ?
        }
        if {$P ne {} && (($P<0 && $i==-1) || $P>$typ || $lj>$li
        || $h>$d1 || ($d2 ne {} && $m>$d2)
        || ($i>-1 && $j>0 && ![string is double $P])
        || [llength [split $P -+]]>1)} {
          set input [string map [list \n {}] [string range $input 0 99]]
          return [MessageErrorInput $type $input]
        }
      }
      default {
        if {[string length $input] > [string length $type]} {
          return [MessageErrorInput $type $input]
        }
      }
    }
  }
  set D(toformat) [list $w $item $wday $type $typ]
  return 1
}
#_______________________

proc EG::FocusedIt {{item ""} {wday ""} {dt ""}} {
  # Handles item focusing.
  #   item - item name
  #   wday - week day

  fetchVars
  StoreItem
  set it [NormItem $item]
  if {$item eq {}} {
    if {$dt eq {}} {
      if {[catch {set dt [ScanDate $D(Date1)]}]} {
        set dt [Date1Seconds]
      }
    }
    set D(Date1) [FormatDate $dt]
    set item EG
    set wday [clock format $dt -format %u]
    incr wday -1
    if {$D(curritem) eq {}} {
      # find 1st non-checked cell at starting app
      set i1st $D(MAXITEMS)
      ForEach [FormatDatePG [FirstWDay $dt]] [list] {
        set wd [string index %k 1]
        if {{%v} in {? ques} && $wd==$wday} {
          if {[set i [ItemIndex %i]]<$i1st && $i>-1} {
            set i1st $i
          }
        }
      }
      if {$i1st < $D(MAXITEMS)} {
        set item [lindex $D(Items) $i1st]
      }
    } else {
      set item $D(curritem)
      set wday $D(currwday)
    }
    set w [Field $item $wday]
    after idle after 500 [list apave::focusByForce $w]
  } else {
    StatusBar $item $wday
    set cw [$EGOBJ LaBI$it]
    set cttl [$EGOBJ LaBIh$wday]
    set bg [$cw cget -bg]
    lassign [$EGOBJ csGet] - fg - bg2
    if {$bg ne $bg2} {
      lassign [apave::InvertBg $bg] fg  ;# item colored by polygons
    }
    set fgttl $Colors(fghot)
    lassign $D(previtem) previtem prevttl prevfg prevfgttl
    set font [[$EGOBJ LaBIh] cget -font]
    if {[string match -nocase *LaBIEG $previtem]} {
      HighlightEG
    } elseif {$previtem ne {}} {
      $previtem configure -fg $prevfg -font $font
    }
    catch {$prevttl configure -fg $prevfgttl -font $font}
    set D(previtem) [list $cw $cttl $fg $fgttl]
    $cw configure -fg $Colors(fgsel) -font [$EGOBJ boldDefFont]
    $cttl configure -fg $Colors(fgsel) -font [$EGOBJ boldDefFont]
  }
  set D(curritem) $item
  set D(currwday) $wday
  ShowText $item $wday
  after idle EG::diagr::DayLine
}
#_______________________

proc EG::CurrentItemDay {{citem ""} {date ""}} {
  # Sets current item and/or week day.
  #   citem - current item to set
  #   date - current date to set
  # Returns list of current item and week day.

  fetchVars
  if {$citem ne {} && $citem in $D(Items)} {
    set D(curritem) $citem
  }
  if {$date ne {}} {
    catch {
      set wday [clock format [ScanDatePG $date] -format %u]
      set D(currwday) [incr wday -1]
    }
  }
  return [list $D(curritem) $D(currwday)]
}
#_______________________

proc EG::SelIt {{to end}} {
  # (Un)selects characters of entry field.

  fetchVars
  catch {
    set w [Field $D(curritem) $D(currwday)]
    $w selection range 0 $to
  }
}
#_______________________

proc EG::FormatValue {w type typ P} {
  # Formats a cell value.
  #   w - cell path
  #   type - cell core type
  #   typ - cell format
  #   P - cell value

  fetchVars
  set P [string trim $P]
  if {$P eq $EMPTY} {return $P}
  if {$P ne "0" && ![string match 0.* $P]} {
    set P [string trimleft $P 0] ;# no octals, to be compatible with Tcl 8.6
  }
  lassign [split $typ .] t1 t2
  lassign [split $P .] n1 n2
  if {$type eq "time" && $n2 eq {}} {
    lassign [split [string map {. :} $P] :] n1 n2
  }
  if {$n1 eq {}} {set n1 "0"}
  switch -glob $type {
    9*.* {
      set n2 [string range ${n2}0000000000 0 [string length $t2]-1]
      set P $n1.$n2
    }
    time {
      if {$n2==60} {
        incr n1; set n2 {00}
      } else {
        set n2 [string range 00$n2 end-1 end]
      }
      set P $n1:$n2
    }
    chk {
      switch [$w cget -image] {
       yes     {set P Y}
       no      {set P N}
       lamp    {set P L}
       ques    {set P $EMPTY}
       default {set P {}}
      }
    }
  }
  return $P
}
#_______________________

proc EG::KeyPress {wid K s item wday} {
  # Handles pressing key in cell.
  #   wid - widget's path
  #   K - key
  #   s - state
  #   item - item name
  #   wday - week day

  fetchVars
  if {$s>1} {
    switch -exact $K {
      n - N {set com New}
      o - O {set com Open}
      s - S {set com Save}
      d - D {set com ChooseWeek}
      h - H {set com MoveToDay}
      l - L {set com SwitchLock}
      f - F {set com Find}
    }
    if {[info exists com]} {
      $com
      return break
    }
  } elseif {[ItemType $item] eq {chk}} {
    switch -- $K {
      Delete - BackSpace {
        $wid configure -image none
        StoreData v {} $item $wday
      }
      2 {
        $wid configure -image yes
        StoreData v Y $item $wday
      }
      1 {
        $wid configure -image lamp
        StoreData v L $item $wday
      }
      0 {
        $wid configure -image ques
        StoreData v $EMPTY $item $wday
      }
      - - minus - KP_Subtract {
        $wid configure -image no
        StoreData v N $item $wday
      }
    }
  }
  set i [ItemIndex $item]
  set llen [expr {[llength $D(Items)]-1}]
  switch -exact $K {
    Up {
      if {$i==0} {
        set i $llen
        if {$wday} {incr wday -1} {set wday 6}
      } else {
        incr i -1
      }
    }
    Down - Return - KP_Enter {
      if {$i>=$llen} {
        set i 0
        if {$wday<6} {incr wday} {set wday 0}
      } else {
        incr i
      }
    }
    default {return}
  }
  focus [Field [lindex $D(Items) $i] $wday]
  return break
}
#_______________________

proc EG::PopupOnItem {wit X Y {doit 0}} {
  # Handles popup menu on item.
  #   wit - item widget's path
  #   X - X-coordinate of pointer
  #   Y - Y-coordinate of pointer
  #   doit - used internally

  fetchVars
  apave::focusByForce $wit
  if {!$doit} {
    after idle after 100 "EG::PopupOnItem $wit $X $Y 1"
    return
  }
  set wpop $WIN.popupitem
  if {[winfo exist $wpop]} {destroy $wpop}
  menu $wpop
  obj themePopup $wpop
  foreach clr {Red Yellow Green} {
    set bg $Colors($clr)
    lassign [apave::InvertBg $bg] fg
    $wpop add command -label $clr -command "EG::AddTag $clr" \
      -foreground $fg -background $bg
  }
  $wpop add separator
  set mcasc $wpop.tags
  menu $mcasc -tearoff 0
  obj themePopup $mcasc
  $wpop add cascade -label Tags -menu $mcasc
  set tags [lsort -dictionary -nocase [split $::EG::D(TextTags)]]
  set itag -1
  foreach it $tags {
    if {$it ne {}} {
      if {[incr itag]%$::EG::TAGOPCLEN==0 && $itag} {
        set label "... [string toupper [string index $it 0]]"
        set mcasc $wpop.tags$itag
        menu $mcasc -tearoff 0
        obj themePopup $mcasc
        $wpop add cascade -label $label -menu $mcasc
      }
      $mcasc add command -label $it -command [list EG::AddTag $it]
    }
  }
  $wpop configure -tearoff 0
  tk_popup $wpop $X $Y
}
#_______________________

proc EG::AddTag {tag {doit 0}} {
  # Add tag to item text.
  #   tag - tag value

  fetchVars
  if {!$doit} {
    after idle [list EG::AddTag $tag 1]
    return
  }
  if {[LockedChanges]} return
  set wtxt [$EGOBJ Text]
  set text [$wtxt get 1.0 end]
  set ltext [split $text \n]
  set line1 [string trim [lindex $ltext 0]]
  if {[string first $D(TAGS) $line1]<0} {
    set line1 $D(TAGS)\ $tag\n
    if {$text eq {}} {$EGOBJ displayText $wtxt {      }}
    $wtxt insert 1.0 $line1
  } else {
    if {[string first $tag $line1]>=[string length $D(TAGS)]} return
    append line1 { } $tag
    $wtxt replace 1.0 1.end $line1
  }
  StoreText
  ShowTable
}
#_______________________

proc EG::PopupOnWeekTitle {ccur X Y} {
  # Handles popup menu on week day title.
  #   ccur - index of clicked title
  #   X - X-coordinate of pointer
  #   Y - Y-coordinate of pointer

  fetchVars
  set wpop $WIN.popupwttl
  if {[winfo exist $wpop]} {destroy $wpop}
  menu $wpop
  obj themePopup $wpop
  set ttl [lindex $D(WeekDays) $ccur]
  $wpop add command -label "Clear \"$ttl\"" -command "EG::ClearCells $ccur it"
  $wpop add command -label {... All} -command "EG::ClearCells $ccur all"
  $wpop add command -label {... All at Left} -command "EG::ClearCells $ccur left"
  $wpop add command -label {... All at Right} -command "EG::ClearCells $ccur right"
  $wpop configure -tearoff 0
  if {$ccur==0} {
    $wpop entryconfigure 2 -state disabled
  } elseif {$ccur==6} {
    $wpop entryconfigure 3 -state disabled
  }
  tk_popup $wpop $X $Y
}
#_______________________

proc EG::ClearCells {ccur what} {
  # Clears cells.
  #   ccur - index of clicked title
  #   what - what cells to clear

  fetchVars
  if {[LockedChanges]} return
  switch $what {
    all {
      set c1 0
      set c2 6
    }
    left {
      set c1 0
      set c2 [incr ccur -1]
    }
    right {
      set c1 [incr ccur]
      set c2 6
    }
    default {
      set c1 [set c2 $ccur]
    }
  }
  for {set wday $c1} {$wday<=$c2} {incr wday} {
    foreach item $D(Items) {
      StoreValue v {} $item $wday
      StoreValue t {} $item $wday
    }
  }
  ShowTable
}
#_______________________

proc EG::ItemColor {item {defcolor black}} {
  # Gets item's color.
  #   item - item name
  #   defcolor - default color

  fetchVars
  if {$item eq {EG}} {
    set color $Colors(bg3)
  } else {
    set color $defcolor
    set i [ItemIndex $item]
    catch {set color $Colors(my[incr i])}
  }
  return $color
}

# ________________________ Data _________________________ #


## ________________________ Item data _________________________ ##

proc EG::ItemType {item} {
  # Gets item type.
  #   item - item name

  fetchVars
  lindex $D(ItemsTypes) [ItemIndex $item]
}
#_______________________

proc EG::ItemIndex {item} {
  # Gets item's index.

  lsearch -exact $::EG::D(Items) $item
}
#_______________________

proc EG::CalculatedValue {itemtype idx {reslist ""}} {
  # Calculates the calculated item's value.
  #   itemtype - item type
  #   idx - index of week day
  #   reslist - optional list of results
  # If *reslist* is passed, it contains items of the following
  # structure: "cnt cnt0 sum avg", at that *sum* and *avg*
  # are decimal values, no possible conversions needed for them.
  # Also, if *reslist* is passed, *idx* argument is an index of
  # value in "cnt cnt0 sum avg" (2 for *sum*, 3 for *avg*).
  # See also: Week1Data

  fetchVars
  set i1 [string first : $itemtype]
  set i2 [string first : $itemtype $i1+1]
  set format [string range $itemtype $i1+1 $i2-1]
  set formula [string range $itemtype $i2+1 end]  ;# may contain ":"
  set data [list]
  for {set i 0} {$i<$D(Curritems)} {incr i} {
    set itv [lindex $D(Items) $i]
    set itt [lindex $D(ItemsTypes) $i]
    if {[llength $reslist]} {
      set val [lindex $reslist $i $idx]
    } else {
      set val [DataValue v $itv $idx]
      if {$itt eq {time}} {
        set val [TimeValue $val]
      }
    }
    lappend data $val
  }
  if {[set val [EG::stat::CalculateByFormula $formula $data]] ne {}} {
    set val [FormatValue - $format $format $val]
  }
  return $val
}
#_______________________

proc EG::TextValue {tval} {
  # Calculates value of text cell.
  #   tval - text

  if {$tval eq {}} {
    # no text, no value
    set val 0
  } else {
    # any text is evaluated as 1
    set val 1
    # leading "-" make it lesser
    # leading "+" make it greater
    set tlen [string length $tval]
    incr val [expr {[string length [string trimleft $tval -]] - $tlen}]
    incr val [expr {$tlen - [string length [string trimleft $tval +]]}]
    set val [expr {max(0,$val)}]
  }
  return $val
}

## ________________________ Scanning _________________________ ##

proc EG::ForEach {dkey dkeys script {egdinfo ""}} {
  # Scans item values, applying a script to them.
  #   dkey - filtering day key or {}
  #   dkeys - list of day keys or {}
  #   script - script with %d, %t, %i, %k and %v (date, itemtype, item, key & value)
  #   egdinfo

  fetchVars
  lassign $egdinfo fname egdvar
  if {$egdvar eq {}} {
    set EGDdict $EGD
    set items [CommonData ITEMS]
    set itemstypes [CommonData ITEMSTYPES]
  } else {
    set EGDdict [set $egdvar]
    set items [DataValue $COMMONTYPE ITEMS {} $egdvar]
    set itemstypes [DataValue $COMMONTYPE ITEMSTYPES {} $egdvar]
  }
  if {![llength $dkeys]} {
    set dkeys [lsort -decreasing [dict keys $EGDdict]]
  }
  set abra e#@
  foreach day $dkeys {
    if {![string match $COMMONTYPE* $day] && [string match $dkey* $day]} {
      set line [dict get $EGDdict $day]
      foreach it [dict keys $line] {
        set i [lsearch -exact $items $it]
        set typ [list [lindex $itemstypes $i]]
        set vals [dict get $line $it]
        set scr [string map [list %% $abra] $script]
        if {[string first %V $script]>-1} {
          set vals [list $vals]
          set scr [string map [list %d $day %t $typ %i $it %V $vals] $scr]
          set scr [string map [list $abra %] $scr]
          uplevel 1 $scr
        } else {
          foreach {k v} $vals {
            set v [list $v]
            set scr [string map [list %d $day %t $typ %i $it %k $k %v $v] $script]
            set scr [string map [list $abra %] $scr]
            uplevel 1 $scr
          }
        }
      }
    }
  }
}
#_______________________

proc EG::DatesKeys {{date1 ""} {date2 ""} {incsort 1} {egdvar ""}} {
  # Gets a list of date keys, for item data.
  #   date1 - min. date to include
  #   date2 - max. date to include
  #   incsort - sort order (1 - increasing, 0 - decreasing)

  fetchVars
  if {$incsort} {set sord -increasing} {set sord -decreasing}
  if {$date1 ne {}} {
    set date1 [FormatDatePG [ScanDate $date1]]
  }
  if {$date2 ne {}} {
    set date2 [FormatDatePG [ScanDate $date2]]
  } else {
    set date2 [CurrentYear]/99/99 ;# used for comparison
  }
  if {$egdvar eq {}} {set egdvar EGD}
  set keys [lsort $sord [dict keys [set $egdvar] */*/*]]
  set res [list]
  foreach dt $keys {
    if {$date1 <= $dt && $dt < $date2} {lappend res $dt}
  }
  return $res
}
#_______________________

proc EG::WeekValue {{date1 ""}} {
  # Gets value of week (value of EGD week item).
  #   date1 - date of week (1st week day's)

  if {$date1 eq {} || ![dict exists $::EG::EGD $date1]} {
    set date1 [lindex [DatesKeys] end]
  }
  if {[dict exists $::EG::EGD $date1]} {
    return [dict get $::EG::EGD $date1]
  }
  return {}
}
#_______________________

proc EG::DataKey {styp {item ""} {wday ""}} {
  # Gets a key for EGD dictionary.
  #   styp - store type (v - cell value, t - text, and others)
  #   item - item
  #   wday - week day

  fetchVars
  if {[string length $styp]==1} {
    if {$item eq {}} {set item $D(curritem)}
    if {$wday eq {}} {set wday $D(currwday)}
    set dt [ScanDate]
    set dt [FormatDatePG [FirstWDay $dt]]
    return [list $dt $item $styp$wday]
  }
  return [list $styp $item] ;# common data
}
#_______________________

proc EG::DataValue {styp item {wday ""} {egdvar EGD}} {
  # Gets a value for EGD dictionary.
  #   styp - store type (v - cell value, t - text, and others)
  #   item - item
  #   wday - week day
  #   egdvar - egd dictionary variable

  fetchVars
  set key [DataKey $styp $item $wday]
  if {[catch {set val [dict get [set $egdvar] {*}$key]}]} {
    set val {}
  }
  fromEOL $val
}

## ________________________ Storing _________________________ ##

proc EG::StoreItem {} {
  # Formats item cell value and saves it.
  # See also: ValidIt

  fetchVars
  lassign $D(toformat) w item wday type typ
  if {$w eq {}} return
  set it [NormItem $item]
  set P [set D($it$wday)]
  if {$P ne {}} {set P [FormatValue $w $type $typ $P]}
  set D($it$wday) $P
  StoreData v $P $item $wday
}
#_______________________

proc EG::StoreValue {styp val {item ""} {wday ""}} {
  # Remembers value.
  #   styp - store type (v - cell value, t - text, and others)
  #   val - data
  #   item  - item name
  #   wday - week day

  fetchVars
  set val [string trimright $val]
  # save text
  set key [DataKey $styp $item $wday]
  if {$val ne {}} {
    dict set EGD {*}$key $val
  } else {
    catch {
      while 1 {
        dict unset EGD {*}$key
        set key [lrange $key 0 end-1]
        if {![llength $key] || [dict get $EGD {*}$key] ne {}} break
      }
    }
  }
}
#_______________________

proc EG::StoreData {styp val {item ""} {wday ""}} {
  # Remembers data.
  #   styp - store type (v - cell value, t - text, and others)
  #   val - data
  #   item  - item name
  #   wday - week day

  StoreValue $styp $val $item $wday
  ShowTable
}
#_______________________

proc EG::CommonData {args} {
  # Sets/gets common data
  #   args - contains item name (to get a value) or item name & value to set

  fetchVars
  lassign $args item value
  if {[llength $args]==2} {
    StoreValue $COMMONTYPE $value $item
  } else {
    set value [DataValue $COMMONTYPE $item]
  }
  return $value
}
#_______________________

proc EG::SaveRC {} {
  # Saves resource data except for notes' contents.

  fetchVars
  foreach n $NOTESN {
    lappend noteopen [winfo exists [note::NoteWin $n]]
  }
  ResourceData Geometry [wm geometry $WIN]
  ResourceData NoteOpen {*}$noteopen
  ResourceData Zoom $D(Zoom)
  ResourceData NoteOnTop $D(NoteOnTop)
  ResourceData DefFont {*}$D(DefFont)
  ResourceData TexFont {*}$D(TexFont)
  TabFilesArray
  ResourceData TabFiles {*}$D(TabFiles)
  ResourceData DATEUSER {*}[split $D(DateUser)]
  ResourceData DATEUSER2 {*}[split $D(DateUser2)]
  ResourceData DATEUSER3 {*}[split $D(DateUser3)]
  ResourceData THEME $D(Theme)
  ResourceData CS $D(CS)
  ResourceData HUE $D(Hue)
  ResourceData FILEBAK $D(FILEBAK)
  ResourceData AUTOBAK $D(AUTOBAK)
}
#_______________________

proc EG::SaveAllData {args} {
  # Saves all data.

  fetchVars
  set t [[$EGOBJ Text] get 1.0 end]
  StoreText $t
  if {"-openfile" ni $args} {
    if {"-newfile" in $args} {set newfile yes} {set newfile no}
    if {[catch {SaveDataFile $newfile} err]} {puts $err}
  }
  SaveRC
  foreach n $NOTESN {
    set isopen [winfo exists [note::NoteWin $n]]
    if {$isopen} {note::SaveNoteData $n}
  }
}
#_______________________

proc EG::SaveAll {args} {
  # Saves all data and shows a message.

  fetchVars
  if {[IsTestMode]} return
  FocusedIt
  SaveAllData {*}$args
  Message "Data saved to $USERDIR" 5
}

## ________________________ Collecting per week/item _________________________ ##

proc EG::AllWeekData {} {
  # Collects all data on items.
  # Results are collected in *DS* dict: as sums, counts and tags
  # on dates & items, i.e. "date1 {item1 {cnt cnt0 sum avg} ...} ...",
  # where date1 is 1st date of week ("by week" diagram) or
  # date of year ("by day" diagram).

  fetchVars
  set DS [dict create]
  set dkeys [DatesKeys {} {} 0]
  # collect results
  ForEach {} $dkeys {
    set k [string index %k 0]
    set i [string index %k 1]
    set d1 %d
    if {!$byWeek} {
      catch {set d1 [FormatDatePG [clock add [ScanDatePG %d] $i days]]}
    }
    set item [list $d1 %i]
    if {[dict exists $DS {*}$item]} {
      set res [dict get $DS {*}$item]
    } else {
      set res [list 0 0 0 ""]
    }
    lassign $res cnt cnt0 sum tags tagcmnt
    switch $k {
      v {
        if {{%i} eq {EG}} {
          set typ 999
        } else {
          set typ [string range %t 0 3]
        }
        switch -glob $typ {
          time {set val [TimeValue %v]}
          chk* {set val [ButtonValue %v]}
          calc* - 9* {
            set val %v
            if {$val eq $::EG::EMPTY} {set val 0}
          }
          default {  ;# pure text
            set val [TextValue %v]
          }
        }
        incr cnt
        if {$val<=0 || ![string is double -strict $val]} {
          incr cnt0
          set val 0
        }
        set sum [expr {$sum + $val}]
        dict set DS {*}$item [list $cnt $cnt0 $sum $tags $tagcmnt]
      }
      t {
        set i1 [string first \n %v]
        set i2 [string first $D(EOL) %v]
        set i [expr {max($i1,$i2)}]
        if {$i>-1} {
          set ltext [string range %v 0 $i-1]
          set ctext [string range [fromEOL [string range %v $i end]] 1 end]
        } else {
          set ltext %v
          set ctext {}
        }
        if {[string first $D(TAGS) $ltext]==0} {
          append tags { } [string range $ltext [string length $D(TAGS)] end]
          set tagcmnt "[string trimleft $tagcmnt\n]$ctext"
          dict set DS {*}$item [list $cnt $cnt0 $sum [string trimleft $tags] $tagcmnt]
        }
      }
    }
  }
  set LS [lsort -index 0 -stride 2 $DS]
}
#_______________________

proc EG::Week1Data {inpdata {inpitem ""}} {
  # Gets counts, sum and color for current week/day.
  #   inpdata - list of data for week/day
  #   inpitem - item name

  fetchVars
  set row [set col [set cnt [set cnt0 [set sum 0]]]]
  set tags [set tagcmnt [set color {}]]
  foreach item $::EG::D(Items) {
    set ::EG::stat::aggrdata($row,$col) 0
    if {$inpitem in [list {} $item AggrEG]} {
      set asum 0
      foreach {it data} $inpdata {
        if {$it eq $item} {
          lassign $data icnt icnt0 isum tag cmnt
          incr cnt $icnt
          incr cnt0 $icnt0
          set sum [expr {$sum + $isum}]
          set asum [expr {$asum + $isum}]
          append tags $tag
          foreach clr {Red Yellow Green} {
            if {[string first $clr $tag]>-1} {
              set tagcmnt "[string trimleft $tagcmnt\n]$cmnt"
              break
            }
          }
        }
      }
      set ::EG::stat::aggrdata($row,$col) $asum
    }
    incr row
  }
  if {$inpitem eq {AggrEG}} {
    set sum [stat::AggregateValue $col]
    if {$sum eq {}} {set sum 0}
  }
  foreach clr {Red Yellow Green} {
    if {[string first $clr $tags]>-1} {
      set color $Colors($clr)
      break
    }
  }
  list $cnt $cnt0 $sum $color $tagcmnt
}
#_______________________

proc EG::GetAggrEG {date1} {
  # Gets value of AggrEG of week.
  #   date1 - date of the week
  # See also: AllWeekData, Week1Data

  fetchVars
  set wdate1 [FirstWDay [ScanDatePG $date1]]
  set aeg [set i 0]
  foreach {dk data} $LS {
    if {[FirstWDay [ScanDatePG $dk]] eq $wdate1} {
      lassign [Week1Data $data AggrEG] cnt cnt0 sum color
      set aeg [expr {$aeg + $sum}]
    }
  }
  Round $aeg 2
}
#_______________________

proc EG::CheckAggrEG {} {
  # Checks the aggregate formula and sets its default at need.

  if {[string trim $::EG::D(AggrEG)] eq {}} {set ::EG::D(AggrEG) EG}
}

# ________________________ Weeks _________________________ #

proc EG::FirstWDay {{dt ""}} {
  # Gets 1st date of week.
  #   dt - clock time

  fetchVars
  if {$dt eq {}} {set dt [Date1Seconds]}
  set wd [clock format $dt -format %u]
  clock add $dt -[incr wd -1] day
}
#_______________________

proc EG::ChooseDay {dtvar args} {
  # Calls a calendar to pick a date.
  #   dtvar - date variable name
  #   args - additional options of color chooser

  fetchVars
  set hllist [lsort [dict keys $EGD */*/*]]
  set dt [obj chooser dateChooser $dtvar -title {Choose a week} \
    -locale en -dateformat $D(DateUser) -weeks 1 \
    -hllist $hllist -hlweeks 1 -entry [$EGOBJ EntDate] {*}$args]
  if {$dt ne {}} {
    if {[catch {set fmt [dict get $args -dateformat]}]} {
      set fmt $D(DateUser)
    }
    set dt [clock scan $dt -format $fmt]
  }
  return $dt
}
#_______________________

proc EG::ChooseWeek {{dtvar ""}} {
  # Calls a calendar to pick a date.
  #   dtvar - date variable name

  fetchVars
  if {$dtvar eq {}} {set dtvar ::EG::D(Date1)}
  set dt [ChooseDay $dtvar]
  if {$dt ne {}} {
    AfterWeekSwitch
    set $dtvar [FormatDate $dt]
  }
  if {[IsMoveWeek]} {
    CheckCurrentWeek
    ShowTable
  }
}
#_______________________

proc EG::IsLockedBase {} {
  # Checks if the whole base isn't for today (i.e. it's past or future).

  fetchVars
  set currDate [FormatDatePG [clock seconds]]
  if {$currDate < $D(egdDate1) || $currDate >= $D(egdDate2) || $TestMode} {
    return yes
  }
  return no
}
#_______________________

proc EG::IsTestMode {} {
  # Checks if the app in the test mode. Shows message if it is.

  if {$::EG::TestMode} {
    Message "Disabled at testing" 7
    return yes
  }
  return no
}
#_______________________

proc EG::CheckCurrentWeek {} {
  # Checks if the week is current and empty (no values set).
  # If so, fills it with "pending values" (0 for number, 0:00 for time,
  # ques icon for chk).

  fetchVars
  ConfigLock
  if {[IsLockedBase]} return
  # current week's 1st day
  set datec [FirstWDay]
  # next week's 1st day
  set daten [FirstWDay [clock add $datec 1 week]]
  # current displayed week's 1st day
  set date1 [FirstWDay [clock scan $D(Date1) -format $D(DateUser)]]
  set fdc [FormatDatePG $datec]
  set fdn [FormatDatePG $daten]
  set fd1 [FormatDatePG $date1]
  if {$fd1 ne $fdc && $fd1 ne $fdn} return
  set found no
  foreach week {0 1 2 3 4} {
    # try to find 1st "non-empty" week among previous ones
    set dt [clock add $date1 -$week week]
    set dt [FormatDatePG [FirstWDay $dt]]
    set pendlist [list]
    ForEach $dt [list] {
      set typ [string range %t 0 3]
      set k [string index %k 0]
      if {{%v} ne {} && $typ ne {calc} && $k ne {t}} {
        set found yes
        lappend pendlist [list %i %t %k]
      }
    }
    foreach i {0 1 2 3 4 5 6} {
      lappend pendlist [list EG - v$i] ;# all EG should be checked
    }
    if {$found} {
      if {$week} {
        foreach data $pendlist {
          lassign $data it typ key
          lassign [split $key {}] k wday
          StoreValue $k $EMPTY $it $wday
        }
      }
      return
    }
  }
}
#_______________________

proc EG::AfterWeekSwitch {} {
  # Checks and sets some data after switching week.

  fetchVars
  # the past data should be locked by default
  set d1 [ScanDate [FormatDate [FirstWDay [ScanDate]]]]
  set d2 [ScanDate [FormatDate [FirstWDay]]]
  set D(lockdata) [expr {[IsLockedBase] || $d1 < $d2}]
  ConfigLock
  ShowTextR
}

# ________________________ Move to _________________________ #

proc EG::IsMoveWeek {} {
  # Checks if a move week is correct. If not, moves to current week of year.

  fetchVars
  update
  set D1 [FormatDatePG [FirstWDay [ScanDate]]]
  set isBad1 [expr {$D1<$D(egdDate1)}]
  set isBad2 [expr {$D1>=$D(egdDate2)}]
  if {$isBad1 || $isBad2} {
    msg ok warn "\n\
      Cannot move to [string trim $D(Date1)]!\n\n\
      In \"Preferences\", the week range is \[$D(egdDate1) - $D(egdDate2)\).\n" \
      -timeout {9 ButOK}
    if {$isBad1} {
      set date [ScanDatePG $D(egdDate1)]
    } else {
      set date [ScanDatePG $D(egdDate2)]
      set date [clock add $date -7 days]
    }
    after idle [list EG::MoveToWeek 0 $date]
    return no
  }
  return yes
}
#_______________________

proc EG::MoveToWeek {wdays {dt ""} {doit no}} {
  # Moves to week(s).
  #   wdays - week days to and fro
  #   dt - time in week day
  #   doit - yes if force moving

  fetchVars
  if {$wdays} {
    if {$dt eq {}} {set dt [ScanDate]}
    set dt [clock add $dt $wdays day]
  }
  set D(Date1) [FormatDate $dt]
  if {$doit || [IsMoveWeek]} {
    CheckCurrentWeek
    ShowTable
    AfterWeekSwitch
    FocusedIt {} {} $dt
  }
}
#_______________________

proc EG::MoveToDay {{dt ""}} {
  # Move to specific day.
  #   dt - date to move to

  CurrentItemDay "" [FormatDatePG $dt]
  MoveToWeek 0 $dt
}

# ________________________ Show data _________________________ #

proc EG::ShowTable {{atStart 0}} {
  # Shows table: values and colors.
  #   atStart - 1 if run at starting EG

  fetchVars
  if {$atStart} {
    if {![IsTabFiles]} UpdateBAR
    if {$InpItem ne {} && $InpDate ne {}} {
      CurrentItemDay $InpItem $InpDate
      MoveToWeek 0 [ScanDatePG $InpDate]
    } else {
      MoveToDay
    }
    return
  }
  foreach item $D(Items) type $D(ItemsTypes) {
    # cells
    for {set wday 0} {$wday<7} {incr wday} {
      set it [NormItem $item]
      set w [Field $item $wday]
      if {$w eq {}} break
      set D($it$wday) [set val [DataValue v $item $wday]] ;# shows number
      switch -glob $type {
        chk {
          switch $val {
            Y - yes  {set im yes}
            N - no   {set im no}
            L - lamp {set im lamp}
            ? - Q - ques {set im ques}
            default  {set im none}
          }
          $w configure -image $im
        }
        calc* {
          set val [CalculatedValue $type $wday]
          StoreValue v $val $item $wday
          set D($it$wday) $val
        }
      }
      set text [DataValue t $item $wday]
      if {$text eq {}} {
        if {$type eq {chk}} {
          set bg $Colors(bg)
        } else {
          set bg $Colors(bg2)
        }
      } else {
        set bg $Colors(bgtex)
        set line1 [lindex [split $text \n] 0]
        if {[string match $D(TAGS)* $line1]} {
          foreach clr {Red Yellow Green} {
            if {[string first $clr $line1]>0} {
              set bg $Colors($clr)
              break
            }
          }
        }
      }
      if {$type eq {chk}} {
        $w configure -bg $bg
      } else {
        lassign [$EGOBJ csGet] fg - bg2
        if {$bg ne $bg2} {
          lassign [apave::InvertBg $bg] fg  ;# cell commented
        }
        $w configure -bg $bg -fg $fg -insertbackground $fg -validate key
      }
    }
  }
}
#_______________________

proc EG::ShowText {item wday} {
  # Shows text for a chosen item.
  #   item - item name
  #   wday - week day

  fetchVars
  set val [DataValue t $item $wday]
  $EGOBJ displayText [$EGOBJ Text] $val
}
#_______________________

proc EG::ShowTextR {} {
  # Shows weekly text.

  fetchVars
  set textR [DataValue $D(WeeklyKEY) {*}$D(WeeklyITEM)]
  $EGOBJ displayText [$EGOBJ TextR] $textR
  set week [clock format [ScanDate] -format %V]
  [$EGOBJ Lfr2] configure -text " Weekly #$week "

}
#_______________________

proc EG::StoreText {{tex ?@-*}} {
  # Stores item comments.
  #   tex - text to store (taken from Text field, if omitted)

  fetchVars
  set wtxt [$EGOBJ Text]
  if {$tex eq {?@-*}} {
    set tex [string trimright [$wtxt get 1.0 end]]
  } else {
    set tex [string trimright $tex]
    $EGOBJ displayText $wtxt $tex
  }
  StoreValue t $tex
}
#_______________________

proc EG::StoreTextR {} {
  # Stores weekly comments.

  fetchVars
  set wtxt [$EGOBJ TextR]
  set tex [string trimright [$wtxt get 1.0 end]]
  StoreValue $D(WeeklyKEY) $tex {*}$D(WeeklyITEM)
}
#_______________________

proc EG::TextTip {} {

  fetchVars
  set cmnt [string trim "[[$EGOBJ Labstat1] cget -text]\
    [[$EGOBJ Labstat2] cget -text]"]
  if {$cmnt ne {}} {
    set cmnt "Comments on $cmnt"
  }
  return $cmnt
}
#_______________________

proc EG::CellTip {item {wday ""}} {
  # Gets a tip for cell.
  #   item - item
  #   wday - week day

  set val [DataValue t $item $wday]
  if {$val eq {} && [incr ::EG::_MAXTIP]<333} {  ;# soon, pointer moves will
    set val "After change\npress Enter to save"  ;# disable the annoying tips
  }
  fromEOL $val
}
#_______________________

proc EG::HighlightEG {} {
  # Highlights some titles.

  fetchVars
  [$EGOBJ LaBIEG] configure -fg $Colors(fghot) -font [$EGOBJ boldDefFont]
}
#_______________________

proc EG::ColorItemLabels {{ispoly 0}} {
  # Colorizes item labels depending on diagram item choice.
  #  ispoly - true for drawing polygon

  fetchVars
  foreach item $D(Items) {
    incr iit
    set ip [expr {$iit-1}]
    set fg $Colors(fg)
    set bg $Colors(bg)
    if {!$ispoly || $D(poly,$ip)} {
      switch -- $Opcvar {
        Totals - EG {}
        Polygon {
          lassign [apave::InvertBg $Colors(my$iit)] fg bg
        }
        default {
          if {$item eq $Opcvar} {
            set iit [ItemIndex $Opcvar]
            lassign [apave::InvertBg $Colors(my[incr iit])] fg bg
          }
        }
      }
      if {$item eq {EG}} {
        set fg $Colors(fghot)
        set bg $Colors(bg)
      }
    }
    set it [NormItem $item]
    [$EGOBJ LaBI$it] configure -fg $fg -bg $bg
  }
  FocusedIt
}

# ________________________ Bar of tabs _________________________ #

proc EG::FillBar {} {
  # Fills the bar of tabs.

  fetchVars
  catch {BAR removeAll}
  catch {::bartabs::Bars create D(bts)}   ;# D(bts) is Bars object
  if {![IsTabFiles]} return
  update ;# to get real sizes of -wbase
  set wbase [$EGOBJ Lfr1]
  set wframe [$EGOBJ Frabts]
  set curtab 0
  if {[set i [lsearch -exact $D(TabFiles) $D(FILE)]]>=0} {
    set curtab $i
  }
  set bar1Opts [list -wbar $wframe -wbase $wbase -pady 2 -scrollsel no \
    -lablen 16 -tiplen 16 -padx 0 -bg [lindex [$EGOBJ csGet] 3] \
    -font TkTooltipFont -cdel {EG::OnTabDeletion %t} -cdel2 EG::UpdateBAR \
    -csel2 {EG::OnTabSelection %t} -popuptip ::EG::PopupTip]
  set tip "To select a bar tab\npress Ctrl and click it."
  lappend bar1Opts -menu [list \
    sep "com {Open...} EG::Open" \
    sep "com {Merge...} {EG::Merge 1 %t} {} {} {$tip}"]
  set tabs [list]
  foreach fname $D(TabFiles) {
    set tab [UniqueTab $tabs [file tail $fname]]
    lappend tabs $tab
    lappend bar1Opts -tab $tab
  }
  set curname [lindex $tabs $curtab]
  if {[catch {set D(BID) [D(bts) create D(bt) $bar1Opts $curname]}]} {
    foreach tab $tabs {BAR insertTab $tab}
  }
  foreach fname $D(TabFiles) tab [BAR listTab] {
    set tid [lindex $tab 0]
    BAR $tid configure -tip $fname
  }
}
#_______________________

proc EG::IsTabFiles {} {
  # Checks if the bar tabs are multiple.

  expr {[llength $::EG::D(TabFiles)] > 1}
}
#_______________________

proc EG::TabFilesArray {} {
  # Gets the bar tab array.

  fetchVars
  catch {
    set tabs [BAR listTab]
    if {[llength $tabs]} {
      set D(TabFiles) [list]
      foreach tab $tabs {
        set tid [lindex $tab 0]
        set fname [TIDfname $tid]
        if {[lsearch -exact $D(TabFiles) $fname]<0} {
          lappend D(TabFiles) $fname
        }
      }
    }
  }
  if {[lsearch -exact $D(TabFiles) $D(FILE)]<0} {
    lappend D(TabFiles) $D(FILE)
  }
}
#_______________________

proc EG::UniqueTab {tabs tab} {
  # Returns a unique name for a tab.
  #   tabs - list of tabs
  #   tab - tab name to be checked for its duplicate
  # If some file has a tail name (tab name) equal to an existing one's,
  # the new tab name should get "(N)" suffix to be unique.
  # This is required by bartabs package: no duplicates allowed.

  set cnttab 1
  set taborig $tab
  while {1} {
    if {[lsearch $tabs $tab]==-1} break
    set tab "$taborig ([incr cnttab])"
  }
  return $tab
}
#_______________________

proc EG::BAR {args} {
  # Runs the tab bar's method.
  #   args - method's name and its arguments

  fetchVars
  set res {}
  catch {
    if {[lindex $args 0] eq {popList}} {
      if {[llength $args] eq 1} {lappend args {} {}}
      lappend args $D(sortList)
    }
    if {[lindex $args 1] eq {cget}} {
      if {![D(bts) isTab [lindex $args 0]]} {
        return {} ;# at closing tabs: cget must return "" to "after" proc
      }
    }
    set res [D(bts) $D(BID) {*}$args]
  }
  return $res
}
#_______________________

proc EG::OnTabSelection {TID} {
  # Handles selecting a tab in the bar.
  #   TID - tab's ID

  fetchVars
  if {[IsTestMode]} return
  set fname [TIDfname $TID]
  if {$fname ne $D(FILE)} {OpenFile $fname} UpdateBAR

}
#_______________________

proc EG::OnTabDeletion {TID args} {

  fetchVars
  if {[IsTestMode]} {return 2}
  set fname [TIDfname $TID]
  if {$fname eq $D(FILE)} {
    if {[set i [lsearch $args -first]]>=0} {
      if {[lindex $args $i+1] == -1} {
        return yes  ;# run with Close of context menu
      }
    }
    Message {Only "Close" of context menu closes the current file!} 20
    return 2
  }
  return yes
}
#_______________________

proc EG::UpdateBAR {args} {
  # Updates the tab bar.
  # Renames tabs: "name(2)" => "name", if "name" is closed.

  set bartabs [BAR listTab]
  if {[llength $bartabs] < 2} {
    pack forget [$::EG::EGOBJ Frabts]
  }
  # first, remove all (n)
  set tabs [list]
  foreach tab $bartabs {
    lassign $tab tid tname
    set tname [file tail [TIDfname $tid]]
    lappend tabs [list $tid $tname]
  }
  # then update tab titles
  set i 0
  foreach tinf $tabs {
    lassign $tinf tid tname
    set tname [UniqueTab $tabs $tname]
    BAR $tid configure -text $tname
    set tabs [lreplace $tabs $i $i $tname]
    incr i
  }
  BAR draw
}
#_______________________

proc EG::PopupTip {wmenu idx TID} {
  # Makes tooltips (full file names) for popup menu items.
  # wmenu - path to popup menu
  # idx - index of item
  # TID - ID of item's tab

  if {[$wmenu cget -tearoff]} {incr idx}
  ::baltip::tip $wmenu [TIDfname $TID] -index $idx -shiftX 10 -ontop 1
}
#_______________________

proc EG::TIDfname {TID} {
  # Gets file name of bar tab.
  #   TID - tab's ID

  BAR $TID cget -tip
}

# ________________________ Canvas _________________________ #

proc EG::opcPre {args} {

  fetchVars
  set item [lindex [split $args] 0]
  if {$item ni [list EG \{EG]} {
    set i [ItemIndex $item]
    if {[incr i]>0} {
      lassign [apave::InvertBg $Colors(my$i)] fg bg
      return [list -background $bg -foreground $fg]
    }
  } else {
    return [list -foreground $::EG::Colors(fgsel) -font [$EGOBJ boldDefFont]]
  }
  return [list]
}
#_______________________

proc EG::opcPost {} {

  if {[diagr::Draw]} {
    diagr::Title
    ColorItemLabels
  } else {
    diagr::Title Polygons
    ColorItemLabels yes
  }
}

# ________________________ Locks _________________________ #

proc EG::SwitchLock {} {
  # Switches lock mode.

  fetchVars
  if {[IsTestMode]} return
  set D(lockdata) [expr {!$D(lockdata)}]
  ConfigLock
  after 500 EG::MessageState
}
#_______________________

proc EG::ConfigLock {} {
  # Configures widgets depending on locks.

  fetchVars
  if {$D(lockdata)} {
    set st disabled
    set ttl {Unlock changes}
    set bg [set bg2 $Colors(Red)]
  } else {
    set st normal
    set ttl {Lock changes}
    set bg $Colors(bg)
    set bg2 $Colors(bg2)
  }
  foreach wt {Text TextR} {
    set wtxt [$EGOBJ $wt]
    $wtxt configure -state $st
    $wtxt configure -fg [lindex [$EGOBJ csGet] 0]
  }
  set but [$EGOBJ BuT_Tool_lock]
  $but configure -bg $bg -activebackground $bg2
  ::baltip::tip $but $ttl
  return $ttl
}
#_______________________

proc EG::LockedChanges {} {
  # Checks if changes are locked & shows message if so.

  if {[IsLockedBase] || $::EG::D(lockdata)} {
    MessageState 1
    return 1
  }
  return 0
}

# ________________________ Messages _________________________ #

proc EG::Message {msg {wait 0} {lab ""} {doit 0}} {
  # Shows a message.
  #   msg - message's text
  #   wait - time to wait in sec.
  #   doit - internally used by itself
  #   lab - label of message

  fetchVars
  if {$lab eq {}} {set lab [$EGOBJ Labstat3]}
  catch {  ;# the method can be called after destroying Puzzle object => catch
    catch {after cancel $D(idafter)}
    if {!$doit} {
      set D(msg) {}
      $lab configure -text {}
      after idle [list EG::Message $msg $wait $lab [incr doit]]
      if {$wait>=0} {
        ::baltip tip $lab $msg -font [list {*}[obj basicDefFont] -weight bold]
        bind $lab <Button> [list EG::Message $msg $wait $lab]
        bind $lab <Enter> \
          "$lab configure -text {}; catch {after cancel \$::EG::D(idafter)}"
      }
      return
    }
    set D(msg) $msg
    $lab configure -text $msg {*}$::EG::D(MsgFont)
    if {$wait<=0} {set wait [expr {[string length $msg]/4}]}
    set D(idafter) [after [expr {$wait*1000}] "EG::CheckMessage $lab"]
  }
}
#_______________________

proc EG::CheckMessage {lab} {
  # Checks if there is a message. If so, erase it char by char.
  #   lab - label of message

  fetchVars
  catch {  ;# the method can be called after destroying Puzzle object => catch
    if {[set len [string length $D(msg)]]} {
      set D(msg) [string range $D(msg) 0 $len-2]
      Message $D(msg) -1 $lab
      after 30 "EG::CheckMessage $lab"
    }
  }
}
#_______________________

proc EG::MessageState {{islock 0}} {
  # Shows current state (lock/unlock) of the week.

  if {$islock || $::EG::D(lockdata)} {
    set msg "The week data changes are locked."
  } else {
    set msg "The week data can be changed."
  }
  Message $msg
}
#_______________________

proc EG::MessageErrorInput {type input} {
  # Message about mistaken input.
  #   type - format
  #   input - value

  Message "Mistaken input for \"$type\" format: $input" 10
  return 0
}
#_______________________

proc EG::StatusBar {item wday} {
  # Displays status bar data.
  #   item - item name
  #   wday - week day

  fetchVars
  set dt [ScanDate]
  set dt [FirstWDay $dt]
  set dt [clock add $dt $wday day]
  set D(Date1) [FormatDate $dt]
  set dtfull [string trim [clock format $dt -format $D(DateUser3)]]
  set dtshort [FormatDateUser $dt]
  [$EGOBJ Labstat1] configure -text $item
  [$EGOBJ Labstat2] configure -text $dtshort
  [$EGOBJ Lfr1] configure -text " \"$item\"  -  $dtfull "
}
#_______________________

proc MessageTags {} {
  # Gets tags for texts shown with messages.
  # Returns "-tags option" for messages.

  lassign [obj csGet] - - - - fS
  set ::EG::textTags [list \
    [list "r" "-font {$::apave::FONTMAINBOLD} -foreground $fS"] \
    [list "b" "-foreground $fS"] \
    [list "link" "openDoc %t@@https://%l@@"] \
    [list "linkChi" "openDoc\
      %t@@https://chiselapp.com/user/aplsimple/repository/expagog/@@"] \
    [list "linkGit" "openDoc %t@@https://github.com/aplsimple/expagog/@@"] \
    [list "linkapl" "openDoc %t@@https://aplsimple.github.io/@@"] \
    [list "linkMIT" "openDoc %t@@https://en.wikipedia.org/wiki/MIT_License@@"] \
    ]
  return {-tags ::EG::textTags}
}
#_______________________

proc EG::msg {type icon message {defb ""} args} {
  # Shows a message and asks for an answer.
  #   type - ok/yesno/okcancel/yesnocancel
  #   icon - info/warn/err
  #   message - the message
  #   defb - default button (for not "ok" dialogs)
  #   args - additional arguments (-title and font's option)
  # For "ok" dialogue, 'defb' is omitted (being a part of args).

  fetchVars
  if {$type eq {ok}} {
    set args [linsert $args 0 $defb]
    set defb {}
  } elseif {$defb eq {}} {
    set defb YES
  }
  lappend defb -centerme [apave::rootModalWindow $WIN]
  lassign [apave::extractOptions args -title {} -noesc 0] title noesc
  if {$title eq {}} {
    switch $icon {
      warn {set title Warning}
      err  {set title Error}
      ques {set title Question}
      default {set title Info}
    }
  }
  set res [$EGOBJ $type $icon $title "\n$message\n" {*}$defb \
    -onclose destroy {*}[MessageTags] -text 1 {*}$args]
  return [lindex $res 0]
}
#_______________________

proc EG::Balloon {msg args} {
  # Shows balloon with message.
  #   msg - message

  fetchVars
  lassign [split [winfo geometry $WIN] x+] w h x y
  set geo "+([expr {$w+$x}]-W-8)+$y"
  ::baltip tip $WIN $msg -geometry $geo -fg white -bg red \
    -pause 1400 -fade 1400 -padx 20 -pady 20 \
    -per10 3000 -font [$EGOBJ boldDefFont] {*}$args
}

# ________________________ App actions _________________________ #

proc EG::FillOpcLists {} {
  # Fills option cascade lists for diagrams.

  fetchVars
  set pitems "{Polygons} Polygon --"
  set litems "{Items}"
  set i 0
  foreach it $D(Items) {
    lappend litems [list [list $it]]
    lappend pitems [list [list \
      "$it -checkvar ::EG::D(poly,$i) -com EG::savePolyFlags"]]
    incr i
  }
  set Opcvar AggrEG
  set OpcItems [list AggrEG Totals -- $litems $pitems]
}
#_______________________

proc EG::ResourceFileName {} {
  # Gets .rc file name.

  fetchVars
  if {$USERFILEPG ne {}} {
    return $USERFILEPG
  } else {
    return [file join $USERDIRPG $TITLE.rc]
  }
}
#_______________________

proc EG::Resource {args} {
  # Sets/gets data of .rc file.
  #   args - list of pairs "name value" to set (if empty, no sets - just gets)

  fetchVars
  set fname [ResourceFileName]
  set ::EG::contRC [apave::readTextFile $fname]
  if {[llength $args]} {
    foreach {opt val} $args {
      if {$val ne {} && $val ne "{}"} {
        dict set ::EG::contRC $opt $val
      } else {
        catch {dict unset ::EG::contRC $opt}
      }
    }
    set contRC {}
    foreach key [dict keys $::EG::contRC] {
      append contRC "$key {[dict get $::EG::contRC $key]}\n"
    }
    WriteTextFile $fname contRC
  }
  return $::EG::contRC
}
#_______________________

proc EG::ResourceData {key args} {
  # Sets/gets data of .rc file by a key.
  #   key - the key
  #   args - the list of pairs "name value" (if set), the flag "-noread" or {}
  # If args is "-noread" or {}, returns value of data.

  if {$args ne "-noread"} {
    if {[llength $args]} {
      return [Resource $key $args]
    }
    Resource
  }
  set res {}
  catch {set res [dict get $::EG::contRC $key]}
  return $res
}
#_______________________

proc EG::ReadEGDFile {fname egdvar} {
  # Reads data of .egd file
  #   fname - file name
  #   egdvar - EGD variable name

  set fcont [apave::readTextFile $fname]
  set err [set errline {}]
  set $egdvar [list]
  foreach line [split $fcont \n] {
    if {[string trimleft $line] eq {}} continue
    if {[catch {dict set $egdvar {*}$line} e] && $err eq {}} {
      set err $e
      set errline $line
    }
  }
  if {$err ne {}} {
    obj ok warn Error "Problems with the data file\
      \n    $fname\nin line\n    $errline\n\n$err"
  }
}
#_______________________

proc EG::OpenDataFile {fname} {
  # Opens data file.
  #   fname - file name

  fetchVars
  if {![file exists $fname]} {
    set fname [file join $USERDIR [file tail $fname]]
  }
  if {![file exists $fname]} {
    obj basicFontSize 11
    InitThemeEG
    set dir [file dirname $fname]
    set res [obj okcancel info {Creating data file} "\n File\
      \n   $fname\n doesn't exist.\
      \n\n Create it in\
      \n   $dir?\n" OK -text 1]
    if {!$res} exit
    catch {file mkdir $dir}
    close [open $fname w]
  }
  set D(FILE) $fname
  ReadEGDFile $fname ::EG::EGD
  set D(TabFiles) [ResourceData TabFiles]
  if {[lsearch -exact $D(TabFiles) $fname]<0} {
    lappend D(TabFiles) $fname
  }
  # Filling main settings
  if {[set _ [CommonData BYWEEK]] in {0 1}} {set byWeek $_}
  if {[set _ [CommonData CUMULATE]] in {0 1}} {set cumulate $_}
  if {[set _ [CommonData COLOR0]] ne {}} {set Colors(fgsel) $_}
  if {[set _ [CommonData COLOR3]] ne {}} {set Colors(bgtex) $_}
  if {[set _ [CommonData COLORRED]] ne {}} {set Colors(Red) $_}
  if {[set _ [CommonData COLORYELLOW]] ne {}} {set Colors(Yellow) $_}
  if {[set _ [CommonData COLORGREEN]] ne {}} {set Colors(Green) $_}
  if {[set _ [CommonData TEXTTAGS]] ne {}} {set D(TextTags) $_}
  if {[set _ [CommonData POLYFLAGS]] ne {}} {set D(poly) $_}
  if {[set _ [CommonData AGGREG]] ne {}} {set D(AggrEG) $_}
  set D(egdDate1) [CommonData EGDDATE1]
  set D(egdDate2) [CommonData EGDDATE2]
  CheckEgdDates
  if {[IsLockedBase]} {set D(Date1) [Date1Seconds]}
  readPolyFlags
  for {set iit 1} {$iit<=$D(MAXITEMS)} {incr iit} {
    if {[set _ [CommonData COLORMY$iit]] ne {}} {set Colors(my$iit) $_}
  }
  set items [CommonData ITEMS]
  set itemstypes [CommonData ITEMSTYPES]
  if {[llength $items] && [llength $itemstypes]} {
    set D(Items) $items
    set D(ItemsTypes) $itemstypes
  }
  set D(Items)      [lrange $D(Items)      0 $D(MAXITEMS)-1]
  set D(ItemsTypes) [lrange $D(ItemsTypes) 0 $D(MAXITEMS)-1]
  if {[lindex $D(Items) end] ne {EG}} {
    lappend D(Items) EG
    lappend D(ItemsTypes) foo
  }
  set D(ItemsTypes) [lreplace $D(ItemsTypes) end end 999] ;# EG's format
  foreach it $D(Items) {
    set itw [expr {min(16,[string length $it]+2)}] ;# +2 for bold font
    if {$ITWIDTH<$itw} {set ITWIDTH $itw}
  }
  GeItemsNumber
}
#_______________________

proc EG::SaveDataFile {{newfile no} {fname ""}} {
  # Saves data file.
  #   newfile - yes for creating new file
  #   fname - file name to save to

  fetchVars
  CommonData ITEMS $D(Items)
  CommonData ITEMSTYPES $D(ItemsTypes)
  CommonData BYWEEK $byWeek
  CommonData CUMULATE $cumulate
  CommonData COLOR0 $Colors(fgsel)
  CommonData COLOR3 $Colors(bgtex)
  CommonData COLORRED $Colors(Red)
  CommonData COLORYELLOW $Colors(Yellow)
  CommonData COLORGREEN $Colors(Green)
  CommonData POLYFLAGS $D(poly)
  CommonData TEXTTAGS $D(TextTags)
  CommonData EGDDATE1 $D(egdDate1)
  CommonData EGDDATE2 $D(egdDate2)
  CommonData AGGREG $D(AggrEG)
  savePolyFlags
  for {set iit 1} {$iit<=$D(MAXITEMS)} {incr iit} {
    CommonData COLORMY$iit $Colors(my$iit)
  }
  if {$fname eq {}} {set fname $D(FILE)}
  set output {}
  foreach key [lsort -decreasing [dict keys $EGD]] {
    if {$newfile && [string match */*/* $key]} continue
    set line [dict get $EGD $key]
    set line [toEOL $line]
    append output $key\ [list $line]\n
  }
  WriteTextFile $fname output
}
#_______________________

proc EG::FileToResource {fname} {
  # Saves file name in .rc file

  Resource FILE $fname
}
#_______________________

proc EG::CheckEgdDates {} {
  # Checks date range of .egd data.

  fetchVars
  if {$D(egdDate1) eq {}} {
    set year [CurrentYear]
    set date1 [lindex [DatesKeys] 0]
    catch {set year [clock format [ScanDatePG $date1] -format %Y]}
    set dt [FirstWDay [ScanDatePG $year/01/01]]
    set D(egdDate1) [FormatDatePG $dt]
  }
  if {$D(egdDate2) eq {}} {
    set dt [ScanDatePG $D(egdDate1)]
    set dt [clock add $dt $::EG::diagr::NDays days]
    set D(egdDate2) [FormatDatePG $dt]
  }
}
#_______________________

proc EG::Date1Seconds {} {
  # Gets current date in seconds.

  fetchVars
  set res [clock seconds]
  set D2 [FormatDatePG $res]
  if {$D2 < $D(egdDate1) || $D2 >= $D(egdDate2)} {
    set keys [lsort [dict keys $EGD */*/*]]
    set D2 [lindex $keys end]
    if {$D2 eq {}} {set D2 $D(egdDate1)}
    catch {set res [ScanDatePG $D2]}
  }
  return $res
}

# ________________________ Menu _________________________ #

proc EG::Actions {} {
  # Handles Actions menu.

  fetchVars
  if {[IsTestMode]} return
  set pmenu $WIN.popupMenu
  set locklab [ConfigLock]
  if {[catch {
    set newmenu 1
    menu $pmenu -tearoff 0
    $pmenu add command -label New... -image mnu_file -compound left \
      -command EG::New -accelerator Ctrl+N
    $pmenu add command -label Open... -image mnu_OpenFile -compound left \
      -command EG::Open -accelerator Ctrl+O
    $pmenu add command -label {Save data} -image mnu_SaveFile -compound left \
      -command EG::Save -accelerator Ctrl+S
    $pmenu add command -label Backup... -image mnu_double -compound left \
      -command EG::Backup
    $pmenu add command -label Merge... -image mnu_download -compound left \
      -command EG::Merge
    $pmenu add separator
    $pmenu add command -label Find... -image mnu_find -compound left \
      -command EG::Find -accelerator Ctrl+F
    $pmenu add command -label $locklab -image mnu_lock -compound left \
      -command EG::SwitchLock -accelerator Ctrl+L
    $pmenu add separator
    $pmenu add command -label Diagram -image mnu_diagram -compound left \
      -command EG::diagr::Draw -accelerator F5
    $pmenu add command -label Statistics... -image mnu_info -compound left \
      -command EG::stat::_run -accelerator F6
    $pmenu add command -label Report... -image mnu_print -compound left \
      -command EG::Report -accelerator F7
    menu $pmenu.notes -tearoff 0
    $pmenu add cascade -label Stickers -menu $pmenu.notes -compound left -image none
    $pmenu add separator
    $pmenu add command -label Preferences... -image mnu_config -compound left \
      -command EG::Preferences
    $pmenu add separator
    $pmenu add command -label Help -image mnu_help -compound left \
      -command EG::Help -accelerator F1
    $pmenu add command -label About... -image mnu_more -compound left \
      -command EG::About
    $pmenu add separator
    $pmenu add command -label Exit -image mnu_exit -compound left \
      -command EG::Exit
  }]} then {
    set newmenu 0
  }
  $pmenu entryconfigure 7 -label $locklab
  obj themePopup $pmenu
  foreach n $NOTESN {
    set opts [list -label "  [note::NoteName $n] " -command "EG::note::_run $n"]
    if {$newmenu} {$pmenu.notes add command {*}$opts}
    set ncolor [note::NoteColor $n]
    if {$ncolor ne {}} {
      lassign [apave::InvertBg $ncolor] fcolor
      lappend opts -foreground $fcolor -background $ncolor
    }
    if {[winfo exists [EG::note::NoteWin $n]]} {
      lappend opts -state disabled
    } else {
      lappend opts -state normal
    }
    catch {$pmenu.notes entryconfigure [incr n -1] {*}$opts}
  }
  lassign [split [winfo geometry $WIN] +] -> x1 y1
  lassign [split [winfo geometry [$EGOBJ BuT_Tool_hamburger]] +x] w h x2 y2
  set X [expr {$x1+$x2+1}]
  set Y [expr {$y1+$y2+$h}]
  tk_popup $pmenu $X $Y
}
#_______________________

proc EG::Preferences {} {
  # Opens Preferences dialog.

  Source pref
  pref::_run
}
#_______________________

proc EG::Open {} {
  # Opens data file.

  fetchVars
  if {[IsTestMode]} return
  set dir [file dirname $D(FILE)]
  set ::EG::D(filetmp) $::EG::D(FILE)
  set types {{{EG Data Files} {.egd} }}
  set fname [$EGOBJ chooser tk_getOpenFile ::EG::D(filetmp) \
    -initialdir $dir -defaultextension .egd -filetypes $types -parent $WIN]
  OpenFile $fname
}
#_______________________

proc EG::OpenFile {fname} {
  # Opens data file.
  #   fname - file name

  fetchVars
  if {$fname ni [list {} $D(FILE)]} {
    if {[file exists $fname]} {
      OpenData $fname -openfile
    } else {
      Message "\"$fname\" doesn't exist" 10
    }
  }
}
#_______________________

proc EG::Save {} {
  # Saves data.

  fetchVars
  [$EGOBJ BuT_Tool_SaveFile] invoke
}
#_______________________

proc EG::Backup {{auto no}} {
  # Saves data file (sort of backup).
  #   auto - "no" to run dialogue, "yes" - to check "auto-backup" and backup

  fetchVars
  after idle EG::SaveAllData
  if {$D(FILEBAK) eq {}} {
    set D(FILEBAK) [file join $USERDIR [string map {. _} [file tail $D(FILE)]].bak]
  }
  if {!$auto} {
    set types {{{EG Backup Files} .bak}}
    lassign [$EGOBJ input {} Backup [list \
      lab "{} {-pady 8} {-t {Backup file name:}}" {} \
      fis "{} {} {-w 60 -filetypes {$types} -defaultextension .bak \
        -title {Backup file}}" "$D(FILEBAK)" \
      chb "{} {-pady 10} {-t {Auto backup at exit}}" $D(AUTOBAK)]] \
      auto fname chauto
    if {$auto} {
      if {$fname eq {}} {
        set auto 0
        Message {No file name supplied}
        after idle EG::Backup
      } else {
        set D(FILEBAK) $fname
        set D(AUTOBAK) $chauto
      }
    }
  }
  if {$auto} {
    SaveDataFile no $D(FILEBAK)
    # additional save of "week day" version
    set wd [clock format [Date1Seconds] -format %u]
    set bak _$wd.bak
    set fname  [file root $D(FILEBAK)]$bak
    SaveDataFile no $fname
    set fname [ResourceFileName]
    set fback [file rootname $fname]_rc$bak
    catch {file copy $fname $fback}
  }
}
#_______________________

proc EG::OpenData {fname args} {
  # Opens data file.
  #   fname - file name

  fetchVars
  SaveDataFile
  $EGOBJ res $WIN 1
  set D(FILE) $fname
  catch {
    set D(egdDate1) $D(NEWFILEDATE1) ;# both are set in "New file" dialogue
    set D(egdDate2) $D(NEWFILEDATE2)
  }
  FileToResource $fname
  set ::argc 1
  set ::argv [list $fname]
  Exit $fname -restart {*}$args
}
#_______________________

proc EG::Find {} {

  Source find
  find::_run
}
#_______________________

proc EG::Report {} {

  Source repo
  repo::_run
}
#_______________________

proc EG::Help {{fhelp EG} args} {
  # Shows help text.
  #   fhelp - name of the help
  #   args - options of message

  fetchVars
  if {$fhelp eq {EG}} {
    set fhelp [file join $DIR README.md]
    if {![catch {set loc [lindex [::msgcat::mcpreferences] 0]}]} {
      set loc [string range $loc 0 1]
      set fhp [file join $DIR doc README_$loc]
      # try to open localized help
      if {[file exists $fhp.md]} {
        set fhelp $fhp.md
      } elseif {[file exists $fhp.txt]} {
        set fhelp $fhp.txt
      }
    }
    set tcltk_version [package require Tk]
    if { [package vsatisfies $tcltk_version 9.0-] } {
      set tmphelp [file join [file tempdir] README.md]
      file copy -force $fhelp $tmphelp
      set fhelp $tmphelp
    }
    openDoc $fhelp
  } else {
    set VersionDate {}
    if {$fhelp eq {about}} {
      set clog [readTextFile [file join $DIR CHANGELOG.md]]
      foreach line [textsplit $clog] {
        lassign [regexp -inline {Version (`.+\(.+\)`)} $line] -> line
        set line [string map {` ""} $line]
        if {$line ne {}} {
          set VersionDate $line
          break
        }
      }
    }
    set fhelp [file join $DATADIR hlp $fhelp.txt]
    set helpcont [string trimright [apave::readTextFile $fhelp]]
    catch {set helpcont [subst $helpcont]} e
    msg ok info $helpcont -title Help {*}$args
  }
}
#_______________________

proc EG::Merge {{doadd no} args} {
  # Merging data files.
  #   doadd - if yes, add selected tabs to merged file list

  fetchVars
  Source merge
  set selfiles [list]
  if {$doadd} {
    set tabs [BAR cget -select]
    if {![llength $tabs]} {
      lappend tabs {*}$args ;# <- right clicked tab
    }
    foreach tab $tabs {
      lassign $tab tid
      set fname [TIDfname $tid]
      if {$D(FILE) ne $fname} {
        lappend selfiles $fname
      }
    }
    if {![llength $selfiles]} {
      Message "To select a tab, press Ctrl & click it. Or right click it." 15
    }
  }
  merge::_run $selfiles
}
#_______________________

proc EG::About {} {

  Help about -title About... -width 30 -height {10 18} -wrap none -minsize {200 300}
}
#_______________________

proc EG::Exit {args} {
  # Handles Exit tool.
  #   args - additional arguments, incl. provided by apave

  fetchVars
  if {[set i [lsearch -exact $args -openfile]]>=0} {
    set args2 [lrange $args $i+1 end]
    set args [lrange $args 0 $i]
  } else {
    set args2 {}
  }
  SaveAll {*}$args
  if {$D(AUTOBAK)} {Backup yes}
  catch {$EGOBJ destroy}
  if {"-restart" in $args} {
    exec -- [info nameofexecutable] $SCRIPT {*}$::argv {*}$args2 &
  }
  exit
}

## ________________________ New... _________________________ ##

proc EG::New {} {
  # Runs New file dialog.

  fetchVars
  set types {}
  set D(NEWFILE) [CloneFileName $D(FILE)]
  set dt [ScanDatePG $D(egdDate2)]
  set D(NEWFILEDATE1) [FormatDatePG [FirstWDay $dt]]
  set dt [ScanDatePG $D(NEWFILEDATE1)]
  set D(NEWFILEDATE2) [FormatDatePG [clock add $dt $::EG::diagr::NDays days]]
  set pobj [set D(NEWFILEPOBJ) ::apave::pavedObj_newfile]
  set win $WIN.newfile
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra "New EG data file"
  $pobj paveWindow $win.fra {
    {fra1 - - - - {-st nsew -pady 16}}
    {.lab - - - - {-pady 0} {-t {File name:}}}
    {.fis + L 1 99 {-pady 0} {-w 60 -filetypes {{{EG Data Files} {.egd}}}
      -defaultextension .egd -title {New file} -tvar ::EG::D(NEWFILE)}}
    {.v_ + T 1 1 {-pady 8}}
    {.labegdD1 + T 1 1 {-st w} {-t "Week range:    \["}}
    {.EntegdD1 + L 1 1 {-st w} {-tvar ::EG::D(NEWFILEDATE1) -w 11 -justify center
      -state disabled -onevent {<Button> {::EG::SelEgdDate 1}}}}
    {.labspc + L 1 1 {-st w -padx 0} {-t {  -  }}}
    {.EntegdD2 + L 1 1 {-st w -padx 0} {-tvar ::EG::D(NEWFILEDATE2) -w 11 -justify center
      -state disabled -onevent {<Button> {::EG::SelEgdDate 2}}}}
    {.labspc2 + L 1 1 {-st w -padx 0} {-t \)}}
    {seh fra1 T 1 5 {-pady 8 -st ew -cw 1}}
    {frabot + T 1 5 {-st ew} {}}
    {.butHelp - - - - {pack -side left}
      {-text Help -com {EG::Help newfile -width 61} -takefocus 0}}
    {.h_ + L 1 1 {pack -side left -expand 1 -fill x}}
    {.butOK + L 1 1 {pack -side left} {-t OK -com {EG::NewFileButton 1}}}
    {.butCancel + L 1 1 {pack -side left -padx 4} {-t Cancel
      -com {EG::NewFileButton 0}}}
  }
  bind $win <F1> {EG::Help newfile -width 61}
  set res [$pobj showModal $win -resizable 0 -escape 1 \
    -onclose destroy -focus $win.fra.fra1.entfis]
  catch {destroy $win}
  $pobj destroy
  if {$res && [set fname [string trim $D(NEWFILE)]] ne {}} {
    if {[file exists $fname]} {
      Message "File $fname already exists."
    } else {
      OpenData $fname -newfile
    }
  }
  unset D(NEWFILE)
  unset D(NEWFILEDATE1)
  unset D(NEWFILEDATE2)
  unset D(NEWFILEPOBJ)
}
#_______________________

proc EG::NewFileButton {res} {
  # Handles OK / Cancel of "New file" dialogue.
  #   res - result of dialogue

  fetchVars
  $D(NEWFILEPOBJ) res $WIN.newfile $res
}
#_______________________

proc EG::SelEgdDate {ndate} {
  # Date chooser for D(NEWFILEDATE1) / D(NEWFILEDATE2).
  #   ndate - date number (1 or 2)

  fetchVars
  if {$ndate==1} {set ttl {Week first}} {set ttl {Week last}}
  set ent [$D(NEWFILEPOBJ) EntegdD$ndate]
  ChooseDay ::EG::D(NEWFILEDATE$ndate) -entry $ent -title $ttl -dateformat $D(DatePG)
  if {$ndate==1} CheckEgdDate1 CheckEgdDate2
}
#_______________________

proc EG::CheckEgdDate1 {} {
  # Checks 1st .egd date against the last.

  fetchVars
  set dt [FirstWDay [ScanDatePG $D(NEWFILEDATE1)]]
  set D(NEWFILEDATE1) [FormatDatePG $dt]
  set dt [clock add $dt $::EG::diagr::NDays days]
  set egdDate2 [FormatDatePG $dt]
  if {$D(NEWFILEDATE1)>$D(NEWFILEDATE2) || $D(NEWFILEDATE2)>$egdDate2} {
    set D(NEWFILEDATE2) $egdDate2
    Message "Week range's Date2 is set to $egdDate2"
  } elseif {$D(NEWFILEDATE2) != $egdDate2} {
    Message "Week range's Date2 is advised to be $egdDate2"
  }
}
#_______________________

proc EG::CheckEgdDate2 {} {
  # Checks last .egd date against the first.

  fetchVars
  set dt [FirstWDay [ScanDatePG $D(NEWFILEDATE2)]]
  set D(NEWFILEDATE2) [FormatDatePG $dt]
  set dt [clock add $dt -$::EG::diagr::NDays days]
  set egdDate1 [FormatDatePG $dt]
  if {$D(NEWFILEDATE1)>$D(NEWFILEDATE2) || $D(NEWFILEDATE1)<$egdDate1} {
    set D(NEWFILEDATE1) $egdDate1
    Message "Week range's Date1 is set to $egdDate1"
  } elseif {$D(NEWFILEDATE1) != $egdDate1} {
    Message "Week range's Date1 is advised to be $egdDate1"
  }
}
#_______________________

proc EG::CloneFileName {fname} {
  # Gets a clone's name.
  #   fname - file name
  # Returns the clone's file name.

  set tailname [file tail $fname]
  set ext [file extension $tailname]
  set root [file rootname $tailname]
  # possibly existing suffix in the filename
  set suffix {_\d+$}
  set suff [regexp -inline $suffix $root]
  set root [string range $root 0 end-[string length $suff]]
  set i1 2
  set i2 99
  if {$suff eq {}} {set suff _$i1}
  # find the free suffix for the clone
  for {set i $i1} {$i<=$i2} {incr i} {
    set suff [string map [list {\d+} $i \$ {}] $suffix]
    set fname2 [file join [file dirname $fname] $root$suff$ext]
    if {![file exists $fname2]} break
  }
  return $fname2
}

# ________________________ Main _________________________ #

proc EG::Init {} {
  # Open data file and initializes the app's data.

  global argv argc
  fetchVars
  set fileegd [CurrentYear].egd
  set i [lsearch -exact $argv -test]
  if {$i>=0} {
    set TestMode 1
    set argv [lreplace $argv $i $i]
  }
  set i1 [lsearch -exact $argv -item]
  set i2 [lsearch -exact $argv -date]
  if {$i1>=0 && $i2>=0} {
    set InpItem [lindex $argv $i1+1]
    set InpDate [lindex $argv $i2+1]
    set argv [lrange $argv 0 $i1-1]
  }
  set argc [llength $argv]
  set err no
  switch $argc {
    0 {
      set fdefault [file join $USERDIR $fileegd]
      set rc [Resource]
      if {[catch {set fname [dict get $rc FILE]}] || $fname eq {}} {
        set fname $fdefault
      } else {
        if {![file exists [file dirname $fname]]} {
          set fname $fdefault  ;# foreign .rc ?
        }
      }
    }
    1 - 2 - 3 {
      lassign $argv arg1 arg2 arg3
      set fname [file normalize $arg1]
      # at starting by EG executable (see EG::Exit)
      if {$argc==2} {
        if {[file tail $arg1] eq {EG.tcl}} {
          set fname [file normalize $arg2]      ;# run by EG executable
        } else {
          set USERDIRPG [file normalize $arg2]  ;# 2nd arg is .rc directory
          set rc [Resource]
        }
      } elseif {$argc==3} {
        if {[file tail $arg1] eq {EG.tcl}} {
          set fname [file normalize $arg2]      ;# run by EG executable
          set USERDIRPG [file normalize $arg3]  ;# 3rd arg is .rc directory
          set rc [Resource]
        } else {
          set err yes
        }
      }
      if {[file isfile $USERDIRPG]} {
        set USERFILEPG $USERDIRPG
        set USERDIRPG [file dirname $USERDIRPG]
      }
    }
    default {
      set err yes
    }
  }
  if {$err} {
    puts "$::EG::TITLE is run so:\n\n  tclsh [file tail $SCRIPT] ?NAME?\
      \n  where NAME is a data file (e.g. 2025.egd) or a directory of data files.\
      \n\nLook README.md for details."
    exit
  }
  if {[file isdirectory $fname]} {
    set USERDIR $fname
    set rc [Resource]
    if {[catch {set fname [dict get $rc FILE]}] || ![file exists $fname]} {
      set fname [file join $fname $fileegd]
    }
  } else {
    set USERDIR [file dirname $fname]
  }
  OpenDataFile $fname
  FileToResource $fname
  if {[obj csDark]} {
    set D(Theme) darkbrown
    set D(CS) 29
  } else {
    set D(Theme) lightbrown
    set D(CS) 4
  }
  if {[set _ [ResourceData DATEUSER]] ne {}} {set D(DateUser) $_}
  if {[set _ [ResourceData DATEUSER2]] ne {}} {set D(DateUser2) $_}
  if {[set _ [ResourceData DATEUSER3]] ne {}} {set D(DateUser3) $_}
  if {[set _ [ResourceData THEME]] ne {}} {set D(Theme) $_}
  if {[set _ [ResourceData CS]] ne {}} {set D(CS) $_}
  if {[set _ [ResourceData HUE]] ne {}} {set D(Hue) $_}
  set D(FILEBAK) [ResourceData FILEBAK]
  set D(AUTOBAK) [string is true -strict [ResourceData AUTOBAK]]
  set D(NoteOnTop) [string is true -strict [ResourceData NoteOnTop]]
  set D(Zoom) [ResourceData Zoom]
  if {$D(Zoom)<0 || $D(Zoom)>16} {set D(Zoom) 3}
  set fs [expr {8+$D(Zoom)}]
  if {[set D(DefFont) [ResourceData DefFont]] ne {}} {
    catch {dict set D(DefFont) -size $fs}
    foreach font {TkDefaultFont TkMenuFont TkHeadingFont TkCaptionFont} {
      if {[catch {font configure $font {*}$D(DefFont)}]} {
        set D(DefFont) {}
      }
    }
    if {$D(DefFont) ne {}} {
      obj basicDefFont $D(DefFont)
      set smallfont $D(DefFont)
      if {![catch {dict set smallfont -size [expr {$fs-2}]}]} {
        ::baltip::configure -font $smallfont
        foreach font {TkSmallCaptionFont TkIconFont TkTooltipFont} {
          if {[catch {font configure $font {*}$smallfont}]} {
            set smallfont {}
          }
        }
      }
    }
  }
  if {[set D(TexFont) [ResourceData TexFont]] eq {}
  || [catch {dict set D(TexFont) -size $fs}]} {
    set D(TexFont) [obj basicTextFont]
  }
  obj basicTextFont $D(TexFont)
  obj basicFontSize $fs
  obj basicDefFont [list {*}[obj basicDefFont] -size $fs]
  obj basicSmallFont [list {*}[obj basicSmallFont] -size [expr {$fs-2}]]
  set D(MsgFont) [list -font [list {*}[obj basicSmallFont] -weight bold] \
    -foreground $Colors(fgsel)]
  apave::initBaltip
  InitThemeEG
  if {$D(Hue)} {obj csToned $D(CS) $D(Hue) yes}
  apave::iconImage -init $ICONTYPE yes
  set ::EG::img_arrleft [apave::iconImage previous]
  set ::EG::img_arrright [apave::iconImage next]
  set ::EG::img_diagram [apave::iconImage diagram]
  set defattr "-font {$::apave::FONTMAIN}"
  obj defaultATTRS laB {} $defattr
  obj defaultATTRS enT {} $defattr
  obj defaultATTRS tex {} $defattr
  lassign [obj csGet] 1 Colors(fg) Colors(bg2) Colors(bg) Colors(fgit) 6 7 8 \
    Colors(grey) Colors(fghot) 11 12 13 Colors(bg3)
  foreach icon $D(Icons) {
    image create photo Tool_$icon -data [apave::iconData $icon $ICONTYPE]
  }
  foreach icon {none lamp ques yes no -info -color -lock -find -config -diagram
  -help -exit -OpenFile -SaveFile -double -more -file -print -download -undo} {
    set img [string map {- mnu_} $icon]
    set ico [string map {- {}} $icon]
    image create photo $img -data [apave::iconData $ico small]
  }
  apave::initStylesFS
  set fd [FirstWDay]
  set D(WeekDays) [list]
  foreach d {0 1 2 3 4 5 6} {
    set dt [clock add $fd $d day]
    lappend D(WeekDays) [clock format $dt -format %a]
  }
  set D(lockdata) 0
  set D(toformat) {}
  set itwidth [MaxItemWidth]
  FillOpcLists
}
#_______________________

proc EG::MaxItemWidth {} {
  # Gets maximum width of items.

  set wmax 5 ;# for times
  foreach typ $::EG::D(ItemsTypes) {
    switch -glob -- $typ {
       calc* {lassign [split $typ :] - typ}
       9* {}
       default {continue}
    }
    set w [string length $typ]
    if {$w>$wmax} {set wmax $w}
  }
  expr {min(10,$wmax)} ;# limit the width
}
#_______________________

proc EG::_create {} {
  # Creates the app's main window.

  fetchVars
  obj untouchWidgets *.laBI*
  apave::APave create $EGOBJ $WIN
  set fontSmall [list {*}[$EGOBJ basicSmallFont] -weight bold]
  $EGOBJ makeWindow $WIN.fra "EG - $D(FILE)"
  $EGOBJ paveWindow $WIN.fra {
    {Fratop - - 1 3 {-st we} }
    #####-tool-bar
    {.tool - - - - {pack -side top} {-relief flat -borderwidth 0 -array {
      Tool_hamburger {EG::Actions -tip "Actions\nF10@@ -under 5"}
      sev 4
      Tool_SaveFile {{after idle EG::SaveAll} -tip "Save data\nCtrl+S@@ -under 5"}
      Tool_info {EG::stat::_run -tip "Statistical info\nF6@@ -under 5"}
      Tool_print {EG::Report -tip "Report\nF7@@ -under 5"}
      sev 4
      Tool_previous2 {{EG::MoveToWeek -28} -tip "Previous 4 weeks@@ -under 5"}
      Tool_previous {{EG::MoveToWeek -7} -tip "Previous week@@ -under 5"}
      h_ 1
      EntDate {-w 11 -justify center -tvar ::EG::D(Date1)
        -tip "Click to choose a week@@ -under 5" -state readonly
        -onevent {<Button> EG::ChooseWeek}}
      h_ 1
      Tool_next {{EG::MoveToWeek 7} -tip "Next week@@ -under 5"}
      Tool_next2 {{EG::MoveToWeek 28} -tip "Next 4 weeks@@ -under 5"}
      sev 4
      Tool_date {EG::ChooseWeek -tip "Choose a week\nCtrl+D@@ -under 5"}
      Tool_home {EG::MoveToDay -tip "To the current day\nCtrl+H@@ -under 5"}
      Tool_find {EG::Find -tip "Find in texts\nCtrl+F@@ -under 5"}
      sev 4
      Tool_lock {EG::SwitchLock -tip "Unlock changes\nCtrl+L@@ -under 5"}
      lab {"" {-expand 1 -fill x}}
      Tool_exit {EG::Exit -tip "Exit@@ -under 5"}
    }}}
    #####-frame-of-items
    {Fral fratop T 4 1 {-st nswe -pady 4}}
    {fral.Frabts fratop T 1 1 {pack -fill x}}
    {.btsBar  - - - - {pack -fill x}}
    {fral.fra - - - - {pack}}
    {.tcl {
      # heading: week days
      %C ".LaBIh - - - - {-st ews -pady 0 -padx 0} {-t {} -w $::EG::ITWIDTH\
        -fg $::EG::Colors(fghot) -bg $::EG::Colors(bg)}"
      for {set i 0} {$i<7} {incr i} {
        %C ".LaBIh$i + L 1 1 {-st ews} {-t [lindex $::EG::D(WeekDays) $i]\
        -anchor center -fg $::EG::Colors(fghot) -bg $::EG::Colors(bg)\
        -onevent {<ButtonPress-3> {EG::PopupOnWeekTitle $i %X %Y}}\
        -tip {Right click to clear}}"
      }
      set n .laBIh
      # cells of items
      foreach item $::EG::D(Items) typ $::EG::D(ItemsTypes) {
        if {$item eq {EG}} {
          %C ".seheg $n T 1 8 {-st ew -pady 4}"
          set n .seheg
        }
        # item name and its normalized version
        set it [EG::NormItem $item]
        %C ".LaBI$it $n T - - {-st ews} {-t {$item } -anchor w}"
        # item values day by day
        for {set i 0} {$i<7} {incr i} {
          if {$typ eq {chk}} {
            set n BuTSTD$it$i
            set atr "-image none -compound center -com"
          } else {
            set n EnTSTD$it$i
            set atr "-textvar ::EG::D($it$i) -justify center -w $::EG::itwidth\
              -validate key -validatecommand"
          }
          set ::EG::D(fld$it,$i) $n
          set lwid ".$n + L 1 1 {-st ewn} {$atr {EG::ValidIt $n {$typ} {$item}\
            $i %P %V} -onevent {<FocusIn> {EG::FocusedIt {$item} $i; EG::SelIt}\
            <FocusOut> {EG::StoreItem; EG::SelIt -1}\
            <KeyPress> {EG::KeyPress %W %K %s {$item} $i}\
            <ButtonPress-3> {EG::PopupOnItem %W %X %Y}} -tip {-BALTIP ! -COMMAND\
            {EG::CellTip $it $i} -UNDER 2 -PER10 999999}}"
          %C $lwid
        }
        set n .LaBI$it
      }
      # end of .tcl
    }}
    #####-comments-on-cell
    {.h_ + T 1 1 {-pady 4}}
    {fral.Lfr1 - - - - {pack -expand 1 -fill both} {-t { } -labelanchor n}}
    {fral.lfr1.Text - - - - {pack -side left -expand 1 -fill both}
      {-wrap word -h 4 -w 10 -tabnext {*.textR}
      -onevent {<FocusIn> EG::StoreItem <<Modified>> {+ EG::StoreText}
      <KeyRelease> {+ EG::StoreText} <FocusOut> {+ EG::StoreText; EG::ShowTable}}}}
    {fral.lfr1.sbv fral.lfr1.text L - - {pack -side left}}
    #####-right-frame
    {sev fral L 4 1 {-st ns -padx 4}}
    {LabWeekRange + L 1 1 {-st we} {-anchor center}}
    {fraTtl + T 1 1 {-st nswe -cw 1}}
    {.LabTtl - - - - {pack -side left -expand 1 -fill x} {-anchor center}}
    {.EntTtl - - - - {pack forget -expand 1 -fill x -side left}
      {-tvar ::EG::D(AggrEG) -w 50 -takefocus 0
      -onevent {<FocusOut> {EG::CheckAggrEG; EG::diagr::Draw}}
      -tip "AggrEG formula\n___________________\nAfter change\npress Enter to save"}}
    #####-diagram
    {frar1 fraTtl T 1 7 {-st nwe}}
    {.Can - - - - {pack -expand 1 -fill both -side top} {-w 70 -h 360 -closeenough 0.0}}
    {.frar2 - - - - {pack -side bottom -fill x -pady 2}}
    {.frar2.btT - - - - {-st w}
      {-image $::EG::img_diagram -com EG::diagr::Draw -tip "Redraw diagram\nF5"}}
    {.frar2.btT1 + L 1 1 {-st w} {-image $::EG::img_arrleft
      -com {EG::diagr::Scroll -4} -tip "Move left"}}
    {.frar2.btT2 + L 1 1 {-st w} {-image $::EG::img_arrright
      -com {EG::diagr::Scroll 4} -tip "Move right"}}
    {.frar2.opc1 + L 1 1 {-st w -padx 20} {::EG::Opcvar ::EG::OpcItems {-width -4
      -takefocus 0} {EG::opcPre {%a}} -command EG::opcPost}}
    {.frar2.chbW + L 1 1 {-st w} {-t weeks -var ::EG::byWeek
      -com EG::diagr::Draw -takefocus 0}}
    {.frar2.chb + L 1 1 {-st w -padx 20} {-t cumulate
      -var ::EG::cumulate -takefocus 0 -com EG::diagr::Draw}}
    #####-comments-on-diagram-and-all
    {Lfr2 frar1 T 1 1 {-st nswe -cw 1 -rw 99 -pady 4} {-t Weekly -labelanchor n}}
    {.TextR - - - - {pack -side left -expand 1 -fill both}
      {-wrap word -h 4 -w 8 -tip "Comments on the week" -tabnext {[EG::FirstCell]}
      -onevent {<<Modified>> {+ EG::StoreTextR}
      <KeyRelease> {+ EG::StoreTextR} <FocusOut> {+ EG::StoreTextR}}}}
    {.sbvR .textR L - - {pack -side left}}
    #####-status-bar
    {fras fral T 1 3 {-st we}}
    {.stat - - - - pack {-array {
      {"Topic:" -font "$fontSmall" -foreground $::EG::Colors(fghot)
        -padding {0 0} -anchor center} 10
      {" Day:" -font "$fontSmall" -foreground $::EG::Colors(fghot)
        -padding {0 0} -anchor center} 7
      {"" -padding {0 0} -anchor w -expand 1} 1
    }}}
  }
  update
  apave::setAppIcon $WIN $::EG::EGICON
  CurrentItemDay $InpItem $InpDate
  ColorItemLabels
  [$EGOBJ LabWeekRange] configure -foreground $Colors(fgit) \
    -text "\[ $D(egdDate1)  -  $D(egdDate2) \)"
  ::baltip tip [$EGOBJ Text] Comments -command EG::TextTip
  set C [$EGOBJ Can]
  set W [winfo reqwidth $WIN]
  set H [winfo reqheight $WIN]
  after idle EG::FillBar
  after idle after 100 "wm minsize $WIN $W $H; EG::HighlightEG"
  after idle after 400 \
    "EG::CheckCurrentWeek; EG::diagr::Title;\
    EG::ShowTable 1; EG::AfterWeekSwitch; after 300 {EG::diagr::Draw 1}"
  bind $WIN <F1> EG::Help
  bind $WIN <F5> EG::diagr::Draw
  bind $WIN <F6> EG::stat::_run
  bind $WIN <F7> EG::Report
  bind $WIN <F10> EG::Actions
  set geo [ResourceData Geometry]
  if {$geo ne {}} {
    set geo [list -geometry [apave::checkGeometry $geo]]
  }
  after 100 EG::note::OpenNotes
  if {[IsTestMode]} {
    after 500 [list EG::Balloon \
      "Test mode.\n\nClose this EG\nafter testing."]
  }
  $EGOBJ showModal $WIN -onclose EG::Exit -escape no {*}$geo
}
#_______________________

proc EG::_run {} {
  # Prepares, runs and ends the app.

  if {[set _ [lsearch -glob $::argv LOG=*]]>-1} {
    set ::EG::LOG [string range [lindex $::argv $_] 4 end]
    apave::logName $::EG::LOG
    apave::logMessage "START ------------"
    set ::argv [lreplace $::argv $_ $_]
    set ::argc [llength $::argv]
  }
  Init
  _create
  Exit
}

# ________________________ Run this _________________________ #

# if {"-test" ni $::argv} {source [apave::HomeDir]/PG/github/DEMO/expagog/demo.tcl} ;#! for demo

EG::_run

# ________________________ EOF _________________________ #
