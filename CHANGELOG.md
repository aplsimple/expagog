# Last changes:


Version `v1.4.0 (18 Jun'25)`

  - BUGFIX: at selecting date from date chooser: current cell change moved too
  - BUGFIX: default color scheme -> texts aren't monotyped
  - BUGFIX: focus entry at opening Report dialog
  - NEW   : one instance of expagog app allowed only
  - NEW   : *Find* dialog: empty value to find means "show all texts"
  - NEW   : data/tpl/repo*.html - 4 report templates
  - NEW   : *Report* dialog: "Include notes" setting
  - NEW   : *Statistics* dialog: F7 key to report
  - NEW   : statistics: AggrEG under table 1 (week data)
  - DELETE: data/tpl/stat.html
  - CHANGE: date chooser parented
  - CHANGE: stat::maxdiff = 0.5%
  - CHANGE: save cell's change at moving to other week
  - CHANGE: *Statistics* dialog: "Report" dialog to report
  - CHANGE: date chooser selects date, not week
  - CHANGE: date format full: no year by default
  - CHANGE: report's diagram setting: 1. saved; 2. if off, no diagram at all
  - CHANGE: dates in Statistics & Preferences: readonly, not disabled
  - CHANGE: clearance & docs, a bit
  - CHANGE: packages: apave 4.6.2

Version `v1.3.0 (28 May'25)`

  - BUGFIX: initiating current week's schedule if previous week is empty
  - BUGFIX: find.tcl: searching with "*?[]" in search values
  - NEW   : "Diagram" item in menu
  - NEW   : "Report" item in toolbar
  - NEW   : diagram in report (needs *tklib* package)
  - NEW   : week numbers in diagram
  - CHANGE: diagr::Draw saves current cell's value, to count it in diagram
  - CHANGE: Statistics: current date range shown as [Date1..Date2)
  - CHANGE: "Home" action: go to current day i/o current week
  - CHANGE: docs, a bit


Version `v1.2.0 (30 Apr'25)`

  - BUGFIX: incorrect octals at going to 08/09 week (from "Find")
  - BUGFIX: overlooked KP_Enter in table cells
  - NEW   : color of "Lock" button at locking changes
  - NEW   : diagram vertical mark for current day
  - NEW   : find.tcl: tips on list; number of found; saved column widths
  - NEW   : find.tcl: combobox of search values
  - NEW   : find.tcl: search in "Weekly"
  - CHANGE: find.tcl: "By words" search (words separated by spaces)
  - CHANGE: some clearance


Version `v1.1.0 (23 Apr'25)`

  - BUGFIX: color week cell of AggrEG diagram at options weeks=OFF, cumulate=OFF
  - BUGFIX: a sticker closed when its color chooser is open
  - BUGFIX: Preferences' Zoom for status bar & "Find" dialog
  - BUGFIX: locked weeks: comments on buttons moved to current cell
  - NEW   : Preferences: "Test" button to test settings
  - NEW   : popup menu of week day titles
  - NEW   : "Weekly" field (comments)
  - NEW   : repo.tcl: weekly comments
  - NEW   : tips of tab bar menu
  - DELETE: "Notes" field (general notes)
  - CHANGE: stay at a current tab when scrolling bar tabs
  - CHANGE: handling AggrEG, more simple
  - CHANGE: checking geometry of color chooser in stickers
  - CHANGE: repo.tcl: color tag comments, AggrEG in table row
  - CHANGE: packages: apave 4.6.1


