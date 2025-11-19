###########################################################
# Name:    pref.tcl
# Author:  Alex Plotnikov  (aplsimple@gmail.com)
# Date:    05/25/2021
# Brief:   Handles "Preferences".
# License: MIT.
###########################################################

# ________________________ Variables _________________________ #

namespace eval pref {
  variable win $::EG::WIN.pref
  variable obPrf ::EG::pref::pobj
  variable arrayTab; array set arrayTab [list]
  variable opct {}
  variable opcThemes {}
  variable opcc {}
  variable opcColors {}
  variable tagColorRed    $::EG::Colors(Red)
  variable tagColorYellow $::EG::Colors(Yellow)
  variable tagColorGreen  $::EG::Colors(Green)
  variable DP; array set DP [list]
  variable DPars {FILE Theme CS Items ItemsTypes Hue Zoom NoteOnTop \
    DateUser DateUser2 DateUser3 egdDate1 egdDate2 DefFont TexFont AggrEG}
  variable currTab {}
  variable currFoc {}
  variable txtColor {}
  variable msgColor {}
  variable itemOrder [list]
  variable savedEgdDate1
  variable savedEgdDate2
}

# ________________________ Common procedures _________________________ #

proc pref::fetchVars {} {
  # Delivers namespace variables to a caller.

  uplevel 1 {
    variable win
    variable obPrf
    variable arrayTab
    variable opct
    variable opcThemes
    variable opcc
    variable opcColors
    variable tagColorRed
    variable tagColorYellow
    variable tagColorGreen
    variable DP
    variable DPars
    variable currTab
    variable currFoc
    variable txtColor
    variable msgColor
    variable itemOrder
    variable savedEgdDate1
    variable savedEgdDate2
  }
}
#_______________________

proc pref::ItemVars {i} {
  # Gets list of variable names of item.
  #   i - index of item

  return [list ::EG::pref::ClrI$i ::EG::pref::EntI$i ::EG::pref::EntF$i]
}
#_______________________

proc pref::Message {msg {wait 0}} {
  # Message in the Preferences.
  #   msg - message
  #   wait - wait time

  fetchVars
  EG::Message $msg $wait [$obPrf LabMess]
}
#_______________________

proc pref::origItemOrder {} {
  # Gets original order of item indexes.

  for {set i 0} {$i<$::EG::D(MAXITEMS)} {incr i} {
    lappend order $i
  }
  return $order
}
#_______________________

proc pref::origItems {} {
  # Gets original item list.

  return [lrange $::EG::D(Items) 0 end-1]
}
#_______________________

#% doctest ReMap
#< namespace eval pref {}

proc pref::ReMap {oldItems newItems oldOrder newOrder} {
  # Gets "renaming map" to rename old items to new ones.
  #   oldItems - old list of items
  #   newItems - new list of items
  #   oldOrder - old order of items
  #   newOrder - new order of items
  # Deleted items (renamed to {}) aren't included into the map.

  set remap [list]
  set maxitems [expr {max([llength $oldItems],[llength $newItems])}]
  for {set i 0} {$i<$maxitems} {incr i} {
    set io [lindex $newOrder $i]
    set itnew [lindex $newItems $i]
    set itold [lindex $oldItems $io]
    set is [lsearch -exact $oldItems $itnew]
    if {$itnew ne $itold && $itnew ne {} && $itold ne {} && $is<0} {
      lappend remap $itold $itnew
    }
  }
  return $remap
}

#% pref::ReMap {i0 i1 i2 i3} {i0 i2 i3 i1} {0 1 2 3} {0 1 3 2} ;# no changes
#>

#% pref::ReMap {i0 i1 i2 i3} {i3 i2 i1 i0} {0 1 2 3} {3 2 1 0} ;# only reorder
#>

#% pref::ReMap {i0 i1 i2 i3} {i3n i2 i1n i0} {0 1 2 3} {3 2 1 0} ;# rename i1 i3
#> i3 i3n i1 i1n

#% pref::ReMap {i0 i1 i2 i3} {i3n i2 i1n} {0 1 2 3} {3 2 1} ;# rename i1 i3
#> i3 i3n i1 i1n

#% pref::ReMap {i0 i1 i2 i3} {i2 "i3n .." "i1n .."} {0 1 2 3} {2 3 1} ;# as above
#> i3 {i3n ..} i1 {i1n ..}

