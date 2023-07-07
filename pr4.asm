IDEAL
MODEL small
STACK 100h
p186
DATASEG
; --------------------------
	setPixel_x dw ?
	setPixel_y dw ?
	setPixel_color dw ?
	
	draw_pixel_x dw ?
	draw_pixel_y dw ?
	draw_pixel_color dw ?

	draw_Line_x dw ?
	draw_Line_y dw ?
	draw_Line_len dw ?
	draw_Line_color dw ?
	
	draw_col_x dw ?
	draw_col_y dw ?
	draw_col_len dw ?
	draw_col_color dw ?

	draw_rect_x dw ?
	draw_rect_y dw ?
	draw_rect_lenx dw ?
	draw_rect_leny dw ?
	draw_rect_color dw ?
	
	draw_frame_x dw 100
	draw_frame_y dw 70
	draw_frame_lenx dw 14
	draw_frame_leny dw 14
	draw_frame_color dw ?
	
	draw_diagonals_x dw ?
	draw_diagonals_y dw ?
	draw_diagonals_color dw 0
	
	draw_one_x dw ?
	draw_one_y dw ?
	draw_one_color dw ?
	
	draw_two_x dw ?
	draw_two_y dw ?
	draw_two_color dw ?
	
	draw_three_x dw ?
	draw_three_y dw ?
	draw_three_color dw ?
	
	draw_four_x dw ?
	draw_four_y dw ?
	draw_four_color dw ?
	
	draw_five_x dw ?
	draw_five_y dw ?
	draw_five_color dw ?
	
	xaxis dw ?
	yaxis dw ?
	
	hearts db 3 ;we start with 3 hearts.
	
	x db ?
	y db ?
	
	letter db ?
	textColor dw 4
	
	nonogram db ' Nonogram$'
	msg2 db ' Made by Shaked Bitan$'
	msg3 db 'use w,a,s,d, space and x. use q to quit.$'
	
	check db ?
	win db ?
	colorr db ?
	
	X1 dw ?
	Y1 dw ?

	bmppic  db 'start.bmp',0
	bmpwin  db 'winwin.bmp',0
	bmplos  db 'los3.bmp',0
; --------------------------
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
game:
	;grafic mode
	mov ax,13h
	int 10h
	
	;draw the start screen:
	mov cx,1
	mov dx,1 
	mov ax, offset bmppic
	call MOR_LOAD_BMP

wait_for_space:
	mov ah,8
	int 21h
	
	cmp al,' '
	jne wait_for_space
	
	;return to text mode
	mov ax, 2h
	int 10h
	
	;grafic mode
	mov ax,13h
	int 10h
	
	call white_screen ; paint the screen in white
	call draw_chart   ;draw the chart
	call moveanddrawcube ; use moveanddrawcube to play the game.
 
; --------------------------
	
exit:
	mov ax, 4c00h
	int 21h

;==============================================
;    procedure- move and draw the frame, paint and mark squares, check if correct.
;    IN :  none  
;    OUT:  move the cube
;    EFFECTED REGISTERS  :NONE
;==============================================
proc moveanddrawcube
	pusha

	mov [draw_frame_color],14 ;set size of the frame (is constant)
	call draw_frame
	
moveit:

	;wait for w,a,s,d,x or space
	mov ah,8
	int 21h
	
	;if its space
	cmp al,' '
	jne compare_more1
	
	mov [draw_rect_color],0 ;set color and size of the square.
	mov [draw_rect_lenx],14
	mov [draw_rect_leny],14
	
	mov ax,[draw_frame_x]  ;mov the place of the frame into draw rect, so the square will be painted at the right place.
	mov [draw_rect_x],ax
	inc [draw_rect_x]
	mov ax,[draw_frame_y]
	mov [draw_rect_y],ax
	inc [draw_rect_y]
	call draw_rect ;paint the square
	
	call checkifcorrect ;the checking procedure.
	cmp [hearts],0 ;we start by making sure we didnt lose- hearts are not 0.
	jne check_win1 ;if we didnt, jump to check win.
	call losing_screen ;if we did, print lose screen and exit.
	
