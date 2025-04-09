 WHAT IS IT?
=============

I don't really know myself. Sometimes it's easier to do something than to tell you what it is and what it's for.

The name *expagog* may be interpreted in different ways, but there is certainly a pedagogical component in it.

*Ah, pedagogy! How boring it is, Sasha, give us something more interesting!*

And here is an interesting thing for pedagogy - experiment and adventure in the *expagog* style.

---

*Well, the passion for adventure is adventurism, Sasha! The whole world is affected by this today, and a few uncles in particular.*

And here you have a bridle for adventures - *expagog*. To reduce the letters and pathos, we will shorten this name to *EG*.

Adventures are different. For example, Christians are currently in Lent (March 2025) and *EG* is perfect for the adventure called *fasting*. The whole point of *EG* is that this pedagogy should not be lean and boring, but interesting, although not without rigor as pedagogy assumes.

It's *adventure with sense* - that's what *EG* is. I've finally found a passable definition for this program.

Due to some implementation details which is discussed below, *EG* is aimed at good - good enterprises and adventures. Besides, evil is interesting only in theory, but in practice it is contrary to human nature, and if you look at evil closely, it will turn out to be sheer tediousness and depressing stupidity. The devil is primarily stupid and interesting only to fools with his stupid "details".

---

*Aren't you mocking, Sasha? Will you be giving us sermons soon? It smacks of a sect.*

Yes, there is a possibility of turning this simple *expagog* program into some kind of sectarianism. However, believe me, this was not built into *EG* initially, it is not there now and, hopefully, it will never be.

If we really get off the ground, then *EG* is not a new religion, but rather a tool for maintaining one's *religiosity*, in the way every thinking person understands it. Christians understand it in their own way, Muslims, Buddhists, Jews etc. - in their own way, but at the root of every religion lies the basic *do not offend anyone, do not act dishonestly.*

Technically, *EG* is similar to a school teacher. And as we all remember, we had different teachers. It was interesting with some, not so much with others, and with others, whatever lesson, it was an adventure for brains. And this is despite the fact that no one canceled the marks for the lessons learned. *Didn't you learn it? Sit down, poor!*

But even not very skilled teachers, by virtue of their profession, force us to do good. *EG* can be used in a similar way - sometimes skillfully, sometimes not so much, but always in the direction of good. And no sectarianism! What kind of sectarianism is there at school?

---

Thus, *EG* makes life not only interesting, but also

  - predictable about evil deeds and stupid situations
  - unpredictable about good deeds and smart situations

This means that one avoids bad deeds and stupid behavior, whereas good deeds definitely await one thanks to the motives and encouragement from *EG*.

However, get to the point.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg1.png" class="media" alt="">

 TERMS
=======

**Week** - starts on Monday and ends on Sunday.

**Topic** - an activity type of experiment / adventure, for example: *NO_smoking*, *ECO_quest*, *Feat* (spaces in the names of topics are excluded).

**Calculated topic** is calculated with the formula, for example: *Dist / Time*.

**Switchable topic** - in this topic, information is not entered from the keyboard, but switches from the *?* icon to the *yes / lamp / no* icons, according to the traffic light principle (*green / yellow / red*).

**Format** - sets the type of topic values; possible formats: number (*99.9*), time (*time*), switch (*chk*), calculated (*calc*), text (*xxx*).

**EG** (the last topic in the list) is a user's overall estimate for the day he/she have lived.

**AggrEG** is an aggregate estimate calculated by a user-defined formula, setting the *weight* of topics; it reflects the overall quality of a day / week / month / year.

**Cell** is located at the intersection of the *subject* row with the *week day* column.

**Cell value** - for topics such as numbers and time, these are their values; for the switch, these are 2 (*yes*), 1 (*lamp*), 0 (*?*) or -1 (*no*); for text, it is always 1 plus the number of initial *+* minus the number of *-* (for example, value of *++ wow!* is 3); values less than zero are reset to 0 (there is no negative in *EG*).

**Schedule** is set in the form of question marks (*?*) in the cells of the table; these are the points of your adventure desirable to fulfill, for example, a point of *Feat* on Wednesdays; the value of *?* is 0, so it *spoils the statistics* if the cell experiment has not been carried out.

**Chart** has two types: a histogram and a graph.

**Cumulative chart** is a chart, each point of which is obtained by summing the values of the previous period; the last value is the sum of all values.

**Tag** is a keyword that can be used to mark a cell; tags are available through the context menu of cells; there are three tags that mark a cell with a color.

**Cell comment** is an arbitrary text for the current cell; it can contain tags; comments can be searched with *Find* tool.

**General notes** is an arbitrary text under the diagram containing comments and conclusions on the current database, diagram etc.

