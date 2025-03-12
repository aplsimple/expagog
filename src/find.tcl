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

proc find::ListboxSelect {w {checkit no}} {
  # Handles a selection event of the foundList listbox.
  #   w - listbox's path
  #   checkit - flag to check for the repeated calls of this procedure

  variable foundList
  set sel [lindex [$w curselection] 0]
  if {[string is digit -strict $sel]} {
    lassign [split [lindex $foundList $sel]] date item
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
  if {$chkList} {set what [split $findString]} {set what {}}
  set foundList [list]
  set dkeys [EG::DatesKeys {} {} 0]
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
      Found %i $date $value $what
    }
  }
  set foundList [lsort -dictionary -nocase $foundList]
  set lfr [$pobj Lfra]
  if {![winfo ismapped $lfr]} {
    pack $lfr -expand 1 -fill x
  }
  EG::Message ""
}
#_______________________

proc find::Found {item date where what} {
  # Search in string.
  #   item - item name
  #   date - date of week
  #   where - string where to search
  #   what - list of "what to find" words at searching by list

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
            AddFoundInfo $item $date $word1
          }
        }
      }
    }
  } else {
    if {[string match {*}$opt *$findString* $where]} {
      AddFoundInfo $item $date $where
    }
  }
}
#_______________________

proc find::AddFoundInfo {item date where} {
  # Logs found info to the listbox.
  #   item - item name
  #   date - week date where search was successful
  #   where - the text where search was successful

  variable foundList
  if {[lsearch -glob $foundList "$date $item *"]<0} {
    lappend foundList "$date $item -- $where"
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
  catch {destroy $win}
  catch {$pobj destroy}
  lassign [EG::ResourceData FindOptions] findString chkList chkCase fgeom
  set chkList [string is true -strict $chkList]
  set chkCase [string is true -strict $chkCase]
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra {Search in comments}
  $pobj paveWindow $win.fra {
    {lab1 - - - - {-st e -padx 4 -pady 4} {-t Find:}}
    {EntFind + L 1 3 {-st w -pady 4 -cw 1} {-tvar ::EG::find::findString -w 50}}
    {lab2 lab1 T 1 1 {-st e -padx 4 -pady 4} {-t Tags:}}
    {Opc1 + L 1 1 {-st w -pady 4} {::EG::find::Opcvar ::EG::find::OpcItems {-width 10}
      {EG::find::opcPre {%a}} -command EG::find::opcPost}}
    {fra1 lab2 T 1 4 {-st ew}}
    {.lab3 - - - - {-st e -padx 4} {-t {As tags:}}}
    {.chb + L 1 1 {-st w} {-var ::EG::find::chkList}}
    {.h_ + L 1 1 {-st ew -padx 9}}
    {.lab4 + L 1 1 {-st e -padx 4} {-t {Match case:}}}
    {.chb2 + L 1 1 {-st w} {-var ::EG::find::chkCase}}
    {fra2 fra1 T 1 4 {-st nswe -pady 4 -rw 111}}
    {fra2.Lfra - - - - {pack forget -expand 1 -fill both} {-t Found: -labelanchor n}}
    {.LbxInfo - - - - {pack -side left -fill both -expand 1}
      {-h 10 -w 20 -lvar ::EG::find::foundList -highlightthickness 0 -onevent {
      <<ListboxSelect>> "EG::find::ListboxSelect %w"}}}
    {.sbv + L - - pack}
    {seh fra2 T 1 4 {-st ew -pady 4}}
    {frabot + T 1 4 {-st ew} {}}
    {.ButHelp - - - - {pack -side left}
      {-text Help -com EG::find::Help -takefocus 0}}
    {.LaBMess + L 1 1 {pack -side left -expand 1 -fill x}}
    {.ButOK + L 1 1 {pack -side left} {-text Find -com EG::find::OK}}
    {.butCancel + L 1 1 {pack -side left -padx 4} {-text Cancel
      -com EG::find::Cancel}}
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