check_win1:
	
	cmp [win],1 ;if we won, print win screen and exit
	jne draw_the_hearts1 ;else, draw the hearts.
	call winning_screen
	jmp exit
	
draw_the_hearts1:

	call draw_hearts
	
	jmp moveit ;now jump and wait for another key.
;_____________________________________________________
	
compare_more1:
	;if its a
	cmp al,'a'
	jne compare_more2 ;compare to a, if it is not a compare more
	
	sub [draw_frame_x],15 ;first of all: check the new frame doesnt deviate.
	cmp [draw_frame_x],99 
	ja next
	add [draw_frame_x],15 ; if it does, we will draw it again at the same place and wait for a new key
	mov [draw_col_color],14
	call draw_frame 
	jmp moveit
	
next:
	;new frame doesnt deviate, so we:
	
	add [draw_frame_x],15 ; paint current frame in black
	mov [draw_frame_color],0 
	call draw_frame
	
	sub [draw_frame_x],15 ;draw the new frame in the new place (change color to yellow first)
	mov [draw_frame_color],14
	call draw_frame
	
	jmp moveit;now jump and wait for another key.
	
;____________________________________________________
 compare_more2:
	;if its s
	cmp al,'s'
	jne compare_more3 ;compare to s, if it is not s compare more.
	
	add [draw_frame_y],15 ; first of all! we check the new frame doesnt deviate.
	cmp [draw_frame_y],144 
	jb nextt
	sub [draw_frame_y],15 ; if it does, we will draw it again at the same place and wait for a new key
	mov [draw_frame_color],14
	call draw_frame 
	jmp moveit

nextt:
	;new frame doesnt deviate, so we:
	
	sub [draw_frame_y],15 ;come back to current frame, paint it in black
	mov [draw_frame_color],0
	call draw_frame
	
	add [draw_frame_y],15 ;draw the new frame in the new place (change color to yellow first)
	mov [draw_frame_color],14
	call draw_frame
	
	jmp moveit
;____________________________________________________
compare_more3:
	;if its d
	cmp al,'d'
	jne compare_more4 ;not d? compare more!
	
	add [draw_frame_x],15 ; first thing is first. check the new frame doesnt deviate.
	cmp [draw_frame_x],174 
	jb nexttt
	sub [draw_frame_x],15 ; if it does, we will draw it again and jump back to start- wait for a new key
	call draw_frame
	jmp moveit
	
nexttt:

	;new frame doesnt deviate, so we:
	
	mov [draw_frame_color],0 ;paint current frame in black
	sub [draw_frame_x],15
	call draw_frame

	mov [draw_frame_color],14 ;draw the new frame in the new place (change color to yellow first)
	add [draw_frame_x], 15
	call draw_frame
	
	jmp moveit ;back to wait for key
	
;____________________________________________________
compare_more4:
	;its w
	cmp al,'w'
	jne compare_more5 ;not w? compare even more!!!
	
	sub [draw_frame_y],15 ; check the new frame doesnt deviate. 
	cmp [draw_frame_y],69 
	ja nextttt
	add [draw_frame_y],15 ; if it does, we will draw it again at the same place and jump back to start
	call draw_frame
	jmp moveit
	
nextttt:
	;new frame doesnt deviate, so we:
	
	mov [draw_frame_color],0 ;paint current frame in black
	add [draw_frame_y],15
	call draw_frame

	mov [draw_frame_color],14 ;draw the new frame in the new place (change color to yellow first)
	sub [draw_frame_y], 15
	call draw_frame
	
	jmp moveit ;get back to start

jump: 
	jmp moveit ;back to start
;____________________________________________________

