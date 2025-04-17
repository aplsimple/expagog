#! /usr/bin/env tclsh
###########################################################
# Name:    find.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jan 30, 2025
# Brief:   Handles searching for EG tags & texts.
# License: MIT.
###########################################################

# _________________________ find ________________________ #

namespace eval find {
  variable win $::EG::WIN.find
  variable pobj ::EG::find::pobj
  variable findString {}
  variable chkList 0
  variable chkCase 0
  variable chkAll 0
  variable foundList [list]
  variable Opcvar
  variable OpcItems
  variable fgeom {}
}
#_______________________

proc find::opcPre {args} {

  set clr [lindex $args 0]
  if {$clr in {Red Yellow Green}} {
    set bg $::EG::Colors($clr)
    lassign [apave::InvertBg $bg] fg
    return "-background $bg -foreground $fg"
  }
  return {}
}
#_______________________

proc find::opcPost {} {

  variable findString
  variable Opcvar
  if {$Opcvar ni [split $findString]} {
    append findString " $Opcvar"
    set findString [string trim $findString]
  }
}
#_______________________

proc find::Fname2Tab {fname} {
  # Translates file name to tab name.
  #   fname - file name

  set res [file tail $fname]
  foreach tab [EG::BAR listTab] {
    lassign $tab tid tname
    if {$fname eq [EG::BAR $tid cget -tip]} {
      set res $tname
      break
    }
  }
  return $res
}
#_______________________

proc find::Tab2Fname {tabname} {
  # Translates tab name to file name.
  #   tabname - tab name

  set res $tabname
  foreach tab [EG::BAR listTab] {
    lassign $tab tid tname
    if {$tname eq $tabname} {
      set res [EG::BAR $tid cget -tip]
      break
    }
  }
  return $res
}
#_______________________

proc find::FillOpcLists {} {
  # Fills option cascade list.

  variable Opcvar
  variable OpcItems
  set OpcItems [list Red Yellow Green --]
  set litems "{Tags}"
  set tags [lsort -dictionary -nocase [split $::EG::D(TextTags)]]
  set itag -1
  foreach it $tags {
    if {[incr itag]%$::EG::TAGOPCLEN==0 && $itag} {
      lappend OpcItems $litems
      set litems "{... [string toupper [string index $it 0]]}"
    }
    lappend litems [list [list $it]]
  }
  lappend OpcItems $litems
  set Opcvar Red
}
#_______________________

proc find::KeyOnTree {K X Y B} {
  # Handles key/button event on treeview.
  #   K - key
  #   X - x-coordinate of pointer
  #   Y - y-coordinate of pointer
  #   B - button clicked

  variable foundList
  variable pobj
  set wtree [$pobj Tree]
  if {$K ni {Return space} && $B!=1} return
  if {$B==1} {
    # button click
    if {[$wtree identify region $X $Y] ni {cell tree}} return
    set tID [$wtree identify item $X $Y]
  } else {
    # key press
    set tID [$wtree selection]
  }
  if {[catch {set sel [$wtree index $tID]}]} return
  if {[string is digit -strict $sel]} {
    set cursel [lindex $foundList $sel]
    lassign [split $cursel] date item
    set curlist [split $cursel \t]
    if {[llength $curlist]>1} {
      set fname [Tab2Fname [lindex $curlist end]]
      if {[file exist $fname]} {
        if {[EG::IsTestMode]} return
        SaveOptions
        EG::OpenData $fname -openfile -item $item -date $date
        return
      }
    }
    EG::CurrentItemDay $item $date
    EG::MoveToWeek 0 [EG::ScanDatePG $date]
  }
}
#_______________________

proc find::Help {} {
  # Shows help on Find dialogue.

  variable win
  EG::Help find -width 57 -height 32 -parent $win
}
#_______________________

proc find::SaveOptions {} {
  # Saves options and dialog's geometry.

  variable win
  variable chkList
  variable findString
  variable chkCase
  set fgeom [wm geometry $win]
  EG::ResourceData FindOptions $findString $chkList $chkCase $fgeom
}
#_______________________

