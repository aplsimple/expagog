#! /usr/bin/env tclsh
###########################################################
# Name:    calc.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    Jun 20, 2026
# Brief:   Handles a calculator available everywhere in EG.
# License: MIT.
###########################################################

# _________________________ calc ________________________ #

namespace eval calc {
  variable win {}          ;# calculator's window
  variable wintop {}       ;# window active before calculator
  variable calcformula {}  ;# expression to calculate
  variable calclist {}     ;# used expressions (combobox' values)
  variable labsize 20      ;# font size of result
  variable busy 0          ;# flag "calculator is open"
  variable calcgeo         ;# geometry of calculator
  array set calcgeo {}
}
#_______________________

proc calc::Calculator {} {
  # Simple calculator.

  variable WIN
  variable win
  variable pobj
  variable wintop
  variable calcformula
  variable calclist
  variable calcgeo
  variable busy
  if {$busy} return
  set busy yes
  set oldfoc [focus]
  set wintop [winfo toplevel $oldfoc]
  if {[winfo exists $wintop]} {
    set win $wintop
  } else {
    set win $WIN
  }
  append win .calc
  set pobj ::apave::pavedObj[incr ::apave::pavedObjIdx]
  ::apave::APave create $pobj $win
  $pobj makeWindow $win.fra Expression
  $pobj paveWindow $win.fra {
    {fra1 - - - - {pack -side top -expand 0 -fill x}}
    {.CbxFormula - - - - {pack -side left -expand 1 -fill x -anchor n -pady 8 -padx 4}
      {-w 40 -h 12 -cbxsel {$calcformula} -tvar ::EG::calc::calcformula
      -clearcom EG::calc::ClearComboValue -selcombobox EG::calc::Calculation}}
    {fra2 - - - - {pack -side bottom -expand 0 -fill x}}
    {.LabResult - - - - {pack -side left -expand 1 -fill x}}
    {.btTcopy - - - - {pack -side left} {-com EG::calc::Copy -tip {To clipboard}}}
    {.btTques - - - - {pack -side left} {-com EG::calc::Help -tip Help}}
  }
  foreach k {<Return> <KP_Enter>} {
    bind $win $k EG::calc::Calculation
  }
  bind $win <F1> EG::calc::Help
  Calculation
  set geo {}
  catch {set geo "-geometry $calcgeo($win)"}
  set res [$pobj showModal $win -resizable {1 0} -minsize {250 10} \
    {*}$geo -focus [$pobj CbxFormula]]
  set calcgeo($win) [wm geometry $win]
  catch {destroy $win}
  $pobj destroy
  set busy no
  apave::focusByForce $oldfoc
}
#_______________________

proc calc::Calculation {} {

  variable pobj
  variable calcformula
  variable labsize
  set lab [$pobj LabResult]
  set res [set err 0.0]
  set calcformula [string trim $calcformula]
  if {$calcformula ne {}} {
    set err [catch {set res [expr $calcformula]} errmsg]
    if {$err} {
      set res $errmsg
      SetLabelSize [expr {$labsize-10}]
    } else {
      if {[string first . $res]>-1} {set res [EG::Round $res 8]}
    }
  }
  if {!$err} {SetLabelSize $labsize}
  $lab configure -text $res
  UpdateCalcList
  set cbx [$pobj CbxFormula]
  $cbx selection range 0 end
  $cbx icursor end
}
#_______________________

proc calc::DeleteFromCalcList {} {
  # Deletes a calculation expression from the list of expressions.

  variable pobj
  variable calclist
  set cbx [$pobj CbxFormula]
  set val [string trim [$cbx get]]
  set i [lsearch -exact $calclist $val]
  if {$val ne {} && $i>-1} {
    set calclist [lreplace $calclist $i $i]
    $cbx configure -values $calclist
    $cbx set {}
  }
}
#_______________________

proc calc::ClearComboValue {} {
  # Clears combobox' field.

  DeleteFromCalcList
  Calculation
}
#_______________________

proc calc::UpdateCalcList {} {
  # Updates the list of calculation expressions.

  variable pobj
  variable calclist
  set cbx [$pobj CbxFormula]
  set val [string trim [$cbx get]]
  DeleteFromCalcList
  set calclist [linsert $calclist 0 $val]
  set ltmp [list {}]
  foreach c $calclist {if {$c ne {}} {lappend ltmp $c}}
  set calclist $ltmp
  set maxlen 33
  catch {set calclist [lreplace $calclist $maxlen end]}
  $cbx set $val
  $cbx configure -values $calclist
}
#_______________________

proc calc::SetLabelSize {sz} {
  # Sets the label's font size.
  #   sz - font size

  variable pobj
  set lab [$pobj LabResult]
  set font [obj basicTextFont]
  set font [::apave::removeOptions $font -size]
  lappend font -size $sz
  $lab configure -font $font
}
#_______________________

proc calc::Copy {} {
  # Copies result to clipboard.

  variable pobj
  variable calcformula
  if {[string trim $calcformula] ne {}} {
    set lab [$pobj LabResult]
    clipboard clear
    clipboard append "$calcformula = [$lab cget -text]"
  }
}
#_______________________

proc calc::Help {} {
  # Shows help on calculator.

  variable win
  EG::Help calc -width 56 -height 32 -parent $win
}
#_______________________

proc calc::_run {} {
  # Binds keys to calling the calculator.

  variable win
  variable wintop
  catch {
    set w [winfo toplevel [focus]]
    if {$w ni "$win $wintop"} {
      set wintop $w
      foreach k {<Control-E> <Control-e>} {
        bind $wintop $k EG::calc::Calculator
      }
    }
  }
  after idle {after 500 EG::calc::_run}
}