compare_more5:
	;its x
	cmp al,'x'
	jne its_q ; not x? it must be q than!
	
	mov ax,[draw_frame_x]
	mov [draw_diagonals_x],ax
	mov ax, [draw_frame_y]
	mov [draw_diagonals_y],ax
	call draw_diagonals ;draw the diagnols, according to location of the frame.
	
	call checkifcorrect ;lets check.
	cmp [hearts],0 ;we start by making sure we didnt lose- hearts are not 0.
	jne check_win ;if we didnt, jump to check win.
	call losing_screen ;if we did, print losing screen and exit.
check_win:
	cmp [win],1 ;if we won, print win screen and exit
	jne draw_the_hearts2 ;else, print hearts, again.
	call winning_screen 
	jmp exit
draw_the_hearts2: 
	;if there was a change in the amount of the hearts, we will see it now.
	call draw_hearts
	
	jmp moveit ;back to start, wait for a new key.
;____________________________________________________
its_q:
	cmp al,'q'
	jne jump ; if its any other key, go back to start and wait for another key.
	
	;return to text mode
	mov ax, 2h ;if it is q, quit from the game.
	int 10h
	
	jmp exit
	
	popa
	ret
endp moveanddrawcube
;==============================================
;    setPixel : draw a dot
;    IN :  x, y, color
;    OUT:  none
;    EFFECTED REGISTERS  :none
;==============================================
proc setPixel
	pusha
	
	mov bh,0
	mov cx, [setPixel_x]
	mov dx, [setPixel_y]
	mov ax, [setPixel_color]
	mov ah, 0ch
	int 10h
	
	popa
	ret
endp setPixel
;==============================================
;   putMessage  - print message on screen
;   IN: DH= row number  , DL = column number  , cx = the message (offset)
;   OUT:  NONE
;	EFFECTED REGISTERS : NONE
; ==============================================

proc putMessage
	pusha

	; set cursor position acording to dh dl
	MOV AH, 2       ; set cursor position
	MOV BH, 0       ; display page number
	INT 10H         ; video BIOS call
	
	; print msg
	mov dx,cx
	mov ah,9
	int 21h

	popa
	ret
endp 
;==============================================
;    draw_Pixel : draw a dot
;    IN :  x, y, color
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_pixel
	pusha
	
	mov bh,0
	mov cx, [draw_pixel_x]
	mov dx, [draw_pixel_y]
	mov ax, [draw_pixel_color]
	mov ah, 0ch
	int 10h
	
	popa
	ret
endp draw_pixel
;==============================================
;    draw_Line : draw a line
;    IN :  x, y, color, lenx
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_Line
	pusha
	mov ax,[draw_Line_x]
	mov [setPixel_x],ax
	mov ax,[draw_Line_y]
	mov [setPixel_y],ax
	mov cx,[draw_Line_len]
	mov ax,[draw_Line_color]
	mov [setPixel_color],ax

draw:
	call setPixel
	inc [setPixel_x]
	loop draw

	popa
	ret
endp draw_Line

;==============================================
;    draw_Line : draw a column
;    IN :  x, y, color, leny
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_col
	pusha
	mov ax,[draw_col_x]
	mov [setPixel_x],ax
	mov ax,[draw_col_y]
	mov [setPixel_y],ax
	mov cx,[draw_col_len]
	mov ax,[draw_col_color]
	mov [setPixel_color],ax

draw1:
	call setPixel
	inc [setPixel_y]
	loop draw1

	popa
	ret
endp draw_col
;==============================================
;    draw_rect : draw a rect
;    IN :  x, y, color, lenx, leny
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_rect
    pusha
	mov ax,[draw_rect_x]
	mov [draw_Line_x],ax

	mov ax,[draw_rect_y]
	mov [draw_Line_y],ax

	mov ax,[draw_rect_lenx]
	mov [draw_Line_len],ax

	mov ax,[draw_rect_color]
	mov [draw_Line_color],ax
	
	mov cx,[draw_rect_leny]
rect:
	call draw_Line
	inc [draw_Line_y]
	loop rect

	popa
	ret