**Statistics** - summary data on the current database; contains two sections of data - *Current week and plan for the next* and *Previous, current and subsequent weeks*.

**Cells / Cells0** - in statistics, they mean the total number of non-empty cells and the number of non-empty cells with a value of 0.

**Report** is an html file that contains data from the current database, including statistics; it can be used for *external use.*

**Sticker** is a short note that can be useful when working with *EG*, for example, criteria of ratings, equivalents, ideas for experiments etc.; stickers can be placed anywhere on the screen and colored in any color; open stickers are presented in the report.


 GENERAL USAGE PROCEDURE
=========================

For a quick installation of *EG*, just run an [installer of expagog](https://github.com/aplsimple/expagog/releases/tag/Installers_of_EG-1.0). Then run [expagog](https://github.com/aplsimple/expagog)'s desktop shortcut.

---

Also, when you have [Tcl/Tk](https://wiki.tcl-lang.org/) deployed on your machine and like to install and run *EG* from its source, you need only to unpack [expagog's source](https://github.com/aplsimple/expagog) to a directory and run it with *tclsh src/EG.tcl* command.

Thus, in this case the installation of *EG* is straightforward as well:

  * download *expagog.zip* from [here](https://github.com/aplsimple/expagog) or from [here](https://chiselapp.com/user/aplsimple/repository/expagog/download)

  * unpack *expagog.zip* to some directory, say *~/PG/expagog*

  * to run the installed *EG*, use the command:

        wish ~/PG/expagog/src/EG.tcl

In Linux, you can run *tclsh* instead of *wish*.

---

Generally, *EG* is run this way:

    wish ~/PG/expagog/src/EG.tcl ?egd-path? ?rc-directory?

where:

  * *egd-path* - path to data (file or directory), for example: *~/.config/egd/2025.egd*
  * *rc-directory* - path to expagog.rc (settings) or its directory, for example: *~/.config/egd*

---

When you start *EG* for the first time, a table with the *default* topics opens. You will most likely want to replace them with your own topics and possibly change other program settings.

To change the settings, click the menu button (*hamburger*) and select *Preferences*.

Then, in the *Topics* tab, replace the default topics with your own. Topic formats can also be changed. To delete a topic, it is enough to clear its name.

Note that the *Speed* topic is a calculated topic, it is a speed, i.e. *Dist/Time* (*Time* is the time spent on *Dist* distance), and can serve as an equivalent of the speed of anything, as well as a sample for entering calculated topics.

In case of difficulties, use the *Help* button for a hint. This button is present in all *EG* dialogs.

After changing the settings, save them by clicking the *Save* button. A new table with your topics will open.

All that remains now is to set a schedule of topics for the week. The schedule is set in the table by specifying question marks (*?*) in the appropriate cells, by topic and week day, as it suits you.

Probably, at first you should not overload the schedule too much with *?* signs, and 5-6 topics are quite enough.

Now that the initial setup is completed, the actual use of *expagog* program may start.

And it boils down to the fact that at the end of day you just enter data instead of *?*, i.e. time spent (distance, etc.) or icons of switchable topics.

Pay special attention to the topic **EG** - this is a general estimate of the day you have lived. Define a scale for **EG** once and for all, for example, 5, 10 or 100 point scale. You can put the evaluation criteria in a sticker, leaving it open in a screen position convenient for you.

An example of such a scale:

    - 0 : a dull day, no experiment, no good deed, everything is bad
    - 1 : empty, nominal attempt to experiment
    - 2 : an unsuccessful attempt to experiment, although not empty
    - 3 : an almost satisfactory attempt
    - 4 : satisfactory, quite acceptable attempt
    - 5 : standard successful experimentation
    - 6 : good experimentation, "above average"
    - 7 : very good experimentation (flaws are negligible)
    - 8 : almost perfect experimentation
    - 9 : I am a real experimenter, at that being modest and in harmony with people

You can comment on any cell, in the text box below the table. You can also mark cells with colors and tags by selecting them from the cell context menu.

Basically, that's it. Then, at the end of week / month / year you will only have to analyze the data with charts and statistics. They will tell you what has succeeded, what has not been very successful, where failures have occurred, what can be fixed, accelerated or slowed down.

To reflect for 5 minutes at the end of the day on what was successful and what was not - isn't it great?

The value of your data will increase along with the data volume.


 SEARCH
========

To open the search dialogue, you can click *Find* icon on the toolbar, select *Find* from the menu, or press *Ctrl+F*.

The search can be performed for text comments of cells and for text topics (if they are set in the settings).

Enter the desired value in the search entry and click *OK* button. A list of found text matches will be displayed.

If you need to search by a list of tags (i.e. just word by word), turn on the *As tags* switch.

The *Match case* mode allows you to search for case-sensitive text.

Click on any row in the list of matches found, and you will be redirected to the corresponding cell in the table.

The *Find* dialogue does not need to be closed after opening, it does not affect the operation in the main *EG* window. The *Find* dialogue's geometry and options are saved until the next session.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg3.png" class="media" alt="">


 CHARTS
========

At the start of *EG*, a histogram for the *AggrEG*  is displayed, its formula is located above the chart. The formula can be corrected at any time, the change being confirmed with Enter key. You can specify topic names in the formula, for example: *Dist/Time*.

To select another chart topic, click the drop-down list in the chart toolbar. In this list, you can select individual histogram topics or selected topics. After marking the selected topics in *Polygons* list, charts are created for them when selecting *Polygon*.

The *Totals* means the sum of all the values of all topics, regardless of their *weight* expressed in the *AggrEG* formula. Thus, *Totals* reflects your general activity in *expagog*.

The **weeks** switch allows you to create charts by weeks and days. After clicking a week or a day, the corresponding table is displayed.

The **cumulate** switch allows you to get cumulative charts in which you can see cumulative sums, the latter will be the total sum.

To update the current chart (when the data changes), you can click the **Redraw** button in the chart tools or press F5 key. You can scroll the diagram left and right with the arrow buttons.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg4.png" class="media" alt="">


 STATISTICS
============

To get statistical information about the current database, click *Statistics* button on the toolbar, select *Statistics* from the menu or press F6 key.

The database statistics consists of two sections:

  - data for the current weeks and the schedule for the next one

  - data on previous, current and subsequent weeks

The date range for the *current weeks* column is set in the report header. The data of this column is collected from the 1st date to the 2nd date (excluding it).

A data value in the report is marked in color if it has changed by more than 2% relative to the previous period.

The *Cells*  is the total number of non-empty cells in the schedule. The *Cells0* is the total number of non-empty cells with value of 0.

The average values are obtained with dividing the sums by *Cells*.

The *Report* button allows to save the statictics to html file.

The *Statistics* dialogue's geometry and options are saved until the next session.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg5.png" class="media" alt="">


 REPORT
========

To get a report on the current database, select *Report* in the menu or press *F7* key.

The *Report* dialogue with the report settings will open.

Main settings:

   - *From template file* - the source template in html format

   - *To resulting .html* - the report in html format

Preferences of the report heading:

   - *Title* - custom name for the report

   - *Normal* - plain text

   - *Red* - highlighted text

If you do not plan to use the report somewhere on some website, you can leave the html settings unchanged.

Otherwise, you can change the html settings as follows:

   - *Css file* - a CSS file

   - *Icon file* - an icon file

   - *1st .js file* - the 1st JavaScript file to be executed by the browser

   - *2nd .js file* - the 2nd JavaScript file

   - *JS code* - JavaScript code to be executed by a browser

To create the report, click the **Report** button.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg6.png" class="media" alt="">


 CUSTOMIZATION
===============

To change the settings of the current database, choose *Preferences* in the menu.

As for data contents, the main settings are a list of tags and a list of topics.

The tags can be set in the first tab of the settings. You can define three colors for highlighting cells with color and tagging cells with Red, Yellow, and Green tags.

In the text box of the tags, you can enter them as a list of keywords. The tags will be available in the table from the cell context menu.

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg2.png" class="media" alt="">

The list of topics is in the second tab of the settings. Each topic has:

  - color (for diagrams)

  - name

  - data type

Data types:

  - *9, 99, 999, etc.* are for integer numbers

  - *9.9, 99.9, 999.99 etc.* are for real numbers

  - *time* is entered in the table as hh.mm (hours.minutes), displayed as hh:mm

  - *chk* is switchable between *?*, *yes*, *lamp*, *no*, meaning the values 0, 2, 1, -1 respectively

  - *calc* is a calculated type

  - *xxxxxx* is arbitrary text type, possibly with leading characters *+* /*-*
to increase/decrease its value

The calculated type (*calc*) is set as:

     calc:format:formula

where *format* is the format of the number obtained as a result of the calculation, *formula* is the calculation formula that includes the names of topics, for example:

     calc:99.9:Dist/Time

Topics can be shuffled in the list with the *arrow* buttons.

You can enter new topics in the empty lines.

You can also rename existing topics. It is advisable to give short names to the topics. The name length's limit is 16. Spaces in the names are excluded.

You can delete a topic by simply clearing its name. It is important to remember that the data entries of the deleted topic are not removed from the database, the topic simply becomes *invisible*. You can restore its visibility by adding it to the list of topics again.

In *Topics* tab, you can also enter the formula for the "aggregate EG estimate" - *AggrEG*. By default, it is equal to the value of the topic "EG", but in principle, the formula can either increase or decrease the weight of individual topics. If the values of topic have a negative meaning (for example, *Cigarettes_smoked*), then it should be negative in the *AggrEG* formula, for example:

     EG * 10 + Lives_saved * 100 - Cigarettes_smoked * 5

The *AggrEG* formula can include both names and topic numbers as *$N*, for example:

     EG*10 + $1*100 - $9*5

 <img src="https://github.com/aplsimple/expagog/releases/download/Screens_of_EG-1.0/eg22.png" class="media" alt="">


 SAVING DATA
=============

To save your data, always close *EG* after entering the data.

To create an archived copy of the current database, choose *Backup* in the menu.

After that, you will be prompted to specify the file name of the archived copy. Specify any one.

Copies of the archive will be also created by day of the week, so if necessary, you can always restore data from the archives of the previous 6 days.

You can also set the auto-save mode for an archived copy at exiting *EG*.

Consider also the following:

 1) If your data is stored on a USB flash drive (like mine, for example), then it's best to archive it to another medium, and vice versa. Then, if you lose one medium, you will at least have an archive on the other.

 2) To save data while working with *EG*, press *Save* button in the *EG* toolbar, or select *Save* from the menu, or press *Ctrl+S*.

 3) After entering a value of a cell, confirm it with Enter key.

And again: always close *EG* after entering the data! The big red button at the top right corner will help you.


 POSSIBLE QUESTIONS
====================

**Question**:

Why are there no password nor data encryption options?

**Answer**:

The *expagog* program is about good experiments and adventures, and they have not to be hidden, as Christ commanded us (Matthew 5:15-16).

Moreover, the openness of the *EG* database will scare away those wanting to use this program not for good, but for evil.

---

**Question**:

Why choose a home-made database format? Why not SQLite? Why not JSON?

**Answer**:

About SQLite. See the answer above.

About JSON. The data in *EG* is stored as *Tcl* dictionary. For greater survivability, the key-value pairs are stored line by line.

I don't see much difference between the *JavaScript* json format and the *Tcl* dictionary format. The *expagog* program has been written in *Tcl*, by the way.

Exporting *EG* data to .json file can be implemented if desired, by the questioner. It's an easy exercise in *Tcl* language and an easy adventure in *EG* style.

---

**Question**:

Why is the program not localized in my language X?

**Answer**:

Knowing a few English words hasn't hurt anyone yet.

*EG* is just a form, not a content. The content can be in any X language.

---

**Question**:

Why does the *EG* table start on January 1? Is it possible to start, say, on September 1?

**Answer**:

Yes, it is possible. The appropriate setting is Preferences' *Week range*.

*Week range*'s first date is included in data and *Week range*'s second date is excluded from data which is shown as *[Date1 - Date2)*.

To select *Date1* or *Date2*, just click its field and choose a date from the calendar.

*Date2* cannot be greater than *Date1 + 53 weeks* which means maximum *Week range* is one year.

Nothing prevents you from splitting the year into periods, e.g. 1st semester, 2nd semester, summer etc., and creating separate data files for this purpose.

The *Merge* menu item can be used to merge those separate data files into one file.


 WHAT ELSE
===========

John Steinbeck ("The Leader of the People"):

*"In boats I might, sir."*

*"No place to go, Jody. Every place is taken. But that's not the worst - no, not the worst. Westering has died out of the people. Westering isn't a hunger any more. It's all done. Your father is right. It is finished."*

---

Anton Chekhov ("Gooseberries"):

*Every happy man should have someone with a little hammer at his door to knock and remind him that there are unhappy people, and that, however happy he may be, life will sooner or later show its claws, and some misfortune will befall him — illness, poverty, loss, and then no one will see or hear him, just as he now neither sees nor hears others. But there is no man with a hammer, and the happy go on living, just a little fluttered with the petty cares of every day, like an aspen-tree in the wind — and everything is all right.*

---

Grigoriy Gorin ([The Very Same Munchhausen](https://en.wikipedia.org/wiki/The_Very_Same_Munchhausen)):

*Ramkopf (reads): “From eight to ten is A FEAT"!*

*The Mayor: What does it mean?*

*The Baroness: This means that he has a feat planned from eight to ten in the morning... What would you say about a man who goes to a feat every day, just for service?!*

---

*EG* might become kind of *someone with a little hammer* to call one to *westering*, to *eastering*, to *feat*... whatever one prefers.


 LINKS
=======

Sources:

  - [on ChiselApp](https://chiselapp.com/user/aplsimple/repository/expagog)

  - [on GitHub](https://github.com/aplsimple/expagog)

Installers:

  - [for Linux and Windows](https://github.com/aplsimple/expagog/releases/tag/Installers_of_EG-1.0)

Demo video:

  - [as .mp4](https://github.com/aplsimple/expagog/releases/tag/Demos_of_EG-1.0)
