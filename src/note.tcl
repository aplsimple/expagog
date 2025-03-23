#! /usr/bin/env tclsh
###########################################################
# Name:    note.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jan 20, 2025
# Brief:   Handles notes of EG app.
# License: MIT.
###########################################################

# _________________________ note ________________________ #

namespace eval note {
  variable NNlen 14
}

# ________________________ Class "Notes" _________________________ #

oo::class create note::Notes {

  variable Pobj Win Ngeometry NN NName Ncolor NoteKey NoteFile _X _Y

constructor {idx} {

  set NN $idx
  set NoteKey Note$NN
  set Pobj ::EG::note::notepavedObj$NN
  set Win $::EG::WIN.sticker$NN
  set Ngeometry +0+0
  lassign [my GetNoteData] NName Ncolor
  set NoteFile [file join $::EG::USERDIR $NoteKey.note]
}

destructor {
  catch {destroy $Win}
  catch {$Pobj destroy}
}

# ________________________ Common methods _________________________ #

method pobj {} {
  # Gets Pobj of note's window.

  return $Pobj
}
#_______________________

method chooseColor {} {
  # Chooses a note's background color.

  lassign [split [wm geometry $Win] x+] w h x y
  set geo +[expr {$x+$w}]+$y
  if {$::EG::D(NoteOnTop)} {
    after idle "catch {wm overrideredirect .__tk__color 1}"
  }
  set ::EG::note::ncolor $Ncolor
  set res [$Pobj chooser colorChooser ::EG::note::ncolor \
    -geometry $geo -parent $Win -ontop 1]
  if {$res ne {}} {
    set Ncolor $res
    lassign [apave::InvertBg $Ncolor] fcolor
    [$Pobj Text] configure -fg $fcolor -bg $Ncolor -insertbackground $fcolor
    my SetNoteData
  }
}

# ________________________ Data in / out _________________________ #

method ReadNoteText {} {
  # Gets a note text.

  set conts [apave::readTextFile $NoteFile]
  $Pobj displayText [$Pobj Text] $conts
}
#_______________________

method SaveNoteText {} {
  # Saves a note's text.

  set conts [string trimright [[$Pobj Text] get 1.0 end]]\n
  apave::writeTextFile $NoteFile conts
}
#_______________________

method GetNoteData {} {
  # Gets the current note's data.

  lassign [EG::ResourceData $NoteKey] NName d1 d2 d3 d4
  if {$NName eq {}} {set NName "Sticker $NN"}
  list $NName $d1 $d2 $d3 $d4
}
#_______________________

method SetNoteData {} {
  # Sets the current note's data.
  #   n - note's number

  set NName [set ::EG::note::notename$NN]
  set NName [string range [string trim $NName] 0 $::EG::note::NNlen]
  set NName [string trim $NName]
  catch {set Ncolor [[$Pobj Text] cget -bg]}
  catch {set Ngeometry [wm geometry $Win]}
  EG::ResourceData $NoteKey $NName $Ncolor $Ngeometry
  my SaveNoteText
  return 1
}
#_______________________

method saveNoteData {} {
  # Saves a note's data.

  my SetNoteData
  EG::SaveRC  ;# for a company
  return 1
}

# ________________________ Dragging note _________________________ #

method mouse_Drag {mode went X Y} {
  # Handles mouse press/move/release to move window.
  #   mode - 1 for press, 2 for move, 3 for release
  #   went - entry path
  #   X - X-coordinate of cursor
  #   Y - Y-coordinate of cursor

  switch -exact -- $mode {
    1 {set _X $X; set _Y $Y}
    2 {
      if {[info exists _X] && $_X>0} {
        lassign [split [wm geometry $Win] x+] w h wx wy
        set shx [expr {$X-$_X}]
        set shy [expr {$Y-$_Y}]
        wm geometry $Win +[expr {$wx+$shx}]+[expr {$wy+$shy}]
        set _X $X; set _Y $Y
      }
    }
    3 {
      set _X 0
      $went selection clear
      apave::focusByForce $went
      after idle EG::SaveDataFile  ;# let it be that often
    }
  }
}

# ________________________ UI _________________________ #

method createNote {n onlyshow} {
  # Creates "Sticker" dialogue.
  #   n - note's index
  #   onlyshow - yes, if only show the note

  lassign [my GetNoteData] NName Ncolor Ngeometry
  set ::EG::note::notename$n $NName
  if {$Ncolor eq {}} {set Ncolor [lindex [obj csGet] 1]}
  lassign [apave::InvertBg $Ncolor] fcolor
  set Self [self]
  obj untouchWidgets *ANote*
  catch {$Pobj destroy}
  ::apave::APave create $Pobj $Win
  $Pobj makeWindow $Win.fra "EG - Sticker $n"
  $Win configure -bg $Ncolor
  $Pobj paveWindow $Win.fra {
    {Fra1 - - 1 1 {-st nsew}}
    {.tool - - - - {pack -side top} {-relief flat -borderwidth 0 -array {
      mnu_color {"$Self chooseColor" -tip "Choose background color@@ -under 5"}
      lab1 {"" {-fill x -expand 1}}
      Ent {-tvar ::EG::note::notename$n -justify center -w $::EG::note::NNlen
        -validate focusout -validatecommand "$Self saveNoteData"}
      lab2 {"" {-fill x -expand 1}}
      no {"$Self saveNoteData; $Self exitNote" -tip "exitNote@@ -under 5"}
      }
    }}
    {frANote fra1 T 1 1 {-st nsew -rw 1 -cw 1} {-width 1 -bg $Ncolor}}
    {.Text - - - - {pack -side left -expand 1 -fill both}
      {-wrap word -tabnext *.ent -w $::EG::note::NNlen -h 2 -fg $fcolor \
      -insertwidth 2 -bg $Ncolor -insertbackground $fcolor}}
    {.Siz - - - - {pack -side bottom}}
    {.sbv .text L - - {pack -side right} {}}
  }
  my ReadNoteText
  set wtxt [$Pobj Text]
  set went [$Pobj Ent]
  if {$::EG::D(NoteOnTop)} {
    wm overrideredirect $Win 1
    bind $wtxt <ButtonPress-1> "apave::focusByForce $wtxt"
    bind $went <ButtonPress-1>   "+ $Self mouse_Drag 1 %W %X %Y"
    bind $went <Motion>          "+ $Self mouse_Drag 2 %W %X %Y"
    bind $went <ButtonRelease-1> "+ $Self mouse_Drag 3 %W %X %Y"
  } else {
    pack forget [$Pobj Siz]
  }
  bind $Win <FocusOut> "+ $Self saveNoteData"
  if {$onlyshow} {
    wm protocol $Win WM_DELETE_WINDOW "$Self saveNoteData; $Self exitNote"
    after idle "::apave::deiconify $Win; wm geometry $Win $Ngeometry"
    wm transient $Win $::EG::WIN
  } else {
    after 1000 "$Self saveNoteData"
    if {$Ngeometry eq {}} {set geo {}} {set geo "-geometry $Ngeometry"}
    $Pobj showModal $Win -modal no -parent $::EG::WIN -focus $wtxt \
      -onclose "$Self saveNoteData; $Self exitNote" {*}$geo
  }
}
#_______________________

method exitNote {args} {
  # Exits a note.

  my SetNoteData
  catch {destroy $Win}
  EG::SaveRC
  catch {$Pobj destroy}
}
#_______________________

method noteWin {} {
  # Returns note window's path.

  return $Win
}

method noteName {} {
  # Returns note's name.

  return $NName
}

method noteColor {} {
  # Returns note's color.

  return $Ncolor
}

# ________________________ EOC _________________________ #

}