endp draw_rect

;==============================================
;    paintscreen : paint the screen in white
;    IN :  none
;    OUT:  paint all screen in white.
;    EFFECTED REGISTERS  :NONE
;==============================================

proc white_screen

	pusha
	
	mov [draw_rect_x], 0
	mov [draw_rect_y], 0
	mov [draw_rect_lenx], 320
	mov [draw_rect_leny], 200
	mov [draw_rect_color], 15

	call draw_rect
	
	popa
	ret
endp white_screen
;==============================================
;    draw_chart : draw the chart, numbers and print messages and hearts
;    IN :  none
;    OUT:  draw the chart, numbers,messages and hearts. use procedures- draw line, draw col, draw 1,2,3,4,5, draw hearts.
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_chart
	pusha
;we start with the rows
	;set it for the first 2 raws
	mov [draw_Line_x], 100
	mov [draw_Line_y],40
	mov [draw_Line_len],75
	mov [draw_Line_color],0
	
	;loop 2 first raws
	mov cx,2
two_raws:
	call draw_Line
	add [draw_Line_y],15
	loop two_raws
	
	;set it longer for other 6 raws
	mov [draw_Line_len],105
	
	mov cx,6
six_raws:
	call draw_Line
	add [draw_Line_y],15
	loop six_raws
	
;now lets draw the columns
	; draw the first 6 columns
	mov [draw_col_x],100
	mov [draw_col_y],40
	mov [draw_col_len],105
	mov [draw_col_color],0
	
	mov cx,6
six_col:
	call draw_col
	add [draw_col_x],15
	loop six_col
	
	;set it shorter for other 2 rows, and start in lower place on the screen.
	mov [draw_col_len],75
	add [draw_col_y], 30
	
	mov cx,2
two_col:
	call draw_col
	add [draw_col_x],15
	loop two_col
	
;draw the digits,using the procedures we built:

	mov [draw_one_x],182
	mov [draw_one_y],75
	mov [draw_col_color],0
	call drawone

	mov [draw_one_x],197
	call drawone
	
	add [draw_one_y],60
	mov [draw_one_x],182
	call drawone
	
	mov [draw_two_color],0
	mov [draw_two_x],166
	mov [draw_two_y],60
	call drawtwo
	
	mov [draw_two_x],106
	call drawtwo
	
	mov [draw_four_y],59
	mov[draw_four_color],0
	mov [draw_four_x],123
	call drawfour
	
	add [draw_four_x],15
	call drawfour
	
	add [draw_four_x],15
	call drawfour
	
	mov [draw_three_color],0
	mov [draw_three_y],121
	mov [draw_three_x],181
	call drawthree
	
	mov [draw_five_color],0
	mov [draw_five_x],181
	mov [draw_five_y],90
	call drawfive
	
	add [draw_five_y],15
	call drawfive
	
	; print messages
	mov cx,offset nonogram
	mov dh,1
	mov dl,13
	call putMessage
	
	mov cx,offset msg3
	mov dh,3
	mov dl,0
	call putMessage
	
	mov cx, offset msg2
	mov dh,20
	mov dl,9
	call putMessage
	
	;print hearts
	call draw_hearts
	
	popa
	ret
endp draw_chart
;==============================================
;    procedure- draw_frame
;    IN :  x , y  ,color
;    OUT:  none
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_frame
	pusha
	;2 lines:
	mov ax, [draw_frame_x]
	mov [draw_Line_x],ax
	mov ax, [draw_frame_y]
	mov [draw_Line_y],ax
	mov [draw_Line_len],15
	mov ax, [draw_frame_color]
	mov [draw_line_color],ax
	call draw_line
	add [draw_Line_y],15
	call draw_line
	
	;2 columns
	mov ax,[draw_frame_y]
	mov [draw_col_y],ax
	mov ax,[draw_frame_x]
	mov [draw_col_x],ax
	mov [draw_col_len],15
	mov ax, [draw_frame_color]
	mov [draw_col_color],ax
	call draw_col
	inc [draw_col_len]
	add [draw_col_x],15
	call draw_col
	
	popa
	ret 
	
