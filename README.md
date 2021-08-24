# Street-Fighter-Scroll
 Fast screen scroller for Street Fighter graphical demo
 
A very quick Sam Coupé experiment for a relatively fast Mode 4 whole screen scroll for Street Fighter style games.

First, take three standard Mode 4 screens, and build lots of compiled routines (I call them 'spans') to print them quickly with the stack register.  As they are lots of strings of LD DE,nn; PUSH DE, in order to use, you must (a) jump into the correct position, and (b) modify the endpoint of the routine to JP (HL) to jump out successfully.

This gives you unpacked routines of around 144kb, and a screen printer running at a reasonable rate of 12-14 frames per second.  (I didn't bother timing it exactly, quick example, and not as fast as skipping printing completely).  However, gives plenty of ideas for expanding the idea.

To use, start by looking at the example BASIC program on the SFS main source/SF Basic.dsk image.  Look at instructions.txt for more pseudo-code.
