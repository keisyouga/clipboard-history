# clipboard history
# watch clipboard periodically
# use clipboard(3tk)

package require Tk

# setup window
proc myinit {} {
	global wlist
	set f [labelframe .frame -text "clipboard history"]
	set wlist $f.list
	pack $f -expand 1 -fill both -side top
	listbox $wlist -exportselection false -listvariable clipStrHist \
	    -yscrollcommand [list $f.listscroll set] -width 30 -height 5
	scrollbar $f.listscroll -command [list $f.list yview]
	bind . <<ListboxSelect>> {
		set sel  [%W curselection]
		if {$sel ne ""} {
			showHistByNum $sel [winfo parent %W].text
		}
	}
	pack $f.list -fill both -side left
	pack $f.listscroll -fill y -side left

	text $f.text -yscrollcommand [list $f.textscroll set] -width 40 -height 5
	scrollbar $f.textscroll -command [list $f.text yview]
	pack $f.text -fill both -side left -expand 1
	pack $f.textscroll -fill both -side left

	set f [frame .buttons]
	pack $f -side bottom
	pack [button $f.exit -command exit -text "exit"] -side right
	pack [button $f.clear -command {set clipStrHist {}} -text "clear"] -side right
}

# get data from selection
proc getClipboardValue {} {
	global clipStrHist type

	# avoid error if selection no content
	if {[catch {clipboard get -type $type} contents] } {
		# fail
		# $contents would have a text like this :
		#   CLIPBOARD selection doesn't exist or form "UTF8_STRING" not defined
		return ""
	} else {
		# success
		return $contents
	}
}

# show clipboard value to text widget in number of clipboard history
proc showHistByNum {num text} {
	global clipStrHist

	set str [lindex $clipStrHist $num]

	$text delete 1.0 end
	$text insert end $str
}

# main loop
proc myloop {} {
	global clipStrHist selection interval wlist
	set clipStr [getClipboardValue]

	# append if clipboard string is updated and not empty
	if {($clipStr ne [lindex $clipStrHist end]) && ($clipStr ne "")} {
		lappend clipStrHist $clipStr
		$wlist see end
	}

	after $interval {myloop}
}

set clipStrHist {}
set interval 1000
set type STRING
if {[tk windowingsystem] eq "x11"} {
	set type UTF8_STRING
}

myinit
myloop