endp draw_frame
;==============================================
;    procedure- draw_diagonals
;    IN :  x , y  
;    OUT:  none
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_diagonals
	pusha
	
	;paint the square in white, use the location of draw frame.
	mov [draw_rect_color],15
	mov [draw_rect_lenx],14
	mov [draw_rect_leny],14
	mov ax,[draw_frame_x]
	mov [draw_rect_x],ax
	inc [draw_rect_x]
	mov ax,[draw_frame_y]
	mov [draw_rect_y],ax
	inc [draw_rect_y]
	call draw_rect
	
	;draw the diagnoms
	mov [draw_pixel_x],0
	mov [draw_pixel_y],0
	mov [draw_pixel_color],0

	mov ax,[draw_frame_x]
	mov [draw_pixel_x],ax
	inc [draw_pixel_x]
	
	mov ax,[draw_frame_y]
	mov [draw_pixel_y],ax
	inc [draw_pixel_y]
	;first pixel
	call draw_pixel
	
	mov cx,13
diagnom1:
	inc [draw_pixel_x]
	inc [draw_pixel_y]
	call draw_pixel
	loop diagnom1
	
	inc [draw_pixel_y]
	sub [draw_pixel_x],14
	
	call draw_pixel
	
	mov cx,14
diagnom2:
	dec [draw_pixel_y]
	inc [draw_pixel_x]
	call draw_pixel
	loop diagnom2
	
	popa
	ret
endp draw_diagonals
; ==============================================
; PROC: Cursor_Location --> The place of the cursor on the screen 
; IN: x, y
; OUT: none
; EFFECTED REGISTERS: none
; ==============================================
proc Cursor_Location
	pusha
	
	mov bh,0
	mov dh, [y]
	mov dl, [x]
	mov ah, 2
	int 10h
	
	popa
	ret
endp Cursor_Location
;==============================================
;    procedure- draw_hearts
;    IN :  [hearts]
;    OUT:  draw as many hearts as in [hearts] 
;    EFFECTED REGISTERS  :NONE
;==============================================
proc draw_hearts
	pusha
	
	;delete hearts: draw white rectangle where the hearts are.
	mov [draw_rect_x], 200
	mov [draw_rect_y], 40
	mov [draw_rect_color], 15
	mov [draw_rect_lenx], 70
	mov [draw_rect_leny], 20
	call draw_rect
	
	; location of the first heart
	mov [x], 25
	mov [y], 5
	
	;prints hearts
	mov dh,[hearts]
draww:
	call Cursor_Location ;locate the heart
	; print a heart
	mov ah,9
	mov al,3
	mov bh,0
	mov bl,13
	mov cx,1
	int 10h
	
	add [x], 3 ; add 3, we need space between the hearts.
	dec dh 
	cmp dh,0 
	jnz draww ; print more, until dh is 0.
	
	popa
	ret
endp draw_hearts
;==============================================
;    procedure- check color, return in [colorr]
;    IN :  X1,Y1  
;    OUT:  colorr
;    EFFECTED REGISTERS  :NONE
;==============================================
proc check_color
	pusha

	mov ah,0Dh
	mov cx,[X1] 
	mov dx,[Y1]
	int 10H ; AL = COLOR
	mov [colorr],al

	popa
	ret
endp check_color
;==============================================
;    procedure- let me know what sequance is in the square: 0= both pixels are black- square is painted in black.
;	 1= one pixel is black, the other one isnt- square is marked with x.
;	 2= both pixels are white- the square wasnt painted/marked yet.
;    IN :  xaxis,yaxis
;    OUT:  0/1/2 in [check]
;    EFFECTED REGISTERS  :NONE
;==============================================
proc sequance
	pusha
	
	mov ax,[xaxis]
	mov bx,[yaxis]
	
	;increase x and y to get in the square (not in the frame)
	inc ax 
	mov [X1],ax
	inc bx
	mov [Y1],bx
	
	call check_color 
	cmp [colorr], 0 ; if first pixel is black, check the other pixel
	je now 
	mov [check],2 ; it is white, so check is 2!
	jmp ending
	