proc find::OK {} {

  variable win
  variable pobj
  variable chkList
  variable chkAll
  variable foundList
  variable findString
  set findString [string trim $findString]
  SaveOptions
  if {$findString eq {}} {
    bell
    EG::Message "Enter what to search."
    apave::focusByForce [$pobj EntFind]
    return
  }
  EG::Message "Wait please..." 10
  set wtree [$pobj Tree]
  set treeid 0
  set delti [list]
  foreach flit $foundList {lappend delti ti[incr treeid]}
  catch {$wtree delete $delti}
  set foundList [list]
  if {$chkList} {set what [split $findString]} {set what {}}
  set egdinfo [list [list $::EG::D(FILE) {}]]
  if {$chkAll} {
    foreach tab [EG::BAR listTab] {
      set tid [lindex $tab 0]
      set fname [EG::BAR $tid cget -tip]
      if {$fname ne $::EG::D(FILE)} {
        set egdvar ::EG::find::egd_tmp[incr itab]
        EG::ReadEGDFile $fname $egdvar
        lappend egdinfo [list $fname $egdvar]
      }
    }
  }
  foreach egdi $egdinfo {
    lassign $egdi fname egdvar
    if {$egdvar eq {}} {set fname {}} {set fname "\t[Fname2Tab $fname]"}
    set dkeys [EG::DatesKeys {} {} 0 $egdvar]
    EG::ForEach {} $dkeys {
      lassign [split %k {}] k d
      set typ %t
      switch -glob -- $typ {
        9* - calc* - time - chk - {} {}
        default {
          set k t ;# search in text cells
        }
      }
      if {$k eq {t} && [string is digit -strict $d]} {
        set date [clock add [EG::ScanDatePG %d] $d day]
        set date [EG::FormatDatePG $date]
        set value [EG::fromEOL %v]
        Found %i $date $value $what $fname
      }
    } $egdi
  }
  set foundList [lsort -dictionary -nocase $foundList]
  set treeid 0
  foreach flit $foundList {
    lassign [split $flit \t] date item where fname
    set tID ti[incr treeid]
    set where [string map [list \n { }] $where]
    $wtree insert {} end -id $tID -values [list [file rootname $fname] $date $where]
    if {$treeid==1} {set tID1 $tID}
  }
  catch {
    $wtree selection set $tID1
    $wtree focus $tID1
    focus $wtree
  }
  set lfr [$pobj Lfra]
  if {![winfo ismapped $lfr]} {
    pack $lfr -expand 1 -fill both
  }
  EG::Message ""
}
#_______________________

proc find::Found {item date where what fname} {
  # Search in string.
  #   item - item name
  #   date - date of week
  #   where - string where to search
  #   what - list of "what to find" words at searching by list
  #   fname - egd file name or {}

  variable chkCase
  variable chkList
  variable findString
  if {$chkCase} {set opt {}} {set opt -nocase}
  if {$chkList} {
    set what [string trim $what]
    foreach word1 [split $where] {
      if {$word1 ne {}} {
        foreach word2 [split $what] {
          if {[string match {*}$opt *$word2* $word1]} {
            AddFoundInfo $item $date $word1 $fname
          }
        }
      }
    }
  } else {
    if {[string match {*}$opt *$findString* $where]} {
      AddFoundInfo $item $date $where $fname
    }
  }
}
#_______________________

proc find::AddFoundInfo {item date where fname} {
  # Logs found info to the found list.
  #   item - item name
  #   date - week date where search was successful
  #   where - text where search was successful
  #   fname - egd file name or {}

  variable foundList
  if {[lsearch -glob $foundList "$date\t$item\t*$fname"]<0} {
    lappend foundList "$date\t$item\t$where$fname"
  }
}
#_______________________

proc find::Cancel {args} {
  # Closes Find dialog.

  variable win
  variable pobj
  $pobj res $win 0
}
#_______________________

