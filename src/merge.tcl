###########################################################
# Name:    merge.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Mar 09, 2025
# Brief:   Handles merging data files.
# License: MIT.
###########################################################

# _________________________ Variables of merge ________________________ #

namespace eval merge {
  variable pobj ::merge::mergeObj
  variable win $::EG::WIN.merge
  variable fileToMerge {}
  variable listToMerge [list]
  variable EGDSav; set EGDSav [dict create] ;# EG data of current week
  variable EGDtmp; set EGDtmp [dict create]
  variable EGDtmpkeys [list]
  variable ItemsSav {}
  variable ItemsItemsTypesSav {}
  variable reWrite 0
  variable backupFile {}
  variable listLog [list]
}

# ________________________ Common procs _________________________ #

proc merge::Message {msg} {
  # Show message in message field.
  #   msg - message

  variable pobj
  set lab [$pobj LaBMess]
  $lab configure -foreground $::EG::Colors(fghot) -font {-weight bold}
  EG::Message $msg 0 $lab
}
#_______________________

proc merge::Log {msg {mode 0}} {
  # Show message(s) in log.
  #   msg - message
  #   mode - 1 init log list, 0 save $msg in log list, 2 output log list

  variable listLog
  if {$mode==2} { ;# sort and output the log list
    foreach msg [lsort -dictionary $listLog] {
      Log1 $msg
    }
    set mode 1
  }
  if {$mode==1} { ;# initialize the log list
    set listLog [list]
  }
  if {$mode==0} { ;# save message in the log list
    if {$msg ni $listLog} {lappend listLog $msg}
  }
}
#_______________________

proc merge::Log1 {msg {doadd yes}} {
  # Show a message in log.
  #   msg - message
  #   doadd - if yes adds to existing text

  variable pobj
  set tex [$pobj TexLog]
  $pobj readonlyWidget $tex no
  if {!$doadd} {$tex replace 1.0 end {}}
  $tex insert end \n$msg
  $pobj readonlyWidget $tex yes
}

# ________________________ Merging _________________________ #