now:
	
	inc [X1] ;move to next pixel.
	call check_color
	
	cmp [colorr],0 ;if it is black, put 0 in [check]
	jne noww ;if it isnt black, its white- we have an x. jump and put 1 in [check] 
	mov [check],0
	jmp ending
	
noww:
	
	mov [check],1
	
ending:

	popa
	ret
endp sequance
;==============================================
;    procedure- check all the squares- if they are marked correctly. if they are not, decrease hearts.
;    in addition, put 0/1 in [win]
;    IN :  [hearts]
;    OUT:  [hearts], [win]
;    EFFECTED REGISTERS  :NONE
;==============================================
proc checkifcorrect
	pusha
	; i used loops in this procedure for all lines. 
	
	mov [win],1 ;we start by assuming it is a win. if its not, if there is a mistake or not painted square, we put 0 instead. 

	mov [xaxis],70 
	mov [yaxis],70
	
	mov cx,3 ;will start by checking x in first line- loop 3 times.
line1x:
	add [xaxis],30 
	
	call sequance
	cmp [check],0 ;cmp to 0- if it is 0, we have a mistake, so decrease the hearts and mov 0 to win, than end checking.
	jne label1
	dec [hearts]
	mov [win],0
	jmp endingg

label1:
	cmp [check],2 ;if it is not a mistake, it might be not painted. mov 0 into win and check other squares.
	jne labela
	mov [win],0
labela:
	loop line1x
	
;---------------- 
	
	mov [xaxis],85 ;now lets check painted squares in first line.

	mov cx,2
line1painted:

	add [xaxis],30 
	call sequance
	cmp [check],1 ;if they are 1, we found a mistake. dec hearts, 0 into win, and jump to the end of procedure.
	jne label2
	dec [hearts]
	mov [win],0
	jmp endingg

label2: 
	cmp [check],2 ;if its not a mistake, it may be not painted. if it is, mov 0 into win and check more.
	jne labelb
	mov [win],0
labelb:
	loop line1painted
	
;----------------
	mov cx,5 ;lets check line 5, which is all painted.
	add [yaxis],15
	mov [xaxis],85
	
line2painted:
	add [xaxis],15
	call sequance
	cmp [check],1 ;if it was marked with x- check is 1, we have a mistake. dec hearts, 0 into win, end procedure.
	jne label3
	dec [hearts]
	mov [win],0
	jmp endingg
	
label3:
	cmp [check],2 ;not a mistake, but a not painted square? well than, 0 into win!
	jne labelc
	mov [win],0
labelc:
	loop line2painted
	
;----------------
	;line 3 is like line 2, we will check all of it is painted in black.
	mov [xaxis],85
	add [yaxis],15
	
	mov cx,5
line3painted:
	add [xaxis],15
	call sequance
	cmp [check],1 ;if it was marked with x- check is 1, we have a mistake. dec hearts, 0 into win, end procedure.
	jne label4
	dec [hearts]
	mov [win],0
	jmp endingg
label4:
	cmp [check],2 ;not a mistake, but a not painted square? well than, 0 into win!
	jne labeld
	mov [win],0
labeld:
	loop line3painted
	
;----------------
	
	mov [xaxis],100
	add [yaxis],15
	
	mov cx,2
line4x: ;line 4- first and last squares are x. 
	call sequance
	cmp [check],0 ;if they are painted, dec hearts, o into win and end procedure
	jne label5
	dec[hearts]
	mov [win],0
	jmp endingg

label5:
	cmp [check],2 ;make sure they are not unpainted. if they are unpainted, 0 into win.
	jne labele
	mov [win],0