# ________________________ Run this _________________________ #

proc note::OpenNotes {} {
  # Opens notes at starting EG.

  EG::Resource
  set noteopen [EG::ResourceData NoteOpen]
  foreach n $::EG::NOTESN {
    set isopen [lindex $noteopen $n-1]
    if {[string is true -strict $isopen]} {_run $n yes}
  }
}
#_______________________

proc note::NoteObj {idx} {
  # Gets Notes object's name.
  #   idx - note's index

  return NoteObj$idx
}
#_______________________

proc note::CreateObj {idx} {
  # Creates Notes object.
  #   idx - note's index

  set nobj [NoteObj $idx]
  catch {Notes create $nobj $idx}
  return $nobj
}
#_______________________

proc note::NoteWin {idx} {
  # Gets note window's path.
  #   idx - note's index

  CreateObj $idx
  [NoteObj $idx] noteWin
}
#_______________________

proc note::NoteName {idx} {
  # Gets note' name.
  #   idx - index of note

  CreateObj $idx
  [NoteObj $idx] noteName
}
#_______________________

proc note::NoteColor {idx} {
  # Gets note's color.
  #   idx - index of note

  CreateObj $idx
  [NoteObj $idx] noteColor
}
#_______________________

proc note::OpenNoteText {idx} {
  # Gets an open note's text.
  #   idx - note's index

  set res {}
  catch {
    set nobj [NoteObj $idx]
    set pobj [$nobj pobj]
    set res [string trimright [[$pobj Text] get 1.0 end]]
  }
  return $res
}
#_______________________

proc note::SaveNoteData {idx} {
  # Saves a note's data.
  #   idx - index of note

  catch {[NoteObj $idx] saveNoteData}
}
#_______________________

proc note::_run {idx {onlyshow no}} {
  # Runs "Sticker" dialogue.
  #   idx - note's index
  #   onlyshow - yes, if only show the note

  if {!$onlyshow} {after idle EG::SaveAllData}
  set nobj [NoteObj $idx]
  catch {$nobj destroy}
  CreateObj $idx
  $nobj createNote $idx $onlyshow
}

# ________________________ EOF _________________________ #