#% pref::ReMap {i0 i1 i2 i3} {i1 i3 {} i2n i0n} {0 1 2 3} {1 3 4 2 0} ;# after {}
#> i2 i2n i0 i0n

#% pref::ReMap {i0 i1 i2} {i3n} {0 1 2} {3} ;# add i3n
#>

#% pref::ReMap {i0 i1 i2} {i0n i3n} {0 1 2} {1 4} ;# rename i1, delete i2, add i3n
#> i1 i0n

#% pref::ReMap {i0 i1 i2} {i0n i3n} {0 1 2} {2 0} ;# rename i2 i0, delete i1
#> i2 i0n i0 i3n

#% pref::ReMap {i0 i1 i2} {i2n} {0 1 2} {2} ;# rename i2, delete i0 i1
#> i2 i2n

#% pref::ReMap {i0 i1 i2} {} {0 1 2} {} ;# delete all
#>

#% pref::ReMap {i0 i1 i2 i3} {i3n i2n i1n i0n} {0 1 2 3} {3 2 1 0} ;# rename all
#> i3 i3n i2 i2n i1 i1n i0 i0n

#> doctest
#_______________________

proc pref::RenameItems {remap} {
  # Renames item name keys of EGD data.
  #   remap - list of mappings (old new) to rename items

  fetchVars
  if {![llength $remap]} return
  foreach key [dict keys $::EG::EGD] {
    if {[string match */*/* $key]} {
      set lvalinp [dict get $::EG::EGD $key]
      set lvalout [list]
      foreach {itkey itval} $lvalinp {
        set itkey [string map $remap $itkey]
        lappend lvalout $itkey $itval
      }
      dict set ::EG::EGD $key $lvalout
    }
  }
}
#_______________________

proc pref::IsChangedMainSettings {} {
  # Gets the flag "main settings' values are changed".
  # "Main" means "require restarting".

  fetchVars
  set res no
  foreach k {FILE Theme CS Zoom Items ItemsTypes egdDate1 egdDate2 DefFont TexFont
  NoteOnTop} {
    set old $::EG::D($k)
    set new $DP($k)
    if {$k in {Items ItemsTypes}} {
      # items & item types include EG - don't check it
      set old [lrange $old 0 end-1]
    }
    if {$old != $new} {set res yes; break}
  }
  lassign $::EG::D(CS) ::EG::D(CS)
  lassign $DP(CS) DP(CS)
  set oldDark [$obPrf csDark $::EG::D(CS)]
  set newDark [$obPrf csDark $DP(CS)]
  expr {$res || $oldDark != $newDark}
}
#_______________________

proc pref::UpdateAppearance {} {
  # Updates the appearance: colors & dates.

  set opcvar $::EG::Opcvar
  EG::CheckItems
  EG::SaveAll
  EG::Init
  EG::FocusedIt $::EG::D(curritem) $::EG::D(currwday)
  EG::ShowTable
  set ::EG::Opcvar $opcvar ;# restore current diagram type
  EG::Diagram
}

# ________________________ Main Frame _________________________ #

proc pref::MainFrame {} {
  # Creates a main frame of the dialogue.

  fetchVars
  return {
    {fraR - - 1 1 {-st nsew -cw 1}}
    {fraR.nbk - - - - {pack -side top -expand 1 -fill both} {
      f1 {-t General}
      f2 {-t Topics}
    }}
    {seh fraR T 1 2 {-st nsew -pady 2}}
    {fraB + T 1 2 {-st nsew} {-padding {2 2}}}
    {.ButHelp - - - - {pack -side left}
      {-t Help -tip F1 -com ::EG::pref::Help -takefocus 0}}
    {.butRun - - - - {pack -side left -padx 2} {-t Test -com {::EG::pref::Save 1}
      -takefocus 0}}
    {.LabMess - - - - {pack -side left -expand 1 -fill both -padx 8}}
    {.butOK - - - - {pack -side left -padx 2} {-t OK -com ::EG::pref::Save}}
    {.butCancel - - - - {pack -side left} {-t Cancel -com ::EG::pref::Cancel}}
  }
}
#_______________________

proc pref::opcCSPre {args} {
  # Gets colors for "Color schemes" items.
  #   args - color scheme's index and name, separated by ":"

  lassign [split $args :] a
  if {[string is integer $a]} {
    lassign [obj csGet $a] - fg - bg
    return "-background $bg -foreground $fg"
  }
  return {}
}
#_______________________

proc pref::Save {{istest 0} args} {
  # Saves preferences.
  #   istest - if true, starts EG in testing mode

  fetchVars
  set savedUSERFILEPG $::EG::USERFILEPG
  set tmpD [array get ::EG::D]
  set tmpDateUser $::EG::D(DateUser)
  set tmpcolors [array get ::EG::Colors]
  set tmprc [file join $::EG::USERDIR _tmp_.rc]
  if {$istest} {
    set ::EG::USERFILEPG $tmprc
  }
  set Items [set ItemsNew [list]]
  set ItemsTypes [list]
  for {set iit 1} {$iit<=$::EG::D(MAXITEMS)} {incr iit} {
    lassign [ItemVars $iit] clrvar itmvar frmvar
    set clr [string trim [set $clrvar]]
    set $clrvar $clr
    set itm [string trim [set $itmvar]]
    set itm [string map [list { } _] $itm]  ;# no spaces in item names!
    set itm [string range $itm 0 $::EG::NAMEWIDTH]  ;# limit length of item names
    set $itmvar $itm
    lappend ItemsNew $itm
    set frm [string trim [set $frmvar]]
    set $frmvar $frm
    if {$clr ne {} && $itm ne {} && $frm ne {}} {
      if {$itm in {Totals All EG AggrEG}} {
        EG::msg ok warn \
          "<r>$itm</r> is a special name used by the app.\n\
          \nPlease, change this item's name."
        array set ::EG::Colors $tmpcolors
        return
      }
      lappend Items $itm
      lappend ItemsTypes $frm
      set ::EG::Colors(my$iit) $clr
    }
  }
  if {![llength $Items]} {
    EG::msg ok warn \
      "No item settings found.\n \
      \nPlease, set item colors, names <b>and</b> formats."
    array set ::EG::Colors $tmpcolors
    return
  }
  set DP(FILE) [string trim $DP(FILE)]
  if {$DP(FILE) eq {}} {
    EG::msg ok warn "Data file isn't set.\n\nPlease, set a file name."
    array set ::EG::Colors $tmpcolors
    return
  }
  set ::EG::D(FILE) [string trim $::EG::D(FILE)]
  set isnewfile [expr {$DP(FILE) ne $::EG::D(FILE)}]
  if {$isnewfile && [file exists $DP(FILE)]} {
    EG::msg ok warn "File\n  $DP(FILE)\nalready exists.\
      \n\nPlease, set a new file name."
    array set ::EG::Colors $tmpcolors
    return
  }
  if {!$::EG::D(AUTOBAK) && !$istest} {
    EG::Backup yes ;# force backup
  }
  set remap [ReMap [origItems] $ItemsNew [origItemOrder] $itemOrder]
  RenameItems $remap
  set ::EG::Colors(bgtex) $txtColor
  set ::EG::Colors(fgsel) $msgColor
  set ::EG::Colors(Red) $tagColorRed
  set ::EG::Colors(Yellow) $tagColorYellow
  set ::EG::Colors(Green) $tagColorGreen
  set ::EG::D(TextTags) {}
  foreach line [split [[$obPrf Textags] get 1.0 end] \n] {
    set line [string trim $line]
    if {$line ne {}} {
      append ::EG::D(TextTags) $line\n
    }
  }
  set ::EG::D(TextTags) [string trim $::EG::D(TextTags)]
  set DP(Items) $Items
  set DP(ItemsTypes) $ItemsTypes
  set DP(Theme) $opct
  set DP(CS) [lindex [split $opcc :] 0]
  set mainchanged [IsChangedMainSettings]
  foreach k $DPars {
    set ::EG::D($k) $DP($k)
  }
  if {$istest} {
    set argvsav $::argv
    set argcsav $::argc
    if {$::argc>1} {
      set ::argv [lreplace $::argv 1 1 $tmprc]
    } elseif {$::argc==1} {
      lappend ::argv $tmprc
    } else {
      set ::argv [list $::EG::D(FILE) $tmprc]
    }
    set ::argc [llength $::argv]
    set ::EG::D(DateUser) $tmpDateUser
    EG::SaveAllData
    catch {exec -- [info nameofexecutable] $::EG::SCRIPT {*}$::argv -test}
    set ::argv $argvsav
    set ::argc $argcsav
    set ::EG::USERFILEPG $savedUSERFILEPG
    array set ::EG::Colors $tmpcolors
    array set ::EG::D $tmpD
    EG::SaveAllData
    return
  }
  $obPrf res $win 1
  if {$mainchanged} {
    if {$isnewfile} {
      EG::FileToResource $DP(FILE)
      set ::argc 1
      set ::argv [list $DP(FILE)]
      set args -newfile
    } else {
      set args {}
    }
    EG::Exit -restart {*}$args
  } else {
    UpdateAppearance
  }
}
#_______________________

proc pref::Cancel {args} {
  # Closes Preferences.
  #   args - not empty, if called by Esc, Alt+F4 or "X" button

  fetchVars
  $obPrf res $win 0
}
#_______________________

proc pref::Help {} {
  # Shows a help on Preferences.

  EG::Help pref -width 62 -height 32
}

# ________________________ Tabs _________________________ #

proc pref::General_Tab {} {
  # Serves to layout "General" tab.

  fetchVars
  set opcc {-2: Default}
  set opcColors [list "{$opcc}"]
  for {set i -1; set n [apave::cs_MaxBasic]} {$i<=$n} {incr i} {
    if {(($i+2) % ($n/2+2)) == 0} {lappend opcColors |}
    set csname [$obPrf csGetName $i]
    lappend opcColors [list $csname]
    if {$i == $DP(CS)} {set opcc $csname}
  }
  set opcThemes [list default clam classic alt -- lightbrown darkbrown]
  if {[string first $DP(Theme) $opcThemes]<0} {
    set opct [lindex $opcThemes 0]
  } else {
    set opct $DP(Theme)
  }
  set txtColor $::EG::Colors(bgtex)
  set msgColor $::EG::Colors(fgsel)
  catch {
    image create photo img_gulls -data [::apave::iconData gulls small]
    image create photo img_color -data [::apave::iconData color small]
  }
  ttk::label $win.labellfr -text { Tags: } -foreground $::EG::Colors(fgit)
  ttk::label $win.labelmisc -text { Miscellaneous: } -foreground $::EG::Colors(fgit)
  return {
    {fra1 - - - - {-st nsew}}
    {.h_a - - - - {-pady 8}}
    {.labFL + T 1 1 {-st se -padx 3} {-t {Data file:}}}
    {.fil + L 1 3 {-st sw} {-tvar ::EG::pref::DP(FILE) -w 60
      -afteridle {EG::pref::focusFirst %w}}}
    {.h_b .labFL T 1 1 {-pady 8}}
    {.fraegdD + L 1 3 {-st w}}
    {.fraegdD.labegdD1 - - - - {-st se} {-t "Week range:   \["}}
    {.fraegdD.EntegdD1 + L 1 1 {-st sw -padx 0} {-tvar ::EG::pref::DP(egdDate1)
      -w 11 -justify center -tip "Included for data\n(click to choose)"
      -state readonly -takefocus 0 -onevent {<Button> {::EG::pref::SelEgdDate 1}}}}
    {.fraegdD.labspc + L 1 1 {} {-t {  -  }}}
    {.fraegdD.EntegdD2 + L 1 1 {-st sw -padx 0} {-tvar ::EG::pref::DP(egdDate2)
      -w 11 -justify center -tip "Excluded for data\n(click to choose)"
      -state readonly -takefocus 0 -onevent {<Button> {::EG::pref::SelEgdDate 2}}}}
    {.fraegdD.labspc2 + L 1 1 {-st sw} {-t \)}}
    {.h_c .h_b T 1 1 {-pady 8}}
    {.labD1 + T 1 1 {-st e -pady 1 -padx 3} {-t {Date format long:}}}
    {.entD1 + L 1 1 {-st sw -pady 1} {-tvar ::EG::pref::DP(DateUser) -w 20
      -validate all -validatecommand {EG::pref::ValidateDateFormat %P LabVD1}}}
    {.LabVD1 + L 1 1 {-st w -pady 1}}
    {.labD2 .labD1 T 1 1 {-st e -pady 1 -padx 3} {-t {Date format short:}}}
    {.entD2 + L 1 1 {-st sw -pady 1} {-tvar ::EG::pref::DP(DateUser2) -w 20
      -validate all -validatecommand {EG::pref::ValidateDateFormat %P LabVD2}}}
    {.LabVD2 + L 1 1 {-st w -pady 1}}
    {.labD3 .labD2 T 1 1 {-st e -pady 1 -padx 3} {-t {Date format full:}}}
    {.entD3 + L 1 1 {-st sw -pady 1} {-tvar ::EG::pref::DP(DateUser3) -w 20
      -validate all -validatecommand {EG::pref::ValidateDateFormat %P LabVD3}}}
    {.LabVD3 + L 1 1 {-st w -pady 1} {-w 30}}
    {.h_0 .labD3 T - - {-pady 8}}
    {.labTheme + T 1 1 {-st e -pady 1 -padx 3} {-t {Ttk theme:}}}
    {.opc1 + L 1 1 {-st sw -pady 1}
      {::EG::pref::opct ::EG::pref::opcThemes
      {-w 10 -compound left -image img_gulls}}}
    {.labCS .labTheme T 1 1 {-st e -pady 1 -padx 3} {-t {Color scheme:}}}
    {.opc2 + L 1 1 {-st sw -pady 1} {::EG::pref::opcc ::EG::pref::opcColors
    {-w 16 -compound left -image img_color} {EG::pref::opcCSPre %a}}}
    {.labHue .labCS T 1 1 {-st e -pady 1 -padx 3} {-t Hue:}}
    {.spxHue + L 1 1 {-st sw -pady 1}
      {-tvar ::EG::pref::DP(Hue) -from -50 -to 50 -increment 5 -w 4}}
    {.h_1 .labHue T - - {-pady 8}}
    {.lab1 .h_1 T 1 1 {-st e -pady 1 -padx 3} {-t {Color of text cell:}}}
    {.clrtxtGEO + L 1 1 {-st w -pady 1 -padx 0} {-tvar ::EG::pref::txtColor
      -title {Color for Topics with Text} -w 11}}
    {.lab2 .lab1 T 1 1 {-st e -pady 1 -padx 3} {-t {Color of messages:}}}
    {.clrmsgGEO + L 1 1 {-st w -pady 1 -padx 0} {-tvar ::EG::pref::msgColor
      -title {Color for Messages} -w 11}}
    {.lfRMisc .opc1 L 6 3 {-st nswe} {-padx 2 -pady 2 -bd 1 -relief raised
      -labelwidget $win.labelmisc -labelanchor n}}
    {.lfRMisc.labZoom - - - - {-st e} {-t Zoom:}}
    {.lfRMisc.spxZoom + L 1 1 {-st sw} {-w 3 -from 0 -to 16
      -tvar ::EG::pref::DP(Zoom)}}
    {.lfRMisc.labDFont .lfRMisc.labZoom T 1 1 {-st e -padx 3 -pady 4}
      {-t {Default font:}}}
    {.lfRMisc.fontDef + L 1 1 {-st w -pady 4} {-tvar ::EG::pref::DP(DefFont) -w 22}}
    {.lfRMisc.labTFont .lfRMisc.labDFont T 1 1 {-st e -padx 3}
      {-t {Text font:}}}
    {.lfRMisc.fontTex + L 1 1 {-st w} {-tvar ::EG::pref::DP(TexFont) -w 22}}
    {.lfRMisc.labNotetm .lfRMisc.labTFont T 1 1 {-st e -padx 3 -pady 4}
      {-t {Top stickers:}}}
    {.lfRMisc.chbNotetm + L 1 1 {-st w -pady 4} {-var ::EG::pref::DP(NoteOnTop)}}
    {.h_2 .lab2 T - - {-pady 8}}
    {.lfRTag + T 1 4 {-st nsew} {-labelwidget $win.labellfr -bd 1 -relief raised -labelanchor n}}
    {.lfRTag.fract - - - - {pack -side left -anchor n -padx 8 -pady 4}}
    {.lfRTag.fract.labc - - - - {pack -side top -anchor nw} {-t {Red, Yellow, Green}}}
    {.lfRTag.fract.clrGEOR - - - - {pack -side top -anchor n -pady 4}
      {-tvar ::EG::pref::tagColorRed -w 11 -title {Color for Red Tag}}}
    {.lfRTag.fract.clrGEOY - - - - {pack -side top -anchor n}
      {-tvar ::EG::pref::tagColorYellow -w 11 -title {Color for Yellow Tag}}}
    {.lfRTag.fract.clrGEOG - - - - {pack -side top -anchor n -pady 4}
      {-tvar ::EG::pref::tagColorGreen -w 11 -title {Color for Green Tag}}}
    {.lfRTag.Textags - - - - {pack -side left -pady 8 -expand 1 -fill both}
      {-w 40 -h 5 -tip {Each line sets tag(s) for topics.}
      -tabnext .eg.pref.fra.fraB.butOK}}
    {.lfRTag.sbvtags + L 1 1 {pack -side left -pady 8} {}}
  }
}
#_______________________

proc pref::Items_Tab {} {

  catch {
    foreach ico {up down} {
      image create photo img_$ico -data [::apave::iconData $ico small]
    }
  }
  return {
    {fra1 - - 1 2 {-st nsew}}
    {prc {EG::pref::FillItems fra1}}
    {labagg fra1 T 1 1 {-st se -pady 8} {-anchor center -t {AggrEG formula: }
      -foreground $::EG::Colors(fgit)}}
    {entagg + L 1 8 {-st sw -pady 8} {-tvar ::EG::pref::DP(AggrEG) -w 60}}
  }
}
#_______________________

proc pref::FillItems {wpar lwidgets ilw} {
  # Fills item widgets.
  #   wpar - parent window
  #   lwidgets - list of widgets
  #   ilw - current index in lwidgets
  # Returns updated list of widgets.

  fetchVars
  # row of head
  set lwidgets [linsert $lwidgets [incr ilw] ".LaB0 - - - - \
    {-st es -pady 0} {-t {} -w 3}"]
  $obPrf makeWidgetMethod $wpar .LaB0
  set lwidgets [linsert $lwidgets [incr ilw] ".fra + L"]
  set lwidgets [linsert $lwidgets [incr ilw] ".fra.LaBI2 - - - - \
    {-st es -pady 0} {-t Topic -fg $::EG::Colors(fgit) -bg $::EG::Colors(bg)}"]
  $obPrf makeWidgetMethod $wpar .fra.LaBI2
  set lwidgets [linsert $lwidgets [incr ilw] ".fra.btT1 + L - - \
    {-st ws -pady 0} {-image img_up -com {EG::pref::SwopIt -1}}"]
  set lwidgets [linsert $lwidgets [incr ilw] ".fra.btT2 + L - - \
    {-st ws -pady 0} {-image img_down -com {EG::pref::SwopIt 1}}"]
  set lwidgets [linsert $lwidgets [incr ilw] ".LaBI3 .fra L - - \
    {-st wes -pady 0} {-t Format -fg $::EG::Colors(fgit) -bg $::EG::Colors(bg)}"]
  $obPrf makeWidgetMethod $wpar .LaBI3
  set lwidgets [linsert $lwidgets [incr ilw] ".LaBI1 + L - - \
    {-st wes -pady 0} {-t Color -fg $::EG::Colors(fgit) -bg $::EG::Colors(bg)}"]
  $obPrf makeWidgetMethod $wpar .LaBI1
  set n .laB0
  set iitmax [expr {[llength $::EG::D(Items)]-1}] ;# excluding EG
  # rows of items
  for {set iit 0} {$iit<$::EG::D(MAXITEMS)} {} {
    if {$iit<$iitmax} {
      set item [lindex $::EG::D(Items) $iit]
      set frmi [lindex $::EG::D(ItemsTypes) $iit]
    } else {
      set item [set frmi {}]
    }
    incr iit
    set ::EG::pref::ClrI$iit $::EG::Colors(my$iit)
    set ::EG::pref::EntI$iit $item
    set ::EG::pref::EntF$iit $frmi
    set lwidgets [linsert $lwidgets [incr ilw] ".labI_$iit $n T 1 1\
      {-st es} {-t $iit. -w 3 -anchor e}"]
    set lwidgets [linsert $lwidgets [incr ilw] ".EntI_$iit + L 1 1 \
      {-st ws -padx 6} {-tvar ::EG::pref::EntI$iit -w 12 \
      -onevent {<Button> {EG::pref::Message {}}}}"]
    $obPrf makeWidgetMethod $wpar .EntI_$iit
    set lwidgets [linsert $lwidgets [incr ilw] ".EntF_$iit + L 1 1 \
      {-st ews} {-tvar ::EG::pref::EntF$iit -w 45 \
      -onevent {<Button> {EG::pref::Message {}}}}"]
    $obPrf makeWidgetMethod $wpar .EntF_$iit
    set lwidgets [linsert $lwidgets [incr ilw] ".ClrIGEO_$iit + L 1 1 \
      {-st ws} {-tvar ::EG::pref::ClrI$iit -w 8 \
      -onevent {<Button> {EG::pref::Message {}}}}"]
    $obPrf makeWidgetMethod $wpar .ClrIGEO_$iit
    set n .labI_$iit
  }
  return $lwidgets
}
#_______________________

proc pref::CurrentIt {} {
  # Gets index of current item.

  set foc [focus]
  if {!([string match *clrI* $foc] || [string match *entI* $foc]
  || [string match *entF* $foc])} {
    Message "Set the cursor on a topic!" 10
    return {}
  }
  return $foc
}
#_______________________

proc pref::SwopIt {to} {
  # Swops items.
  #   to - where to swop (up/down)

  fetchVars
  lassign [IsUpDown $to] i1 i2
  if {$i1} {
    FocusTopic $i1
    lassign [ItemVars $i1] clrvar1 itmvar1 frmvar1
    lassign [ItemVars $i2] clrvar2 itmvar2 frmvar2
    foreach v {clr itm frm} {
      set v1 [set ${v}var1]
      set v2 [set ${v}var2]
      set tmp1 [set $v1]
      set tmp2 [set $v2]
      set $v1 $tmp2
      set $v2 $tmp1
    }
    FocusTopic $i2
    set o1 [lindex $itemOrder [incr i1 -1]]
    set o2 [lindex $itemOrder [incr i2 -1]]
    set itemOrder [lreplace $itemOrder $i1 $i1 $o2]
    set itemOrder [lreplace $itemOrder $i2 $i2 $o1]
  }
}
#_______________________

proc pref::IsUpDown {ito} {
  # Check if the item moving is possible.
  #   ito - where to move (+1/-1)
  # Return pair of indices: from to

  Message {}
  if {[set foc [CurrentIt]] eq {}} {return 0}
  lassign [split $foc _] -> ii1
  set ii2 [expr {$ii1 + $ito}]
  if {$ii2 < 1 || $ii2 > $::EG::D(MAXITEMS)} {
    Message {Can't move the item this way!} 7
    return 0
  }
  return [list $ii1 $ii2]
}
#_______________________

proc pref::focusFirst {foc} {
  # Sets focus on entry field at 1st opening the dialog.
  #   foc - path to focus

  fetchVars
  if {![winfo exists $currTab] && ![winfo exists $currFoc]} {
    after 200 "apave::focusByForce $foc"
  }
}
#_______________________

proc pref::FocusTopic {it} {
  # Sets focus on topic field.
  #   it - index of topic

  fetchVars
  focus [string map {.clr .entclr} [$obPrf ClrIGEO_$it]]
  focus [$obPrf EntI_$it]
}
#_______________________

proc pref::ValidateDateFormat {val lab} {
  # Validates date format (in fact shows it).
  #   val - date format
  #   lab - date label

  fetchVars
  set dt [clock seconds]
  if {[catch {set val [clock format $dt -format $val]} err]} {
    set val $err
  }
  [$obPrf $lab] configure -text $val
  return 1
}
#_______________________

proc pref::CheckEgdDate1 {} {
  # Checks 1st .egd date against the last.

  fetchVars
  set dt [EG::FirstWDay [EG::ScanDatePG $DP(egdDate1)]]
  set DP(egdDate1) [EG::FormatDatePG $dt]
  set dt [clock add $dt $::EG::diagr::NDays days]
  set egdDate2 [EG::FormatDatePG $dt]
  if {$DP(egdDate1)>$DP(egdDate2) || $DP(egdDate2)>$egdDate2} {
    set DP(egdDate2) $egdDate2
    Message "Week range's Date2 is set to $egdDate2"
  } elseif {$DP(egdDate2) != $egdDate2} {
    Message "Week range's Date2 is advised to be $egdDate2"
  }
  CheckEgdDates
}
#_______________________

proc pref::CheckEgdDate2 {} {
  # Checks last .egd date against the first.

  fetchVars
  set dt [EG::FirstWDay [EG::ScanDatePG $DP(egdDate2)]]
  set DP(egdDate2) [EG::FormatDatePG $dt]
  set dt [clock add $dt -$::EG::diagr::NDays days]
  set egdDate1 [EG::FormatDatePG $dt]
  if {$DP(egdDate1)>$DP(egdDate2) || $DP(egdDate1)<$egdDate1} {
    set DP(egdDate1) $egdDate1
    Message "Week range's Date1 is set to $egdDate1"
  } elseif {$DP(egdDate1) != $egdDate1} {
    Message "Week range's Date1 is advised to be $egdDate1"
  }
  CheckEgdDates
}
#_______________________

proc pref::CheckEgdDates {} {
  # Checks 1st & last .egd dates against the curren data.

  fetchVars
  set dkeys [EG::DatesKeys]
  set D1 [lindex $dkeys 0]
  set D2 [lindex $dkeys end]
  if {$D1 ne {} && $DP(egdDate2)<$D1 || $D2 ne {} && $DP(egdDate1)>$D2} {
    EG::msg ok warn "\n\
      No data in the range $DP(egdDate1) - $DP(egdDate2)!\n\n\
      The data's range is $D1 - $D2.\n\
      _____________________________________________\n\n\
      The original range will be restored.\n"
    set DP(egdDate1) $savedEgdDate1
    set DP(egdDate2) $savedEgdDate2
  }
}
#_______________________

proc pref::SelEgdDate {ndate} {
  # Chooses egdDate (1 or 2).
  #   ndate - date number (1 or 2)

  fetchVars
  set dtvar ::EG::pref::DP(egdDate$ndate)
  if {$ndate==1} {set ttl {Week first}} {set ttl {Week last}}
  set ent [$obPrf EntegdD$ndate]
  EG::ChooseDay $dtvar -entry $ent -title $ttl -dateformat $::EG::D(DatePG) -parent $win
  if {$ndate==1} CheckEgdDate1 CheckEgdDate2
}

# ________________________ GUI procs _________________________ #

proc pref::_create {} {
  # Creates "Preferences" dialogue.

  fetchVars
  set preview 0
  ::apave::APave create $obPrf $win
  $obPrf makeWindow $win.fra Preferences
  $obPrf paveWindow \
    $win.fra [MainFrame] \
    $win.fra.fraR.nbk.f1 [General_Tab] \
    $win.fra.fraR.nbk.f2 [Items_Tab]
  if {[winfo exists $currTab] && [winfo exists $currFoc]} {
    after idle "$win.fra.fraR.nbk select $currTab"
    after idle after 300 "focus $currFoc"
  }
  foreach k {DateUser DateUser2 DateUser3} lab {LabVD1 LabVD2 LabVD3} {
    ValidateDateFormat $DP($k) $lab
  }
  $obPrf displayText [$obPrf Textags] $::EG::D(TextTags)
  bind $win <F1> "[$obPrf ButHelp] invoke"
  bind $win <Control-o> \
    [list $obPrf vieweditFile $::EG::D(FILE) {} -h {15 25} -w {60 100} -rotext _]
  $obPrf showModal $win -parent $::EG::WIN -resizable 0 \
    -onclose ::EG::pref::Cancel
  set currTab [$win.fra.fraR.nbk select]
  set currFoc [focus]
  EG::CheckAggrEG
  catch {destroy $win}
  $obPrf destroy
}
#_______________________

proc pref::_run {} {
  # Runs "Preferences" dialogue.
  # Returns yes, if settings were saved.

  fetchVars
  if {[EG::IsTestMode]} return
  EG::SaveAllData
  set itemOrder [origItemOrder]
  foreach k $DPars {set DP($k) $::EG::D($k)}
  set savedEgdDate1 $DP(egdDate1)
  set savedEgdDate2 $DP(egdDate2)
  _create
}

# _________________________________ EOF _________________________________ #
