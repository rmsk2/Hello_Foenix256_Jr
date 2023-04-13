5     print "SID test program"
6     print "----------------"
7     print 
8     input "Left or right sid? ";s$
10    testsid(s$)
100   end 
500   proc testsid(sidpos$)
505   local sid,n
510   sid=$D500
511   if sidpos$<>"right"then sid=$D400
519   poke sid+24,15
520   poke sid+5,194
530   poke sid+6,90
540   poke sid,180
550   poke sid+1,8
560   poke sid+4,33
570   for n=1 to 15000:next 
580   poke sid+4,32
590   print "done"
1000  endproc 
