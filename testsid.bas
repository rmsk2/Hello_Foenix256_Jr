1     selected$ = "left"
2     key$ = ""
5     print "SID test program"
6     print "----------------"
7     print "Use CRSR left/right to select SID"
8     print "Use RETURN to play sound"
9     print "Use x to quit"
10    cursor off
19    repeat 
20        printselection(selected$)
40        if asc(key$) = 2 
43            selected$ = "left"
50        else
60            if asc(key$) = 6
70                selected$ = "right"   
80           else
90               if asc(key$) = 13 : testsid(selected$):endif
100          endif
190        endif
195        key$ = inkey$()
200   until key$ = "x"
205   print 
207   print "done"
210   cursor on
498   end 
499   print "done"
500   proc testsid(sidpos$)
505       local sid,n
510       sid=$D500
511       if sidpos$<>"right"then sid=$D400
519       poke sid+24,15
520       poke sid+5,194
530       poke sid+6,90
540       poke sid,180
550       poke sid+1,8
560       poke sid+4,33
570       for n=1 to 15000:next 
580       poke sid+4,32
600  endproc 
700  proc printselection(pos$)
705      print chr$(1);
710      print "Selected SID: " pos$ "   ";
1000 endproc