labele:
	add [xaxis],60
	loop line4x
	
;----------------
	
	mov [xaxis],100
	
	mov cx,3
line4painted:
	add [xaxis],15
	call sequance
	cmp [check],1 ;we have 3 painted square in this line. make sure they are not x.
	jne label6
	dec [hearts]
	mov [win],0
	jmp endingg
label6:
	cmp [check],2 ;make sure they are not white.
	jne labelf
	mov [win],0
	
labelf:
	loop line4painted
	
;----------------
	
	mov [xaxis],85
	add [yaxis],15
	
	mov cx,2 ;last line, starts with 2 x squares
line5x1:
	add [xaxis],15
	call sequance
	cmp [check],0
	jne label7
	dec [hearts]
	mov [win],0
	jmp endingg
	
label7:
	cmp [check],2
	jne labelg
	mov [win],0
	
labelg:
	loop line5x1
	
;----------------

	add [xaxis],15 ;than one painted square
line5painted:
	call sequance
	cmp [check],1
	jne label8
	dec [hearts]
	mov [win],0
	jmp endingg
label8:
	cmp [check],2
	jne labelh
	mov [win],0
labelh:
	
;----------------

	mov cx,2 ;and now 2 more x squares.
line5x2:
	add [xaxis],15
	call sequance
	cmp [check],0
	jne label9
	dec [hearts]
	mov [win],0
	jmp endingg
label9:
	cmp [check],2
	jne labeli
	mov [win],0
labeli:
	loop line5x2
	
	;if the procedure is here and [win] still contains a 1, we have a win. end procedure.
endingg:

	popa
	ret
endp checkifcorrect
;==============================================
;    procedure- draw win screen
;    IN :  none  
;    OUT:  print winning screen
;    EFFECTED REGISTERS  :NONE
;==============================================
proc winning_screen
	pusha
	
	; sleep 
	mov ax,300
	call MOR_SLEEP
	
	;grafic mode
	mov ax,13h
	int 10h
	
	;draw the start screen:
	mov cx,1
	mov dx,1
	mov ax, offset bmpwin
	call MOR_LOAD_BMP

wait_for_q1:
	mov ah,8
	int 21h
	
	cmp al,'q'
	jne wait_for_q1
	
	;return to text mode
	mov ax, 2h
	int 10h
	
	popa
	ret
	
endp winning_screen
;==============================================
;    procedure- draw lose screen
;    IN :  none  
;    OUT:  print losing screen and exit program
;    EFFECTED REGISTERS  :NONE
;==============================================
proc losing_screen
	pusha
;grafic mode
	mov ax,13h
	int 10h
	
	;draw the start screen:
	mov cx,1
	mov dx,1
	mov ax, offset bmplos
	call MOR_LOAD_BMP

wait_for_key:
	mov ah,8
	int 21h
	
	cmp al,'q'
	jne wait_for_key
	
	;return to text mode
	mov ax, 2h
	int 10h
	
	jmp exit
	
	popa
	ret
	
endp losing_screen
;==============================================
;    draw one- draw the digit one
;    IN : x, y, color  
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc drawone
;print the number according to row , coll, color and dig
	pusha
	mov ax,[draw_one_x]
	mov [setPixel_x],ax
	mov ax,[draw_one_y]
	mov [setPixel_y],ax
	mov ax,[draw_one_color]
	mov [setPixel_color],ax
	
	call setPixel
	inc [setPixel_x]
	dec [setPixel_y]
	call setPixel
	mov cx,6
rowforone:
	inc [setPixel_y]
	call setPixel
	loop rowforone

	popa
	ret
