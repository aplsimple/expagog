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
  variable col1Width 100
  variable col2Width 100
}

# ________________________ Common _________________________ #

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

proc find::ClearCbx {cbx varname} {
  # Clears a combobox's value and removes it from the combobox' list.
  #   cbx - the combobox's path
  #   varname - name of variable used in the current namespace

  set val [string trim [$cbx get]]
  set values [$cbx cget -values]
  if {[set i [lsearch -exact $values $val]]>-1} {
    set values [lreplace $values $i $i]
    $cbx configure -values $values
  }
  set $varname $values
}
#_______________________

proc find::treTip {ID col} {
  # Gets tip for treeview column.
  #   ID - item's ID
  #   col - column

  variable foundList
  set idx [string range $ID 2 end]
  lassign [split [lindex $foundList $idx-1] \t] date item word fname where
  switch -exact $col {
    {#1} {
      if {$fname eq {}} {
        set res "Current"
      } else {
        set res $fname\n[Tab2Fname $fname]
      }
    }
    {#2} {
      set res [EG::FormatDate [EG::ScanDatePG $date]]
    }
    default {
      set res \"$word\"\n\n$where
    }
  }
  return $res
}
#_______________________

proc find::SaveOptions {} {
  # Saves options and dialog's geometry.

  variable win
  variable pobj
  variable chkList
  variable chkCase
  set findStrs {}
  foreach fstr $::EG::D(FindStrs) {
    if {$findStrs ne {}} {append findStrs \n}
    append findStrs $fstr
    if {[incr _cnt]==30} break
  }
  set wtree [$pobj Tree]
  EG::ResourceData FindOptions [EG::toEOL $findStrs] $chkList $chkCase \
    [wm geometry $win] [$wtree column #1 -width] [$wtree column #2 -width]
}

# ________________________ Option cascade _________________________ #

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

# ________________________ Search _________________________ #

proc find::Found {item date where what fname} {
  # Search in string.
  #   item - item name
  #   date - date of week
  #   where - string where to search
  #   what - list of "what to find" words at searching by list
  #   fname - egd file name or {}

  variable findString
  variable chkCase
  variable chkList
  if {$chkCase} {set opt {}} {set opt -nocase}
  if {$findString eq {}} {
    AddFoundInfo $item $date $where $fname $where ;# empty find value => show all texts
  } elseif {$chkList} {
    set what [string trim $what]
    foreach word1 [split $where] {
      if {$word1 ne {}} {
        foreach word2 $what {
          if {[string match {*}$opt $word2 $word1]} {
            AddFoundInfo $item $date $word1 $fname $where
          }
        }
      }
    }
  } else {
    if {[string match {*}$opt *$what* $where]} {
      AddFoundInfo $item $date $where $fname $where
    }
  }
}
#_______________________

proc find::AddFoundInfo {item date word fname where} {
  # Logs found info to the found list.
  #   item - item name
  #   date - week date where search was successful
  #   word - word where search was successful
  #   fname - egd file name or {}
  #   where - text where search was successful

  variable foundList
  if {[lsearch -glob $foundList "$date\t$item\t*\t$fname\t*"]<0} {
    set word [string map [list \t { }] $word]
    set where [string map [list \t { }] $where]
    lappend foundList "$date\t$item\t$word\t$fname\t$where"
  }
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
      set fname [Tab2Fname [lindex $curlist 3]]
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

# ________________________ Buttons _________________________ #


proc find::OK {} {

  variable win
  variable pobj
  variable chkList
  variable chkAll
  variable foundList
  variable findString
  set findString [string trim $findString]
  SaveOptions
  set cbx [$pobj Cbx1]
  EG::Message "Wait please..." 10
  ClearCbx $cbx ::EG::D(FindStrs)
  set ::EG::D(FindStrs) [linsert $::EG::D(FindStrs) 0 $findString]
  $cbx configure -values $::EG::D(FindStrs)
  set wtree [$pobj Tree]
  set treeid 0
  set delti [list]
  foreach flit $foundList {lappend delti ti[incr treeid]}
  catch {$wtree delete $delti}
  set foundList [list]
  set escmap [list \\ \\\\ * \\* ? \\? \[ \\\[ \] \\\]]
  if {$chkList} {
    set what [list]
    foreach wf [split $findString] {
      lappend what [string map $escmap $wf]
    }
  } else {
    set what [string map $escmap $findString]
  }
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
  lassign $::EG::D(WeeklyITEM) weeklyItem
  foreach egdi $egdinfo {
    lassign $egdi fname egdvar
    set dkeys [EG::DatesKeys {} {} 0 $egdvar]
    if {$egdvar eq {}} {
      set fname {}
      set egd $::EG::EGD
    } else {
      set fname "[Fname2Tab $fname]"
      set egd [set $egdvar]
    }
    foreach date $dkeys {
      set itemdata [dict get $egd $date]
      if {[dict exists $itemdata $weeklyItem]} {
        lassign [dict get $itemdata $weeklyItem] it value
        set value [EG::fromEOL $value]
        Found $it $date $value $what $fname ;# search in weekly
      }
    }
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
    lassign [split $flit \t] date item word fname where
    set tID ti[incr treeid]
    set word [string trim [string map [list \n { } $::EG::D(TAGS) {}] $where]]
    $wtree insert {} end -id $tID -values [list [file tail $fname] $date $word]
    if {$treeid==1} {set tID1 $tID}
  }
  catch {
    $wtree selection set $tID1
    $wtree focus $tID1
    focus $wtree
  }
  ::baltip::tip $wtree {::EG::find::treTip %i %c}
  [$pobj Lfra] configure -text " Found: [llength $foundList] "
  EG::Message ""
}
#_______________________

proc find::Cancel {args} {
  # Closes Find dialog.

  variable win
  variable pobj
  $pobj res $win 0
}
#_______________________

proc find::Help {} {
  # Shows help on Find dialogue.

  variable win
  EG::Help find -width 57 -height 32 -parent $win
}

# ________________________ Main _________________________ #

proc find::_create {} {
  # Creates and opens Find dialog.

  variable win
  variable pobj
  variable findString
  variable chkList
  variable chkCase
  variable col1Width
  variable col2Width
  if {[winfo exists $win]} {
    focus $win
    catch {
      set wtree [$pobj Tree]
      focus $wtree
      $wtree focus [$wtree selection]
    }
    return
  }
  lassign [EG::ResourceData FindOptions] findString chkList chkCase fgeom \
    col1Width col2Width
  if {![string is digit -strict $col1Width]} {set col1Width 100}
  if {![string is digit -strict $col2Width]} {set col2Width 100}
  set ::EG::D(FindStrs) [split [EG::fromEOL $findString] \n]
  set findString [lindex $::EG::D(FindStrs) 0]
  set chkList [string is true -strict $chkList]
  set chkCase [string is true -strict $chkCase]
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra Find
  $pobj paveWindow $win.fra {
    {lab1 - - - - {-st e -padx 2 -pady 4} {-t Find:}}
    {Cbx1 + L 1 3 {-st w -pady 4 -cw 1}
      {-tvar ::EG::find::findString -w 50 -h 10 -values {$::EG::D(FindStrs)}
      -clearcom {EG::find::ClearCbx %w ::EG::D(FindStrs)} -tip {-BALTIP "Empty field means\n\"show all texts\"" -MAXEXP 2} }}
    {lab2 lab1 T 1 1 {-st e -padx 2 -pady 4} {-t Tags:}}
    {Opc1 + L 1 1 {-st w -pady 4} {::EG::find::Opcvar ::EG::find::OpcItems {-width 10}
      {EG::find::opcPre {%a}} -command EG::find::opcPost}}
    {fra1 lab2 T 1 4 {-st ew}}
    {.lab3 - - - - {-st e -padx 2} {-t {By words:}}}
    {.chb + L 1 1 {-st w} {-var ::EG::find::chkList}}
    {.h_ + L 1 1 {-st ew -padx 9}}
    {.lab4 + L 1 1 {-st e -padx 2} {-t {Match case:}}}
    {.chb2 + L 1 1 {-st w} {-var ::EG::find::chkCase}}
    {.h_2 + L 1 1 {-st ew -padx 9}}
    {.LabAll + L 1 1 {-st e -padx 2} {-t {In all:}}}
    {.ChbAll + L 1 1 {-st w} {-var ::EG::find::chkAll}}
    {fra2 fra1 T 1 4 {-st nswe -pady 4 -rw 111}}
    {fra2.Lfra - - - - {pack -expand 1 -fill both} {-t Found -labelanchor n}}
    {.Tree - - - - {pack -side left -fill both -expand 1} {
      -selectmode browse -show headings -columns {L1 L2 L3}}}
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
  if {![EG::IsTabFiles]} {
    [$pobj LabAll] configure -state disabled
    [$pobj ChbAll] configure -state disabled
  }
  set wtree [$pobj Tree]
  $wtree heading #1 -text File
  $wtree heading #2 -text Date
  $wtree heading #3 -text {Found string}
  $wtree column #1 -minwidth 4 -width $col1Width -stretch 0
  $wtree column #2 -minwidth 4 -width $col2Width -stretch 0
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