proc merge::Merge {} {
  # Does merge.

  variable listToMerge
  variable EGDtmp
  variable EGDtmpkeys
  Log {} 1
  foreach fname $listToMerge {
    Log {} 2
    EG::ReadEGDFile $fname ::EG::merge::EGDtmp
    Log1 [string repeat _ 80]
    Log1 \n$fname:\n
    if {[catch {
      set items [CommonTmpData ITEMS]
      set itemstypes [CommonTmpData ITEMSTYPES]
    } err]} then {
      Log "ERROR: $err"
      continue
    }
    set EGDtmpkeys [lsort [dict keys $EGDtmp */*/*]]
    foreach it $items typ $itemstypes {
      if {[set idx [lsearch -exact $::EG::D(Items) $it]]<0} {
        if {$::EG::D(Curritems)==$::EG::D(MAXITEMS)} {
          Log "ERROR: \"$it\" off item limit ($::EG::D(MAXITEMS))"
          continue
        }
        lappend ::EG::D(Items) $it
        lappend ::EG::D(ItemsTypes) $typ
        EG::GeItemsNumber
      } else {
        set oldtyp [lindex $::EG::D(ItemsTypes) $idx]
        if {$typ ne $oldtyp} {
          Log "ERROR: \"$it\" types differ: $oldtyp <> $typ"
          continue
        }
      }
      if {[catch {AddItemData $it} err]} {
        Log "ERROR: $err"
      }
    }
  }
  Log {} 2
  EG::ShowTable
}
#_______________________

proc merge::AddItemData {item} {
  # Adds item data from EGDtmp to EGD dictionary.
  #   item - item name

  variable EGDtmp
  variable EGDtmpkeys
  variable reWrite
  foreach key $EGDtmpkeys {
    if {$key<$::EG::D(egdDate1) || $key>$::EG::D(egdDate2)} {
      Log "ERROR: \"$key\"\
        out of Preferences' range \[$::EG::D(egdDate1) - $::EG::D(egdDate2)\)"
      continue
    }
    foreach {k1 v1} [dict get $EGDtmp $key] {
      if {$k1 eq $item} {
        foreach {k2 v2} $v1 {
          set adkey [list $key $k1 $k2]
          if {!$reWrite
          && [dict exists $::EG::EGD {*}$adkey]
          && ([set v [dict get $::EG::EGD {*}$adkey]] ni {? ques} || $v eq $v2)} {
            Log "Existing data $adkey: $v => $v2"
          } else {
            Log "$adkey => $v2"
            dict set ::EG::EGD {*}$adkey $v2
          }
        }
      }
    }
  }
}
#_______________________

proc merge::DisplayTexLog {} {
  # Initializes log messages as for file list to merge.

  variable listToMerge
  variable pobj
  set listToMerge [lsort -dictionary $listToMerge]
  set outlog "File(s) to merge:\n"
  foreach fn $listToMerge {
    append outlog \n$fn
  }
  Log1 $outlog no
  if {[llength $listToMerge]} {
    set state normal
  } else {
    set state disabled
  }
  [$pobj ButMerge] configure -state $state
  [$pobj ButUndo] configure -state $state
}
#_______________________

proc merge::GetFileToMerge {} {
  # Gets name of file to merge.

  variable fileToMerge
  variable listToMerge
  set fileToMerge [string trim $fileToMerge]
  if {$fileToMerge ne {} && $fileToMerge ni $listToMerge} {
    if {$fileToMerge eq $::EG::D(FILE)} {
      Message {The file is already here}
    } elseif {![file exists $fileToMerge]} {
      Message "[file tail $fileToMerge] doesn't exist"
    } else {
      lappend listToMerge $fileToMerge
      Message {}
    }
  }
  DisplayTexLog
}
#_______________________

proc merge::AddTabs {selfiles} {
  # Add merged files selected in tab bar.
  #   selfiles - selected files

  variable listToMerge
  foreach fname $selfiles {lappend listToMerge $fname}
  DisplayTexLog
}
#_______________________

proc merge::CommonTmpData {dkey} {
  # Gets common data from EGDtmp.
  #   dkey - data key

  variable EGDtmp
  dict get $EGDtmp $::EG::COMMONTYPE $dkey
}

# ________________________ Actions _________________________ #

proc merge::Undo {} {
  # Undoes all changes.

  variable EGDSav
  variable ItemsSav
  variable ItemsItemsTypesSav
  variable backupFile
  set ::EG::EGD $EGDSav
  set ::EG::D(Items) $ItemsSav
  set ::EG::D(ItemsTypes) $ItemsItemsTypesSav
  set backupFile {}
  EG::GeItemsNumber
  DisplayTexLog
  EG::ShowTable
}
#_______________________

proc merge::Close {args} {
  # Closes Merge dialog.

  variable win
  variable pobj
  $pobj res $win 0
}
#_______________________

proc merge::Help {} {
  # Shows help on Merge dialog.

  variable win
  EG::Help merge -width 56 -height 32 -parent $win
}

# ________________________ GUI _________________________ #

proc merge::_create  {selfiles} {
  # Creates Merge dialogue.
  #   selfiles - merged file list

  variable pobj
  variable win
  variable reWrite
  catch {$pobj destroy}
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra Merge
  $pobj paveWindow $win.fra {
    {fra1 - - - - {-st nsew -cw 1}}
    {.v_ - - - - {-pady 8}}
    {.lab1 + T 1 1 {-st es -padx 4} {-t {File to merge:} -anchor e}}
    {.filIn + L 1 1 {-st swe -cw 1} {-w 60 -tvar ::EG::merge::fileToMerge
      -initialdir $::EG::USERDIR
      -filetypes {{{EG Data Files} {.egd} }} -defaultextension .egd}}
    {.lab2 .lab1 T 1 1 {-st es -padx 4 -pady 8} {-t {Rewrite data:} -anchor e}}
    {.chb + L 1 1 {-st w -pady 8} {-var ::EG::merge::reWrite}}
    {lfr fra1 T 1 2 {-st nswe -rw 1 -cw 1} {-t {Log messages:} -labelanchor n}}
    {.TexLog - - - - {pack -side left -expand 1 -fill both}
      {-w 10 -h 16 -ro 1 -wrap none}}
    {.sbvLog + L - - {pack -side left}}
    {seh lfr T 1 2 {-pady 8 -st ew}}
    {frabot + T 1 2 {-st ew} {}}
    {.ButHelp - - - - {pack -side left}
      {-text Help -com EG::merge::Help -takefocus 0}}
    {.LaBMess + L 1 1 {pack -side left -expand 1 -fill x}}
    {.ButMerge + L 1 1 {pack -side left} {-text Merge -state disabled
      -image mnu_download -compound left -com EG::merge::Merge}}
    {.ButUndo + L 1 1 {pack -side left} {-text Undo -state disabled
      -image mnu_undo -compound left -com EG::merge::Undo}}
    {.butClose + L 1 1 {pack -side left -padx 4} {-text Close -com EG::merge::Close}}
  }
  foreach ev {FocusIn FocusOut} {
    bind .eg.merge.fra.fra1.entfilIn <$ev> EG::merge::GetFileToMerge
  }
  AddTabs $selfiles
  bind $win <F1> "[$pobj ButHelp] invoke"
  set res [$pobj showModal $win -parent $::EG::WIN -focus Tab \
    -minsize {300 200} -onclose EG::merge::Close]
  catch {destroy $win}
  catch {$pobj destroy}
}
#_______________________

proc merge::_run  {selfiles} {
  # Runs Merge dialogue.
  #   selfiles - merged file list

  variable EGDSav
  variable ItemsSav
  variable ItemsItemsTypesSav
  variable reWrite
  variable backupFile
  variable fileToMerge
  variable listToMerge
  set EGDSav $::EG::EGD
  set ItemsSav $::EG::D(Items)
  set ItemsItemsTypesSav $::EG::D(ItemsTypes)
  set reWrite 0
  set fileToMerge {}
  set listToMerge [list]
  if {$backupFile eq {}} {
    set backupFile $::EG::D(FILEBAK)
    set ::EG::D(FILEBAK) $::EG::D(FILE)-beforeMerge
    EG::Backup yes
    set ::EG::D(FILEBAK) $backupFile
  }
  _create $selfiles
  EG::ShowTable
}

# ________________________ EOF _________________________ #