endp drawone
;==============================================
;    draw two- draw the digit two
;    IN : x, y, color  
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc drawtwo
;print the number according to row , col, color
	pusha
	mov ax,[draw_two_x]
	mov [setPixel_x],ax
	mov ax,[draw_two_y]
	mov [setPixel_y],ax
	mov ax,[draw_two_color]
	mov [setPixel_color],ax
	
	call setPixel
	inc [setPixel_x]
	dec [setPixel_y]
	call setPixel
	inc [setPixel_x]
	call setPixel
	inc [setPixel_x]
	inc [setPixel_y]
	call setPixel
	inc [setPixel_y]
	call setPixel
	mov cx,3
diagnomfor2:
	inc [setPixel_y]
	dec [setPixel_x]
	call setPixel
	loop diagnomfor2
	inc [setPixel_y]
	call setPixel
	mov cx,3
rowfor2:
	inc [setPixel_x]
	call setPixel
	loop rowfor2

	popa
	ret
endp drawtwo
; --------------------------
;==============================================
;    draw four- draw the digit four
;    IN : x, y, color  
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc drawfour
;print the number according to row , col, color
	pusha
	mov ax,[draw_four_x]
	mov [setPixel_x],ax
	mov ax,[draw_four_y]
	mov [setPixel_y],ax
	mov ax,[draw_four_color]
	mov [setPixel_color],ax
	
	call setPixel
	mov cx,6
rowforfour:
	inc [setPixel_y]
	call setPixel
	loop rowforfour
	sub [setPixel_y],5
	dec [setPixel_x]
	call setPixel
	mov cx,2
diagnomfor4:
	inc [setPixel_y]
	dec[setPixel_x]
	call setPixel
	loop diagnomfor4
	inc [setPixel_y]
	call setPixel
	mov cx,4
rowfor4:
	inc[setPixel_x]
	call setPixel
	loop rowfor4


	popa
	ret
endp drawfour
; --------------------------
;==============================================
;    draw three- draw the digit three
;    IN : x, y, color  
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc drawthree
;print the number according to row , col, color
	pusha
	mov ax,[draw_three_x]
	mov [setPixel_x],ax
	mov ax,[draw_three_y]
	mov [setPixel_y],ax
	mov ax,[draw_three_color]
	mov [setPixel_color],ax
	
	call setPixel
	dec [setPixel_y]
	inc [setPixel_x]
	call setPixel
	inc [setPixel_x]
	call setPixel
	inc [setPixel_x]
	inc [setPixel_y]
	call setPixel
	inc [setPixel_y]
	call setPixel
	inc [setPixel_y]
	dec [setPixel_x]
	call setPixel
	dec [setPixel_x]
	call setPixel
	add [setPixel_x],2
	inc [setPixel_y]
	call setPixel
	inc [setPixel_y]
	call setPixel
	dec [setPixel_x]
	inc [setPixel_y]
	call setpixel
	dec [setPixel_x]
	call setPixel
	dec [setPixel_x]
	dec [setPixel_y]
	call setpixel
	
	popa
	ret
endp drawthree
; --------------------------
;==============================================
;    draw five- draw the digit five
;    IN : x, y, color  
;    OUT:  NONE
;    EFFECTED REGISTERS  :NONE
;==============================================
proc drawfive
;print the number according to row , col, color 
	pusha
	mov ax,[draw_five_x]
	mov [setPixel_x],ax
	mov ax,[draw_five_y]
	mov [setPixel_y],ax
	mov ax,[draw_five_color]
	mov [setPixel_color],ax
	
	call setPixel
	mov cx,3
row1for5:
	inc[setPixel_x]
	call setPixel
	loop row1for5
	
	sub [setPixel_x],3
	mov cx,3
col1for5:
	inc [setPixel_y]
	call setpixel
	loop col1for5
	
	mov cx,3
row2for5:
	inc[setPixel_x]
	call setPixel
	loop row2for5
	
	mov cx,3
col2for5:
	inc [setPixel_y]
	call setpixel
	loop col2for5
	
	mov cx,3
row3for5:
	dec [setPixel_x]
	call setPixel
	loop row3for5

	popa
	ret
endp drawfive
; --------------------------
include "MOR_LIB.ASM"
END start