Version `v1.0 (9 Apr'25)`

  - BUGFIX: diagram: switching "weeks" => \n added to comments
  - BUGFIX: calendar: highlighthing weeks with data (on other years)
  - BUGFIX: repo::RelativePath: last doctest failed
  - NEW   : *Merge* dialog
  - NEW   : *Preferences* dialog: week range
  - NEW   : *New file* dialog: week range
  - NEW   : *Preferences* dialog: fonts (default & text)
  - NEW   : week range title above diagram
  - NEW   : tab bar for multiple open egd files
  - NEW   : find.tcl: "In all" to search in multiple open egd files
  - NEW   : open stickers go to report
  - NEW   : Delete/Backspace on *chk* field clears it; 0/1/2/- sets icon
  - NEW   : stat.tcl: info on days: data/planned/checked/empty
  - NEW   : stat.tcl: *Total* in 2nd table to reflect total activity
  - NEW   : repo.tcl: colored tags
  - NEW   : diagram.tcl: for colored week cells, add comments in tips
  - NEW   : optional 2nd argument: .rc file/directory name
  - DELETE: sframe.tcl (not used)
  - CHANGE: pref.tcl: restart only if main settings changed
  - CHANGE: some settings moved from .egd to .rc file, supposedly to be global
  - CHANGE: ~/*.config*/expagog.rc be the only resource by default
  - CHANGE: repo.tcl: heading week days
  - CHANGE: stat.tcl: current week: filled with cell values & set at left side
  - CHANGE: stat.tcl: button cell values as integers; time averages rounded
  - CHANGE: note.tcl: fonts for heading & text
  - CHANGE: stickers' location is .rc directory
  - CHANGE: docs: no localization promised
  - CHANGE: week range counted in diagrams
  - CHANGE: locking data for "non-today" week ranges
  - CHANGE: at trespassing the week range: go to a week of range i/o current week
  - CHANGE: update diagram at exiting AggrEG field
  - CHANGE: tips on polygons include item name
  - CHANGE: tips with comments of calc/chk cells
  - CHANGE: EG::Date1Seconds: current date in seconds i/o [clock seconds]
  - CHANGE: saving "Y/L/N/?" i/o "yes/lamp/no/ques" for *chk*
  - CHANGE: packages: apave 4.5.8


Version `v0.9.6 (8 Mar'25)`

  - BUGFIX: saving AggrEG formula from Preferences
  - BUGFIX: Report icon's size
  - NEW   : backup .rc together with .egd (on week days)
  - NEW   : tip on status bar message
  - NEW   : length limit of item names is 16
  - NEW   : installers for 4 platforms
  - CHANGE: left padding text values in report
  - CHANGE: statusbar messages a-la alited
  - CHANGE: EG highlighted in diagram lists
  - CHANGE: calculated "Inf" is cleared
  - CHANGE: Report's file entries: -initialdir calculated for file chooser
  - CHANGE: AggrEG saved primarily in .egd, then in .rc (for new .egd)
  - CHANGE: all dialogs begin with EG::SaveAllData
  - CHANGE: localized docs moved to ./doc
  - CHANGE: demo
  - CHANGE: clearance & tidy-up


Version `v0.9 (2 Mar'25)`

  - NEW   : move to specific cell from Find dialog
  - NEW   : "pure text" cells got values and initial +/- may change it
  - NEW   : demo
  - CHANGE: layouts of main window & Preferences dialog
  - CHANGE: formulas: "topic" instead of "$topic"
  - CHANGE: helps, docs


Version `v0.8 (26 Feb'25)`

  - CHANGE: TimeDec removed from calc item's formula
  - CHANGE: helps
  - CHANGE: Find: save options; move to item+day
  - CHANGE: renaming items properly
  - CHANGE: color report's statistics


Version `v0.7 (24 Feb'25)`

  - NEW   : find.tcl
  - NEW   : rename item


Version `v0.6 (22 Feb'25)`

  - NEW   : report
  - CHANGE: note.tcl refactored


Version `v0.5 (15 Feb'25)`

  - NEW   : statistics, diagrams, AggrEG


Version `v0.4 (30 Jan'25)`

  - NEW   : notes
  - NEW   : propagate week inputs to current/next week


Version `v0.3 (15 Jan'25)`

  - CHANGE: can be used for data input


Version `v0.2 (13 Jan'25)`

  - CHANGE: more or less usable, as for data input and UI


Version `v0.1 (7 Jan'25)`

  - CHANGE: not usable yet, all's too green