proc find::_create {} {
  # Creates and opens Find dialog.

  variable win
  variable pobj
  variable findString
  variable chkList
  variable chkCase
  if {[winfo exists $win]} {
    focus $win
    catch {
      set wtree [$pobj Tree]
      focus $wtree
      $wtree focus [$wtree selection]
    }
    return
  }
  lassign [EG::ResourceData FindOptions] findString chkList chkCase fgeom
  set chkList [string is true -strict $chkList]
  set chkCase [string is true -strict $chkCase]
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra {Search in texts}
  $pobj paveWindow $win.fra {
    {lab1 - - - - {-st e -padx 2 -pady 4} {-t Find:}}
    {EntFind + L 1 3 {-st w -pady 4 -cw 1} {-tvar ::EG::find::findString -w 50}}
    {lab2 lab1 T 1 1 {-st e -padx 2 -pady 4} {-t Tags:}}
    {Opc1 + L 1 1 {-st w -pady 4} {::EG::find::Opcvar ::EG::find::OpcItems {-width 10}
      {EG::find::opcPre {%a}} -command EG::find::opcPost}}
    {fra1 lab2 T 1 4 {-st ew}}
    {.lab3 - - - - {-st e -padx 2} {-t {As tags:}}}
    {.chb + L 1 1 {-st w} {-var ::EG::find::chkList}}
    {.h_ + L 1 1 {-st ew -padx 9}}
    {.lab4 + L 1 1 {-st e -padx 2} {-t {Match case:}}}
    {.chb2 + L 1 1 {-st w} {-var ::EG::find::chkCase}}
    {.h_2 + L 1 1 {-st ew -padx 9}}
    {.LabAll + L 1 1 {-st e -padx 2} {-t {In all:}}}
    {.ChbAll + L 1 1 {-st w} {-var ::EG::find::chkAll}}
    {fra2 fra1 T 1 4 {-st nswe -pady 4 -rw 111}}
    {fra2.Lfra - - - - {pack forget -expand 1 -fill both} {-t Found: -labelanchor n}}
    {.Tree - - - - {pack -side left -fill both -expand 1} {
      -selectmode browse -show headings -columns {L1 L2 L3}
      -columnoptions "L1 {-width 20} L2 {-width 50}"}}
    {.sbv + L - - {pack -fill y}}
    {seh fra2 T 1 4 {-st ew -pady 4}}
    {frabot + T 1 4 {-st ew} {}}
    {.ButHelp - - - - {pack -side left}
      {-text Help -com EG::find::Help -takefocus 0}}
    {.LaBMess + L 1 1 {pack -side left -expand 1 -fill x}}
    {.ButOK + L 1 1 {pack -side left} {-text Find -com EG::find::OK}}
    {.butCancel + L 1 1 {pack -side left -padx 4} {-text Cancel
      -com EG::find::Cancel}}
  }
  EG::TabFilesArray
  set wtree [$pobj Tree]
  if {![EG::IsTabFiles]} {
    [$pobj LabAll] configure -state disabled
    [$pobj ChbAll] configure -state disabled
  }
  $wtree heading #1 -text File
  $wtree heading #2 -text Date
  $wtree heading #3 -text {Found string}
  foreach ev {KeyPress ButtonPress} {
    bind $wtree <$ev> {+ EG::find::KeyOnTree %K %x %y %b}
  }
  bind $win <F1> EG::find::Help
  if {$fgeom ne {}} {set fgeom [list -geometry $fgeom]}
  $pobj showModal $win -modal no -parent $::EG::WIN -onclose EG::find::Cancel \
    -resizable 1 -minsize {350 250} -focus Tab -escape 1 {*}$fgeom
  catch {SaveOptions}
  catch {destroy $win}
  catch {$pobj destroy}
}
#_______________________

proc find::_run {args} {
  # Runs Find dialog.

  after idle EG::SaveAllData
  FillOpcLists
  _create
}
