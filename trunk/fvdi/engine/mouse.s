*****
* fVDI mouse functions
*
* Copyright 1997-2000, Johan Klockars 
* This software is licensed under the GNU General Public License.
* Please, see LICENSE.TXT for further information.
*****

;lattice		equ	1		; 1 - Assemble for DevPac/Lattice

transparent	equ	1		; Fall through?

mouse_size	equ	4		; Mostly for testing
show_delay	equ	1		; 5

mouse_interval	equ	1		; Interval between mouse updates

sven_mouse	equ	1		; Use Sven's timer draw code?

	include	"vdi.inc"

*
* Macros
*
  ifne lattice
	include	"macros.dev"
  else
	include	"macros.tas"
  endc

	xref	redirect
	xref	_malloc,_free
	xref	_screen_wk,_old_curv,_old_timv

	xdef	vsc_form,v_show_c,v_hide_c
	xdef	_mouse_move,_mouse_timer

	xdef	lib_vsc_form,lib_v_show_c,lib_v_hide_c


	text

	dc.b	0,"vsc_form",0
* vsc_form - Standard Trap function
* Todo: Redraw mouse through vector
* In:   a1      Parameter block
*       a0      VDI struct
vsc_form:
	move.l	a1,-(a7)
	move.l	intin(a1),-(a7)
	move.l	a7,a1
	bsr	lib_vsc_form
	addq.l	#4,a7
	move.l	(a7)+,a1
	move.l	vwk_real_address(a0),a2		; If no mouse type, the original VDI is called too
	tst.w	wk_mouse_type(a2)
	beq	redirect			; Temporary (needs a1)
	done_return

* lib_vsc_form - Standard Library function
* Todo: ?
* In:	a1	Parameters   lib_vsc_form(pt_data)
*	a0	VDI struct
lib_vsc_form:
	movem.l	a0-a1,-(a7)
	bsr	lib_v_hide_c			; Try to hide
	movem.l	(a7)+,a0-a1

	move.l	(a1),a2
	move.l	vwk_real_address(a0),a1		; a0 no longer -> VDI
	move.l	(a2),wk_mouse_hotspot_x(a1)	; X and y coodinates
	addq.l	#6,a2
	move.l	(a2)+,wk_mouse_colour(a1)	; Mask and data colours

	move.l	a1,-(a7)
	lea	wk_mouse_mask(a1),a1
	moveq	#15,d0				; Mask and data rows
;1$:			; .loop:
 label .loop,1
	move.l	(a2)+,(a1)+
;	dbra	d0,1$	; .loop
	ldbra	d0,.loop,1
	move.l	(a7)+,a1

	move.l	wk_r_mouse(a1),d0
;	beq	2$	; .done
	lbeq	.done,2
	uses_d1
	move.l	d0,a2
	move.l	a1,d2
	add.l	#wk_mouse,d2			; Change
	move.w	mouse_op,d0
	swap	d0
	move.w	wk_mouse_position_x(a1),d0
	move.w	wk_mouse_position_y(a1),d1
	move.l	a0,-(a7)
	jsr	(a2)
;	tst.w	d0
;	beq	3$	; .no_error
	move.w	d0,mouse_op		; What to try again
	swap	d0			;  and in how long
;	neg.w	d0
	move.w	d0,pointer_delay
;3$:			; .no_error
	move.l	(a7)+,a0
	used_d1
;2$:			; .done
 label .done,2

	move.w	#1,-(a7)
	move.l	a7,a1
	bsr	lib_v_show_c
	addq.l	#2,a7

	rts


	dc.b	0,"v_show_c",0
* v_show_c - Standard Trap function
* Todo: Redraw mouse through vector when necessary
* In:   a1      Parameter block
*       a0      VDI struct
v_show_c:
	move.l	intin(a1),a2
	move.l	a1,-(a7)
	move.w	(a2),-(a7)
	move.l	a7,a1
	bsr	lib_v_show_c
	addq.l	#2,a7
	move.l	(a7)+,a1
	move.l	vwk_real_address(a0),a2		; If no mouse type, the original VDI is called too
	tst.w	wk_mouse_type(a2)
	beq	redirect			; Temporary (needs a1)
	done_return

* lib_v_show_c - Standard Library function
* Todo: ?
* In:	a1	Parameters   lib_v_show_c(reset)
*	a0	VDI struct
lib_v_show_c:
	move.w	(a1),d0				; Always show?
	move.l	vwk_real_address(a0),a1		; Does not affect flags
;	beq	2$	; .set
	lbeq	.set_,2
	move.w	wk_mouse_hide(a1),d0
;	beq	1$	; .end			; Already shown?
	lbeq	.end,1				; Already shown?
	subq.w	#1,d0
;2$:			; .set:
 label .set_,2
	move.w	d0,wk_mouse_hide(a1)
;	bhi	1$	; .end			; Still not shown?
	lbhi	.end,1				; Still not shown?

	tst.w	wk_mouse_type(a1)		; If no mouse type, leave to old VDI
;	beq	1$	; .end
	lbeq	.end,1


;	move.w	pointer_delay,d0
;	bgt	3$	; .set_delay
;	cmp.w	#-show_delay,d0
;	bge	1$	; .end
;3$:			; .set_delay:

;	move.w	#-show_delay,pointer_delay	; Turn the mouse on soon

;	move.l	wk_r_mouse(a1),d0
;	beq	mouse_show
;	move.l	d0,a2
;	movem.w	wk_mouse_position(a1),d0-d1
;	moveq	#3,d2				; Show
;	jsr	(a2)

 ifne 1
	move.l	wk_r_mouse(a1),d0
;	bne	3$	; .call_r_mouse
	lbne	.call_r_mouse,3
	uses_d1
	bsr	mouse_unshow
	used_d1
 endc
;1$:			; .end:
 label .end,1
	rts

;3$:			; .call_r_mouse
 label .call_r_mouse,3
	uses_d1
	move.l	d0,a2
	move.w	mouse_op,d0
	swap	d0
	move.w	wk_mouse_position_x(a1),d0
	move.w	wk_mouse_position_y(a1),d1
	moveq	#3,d2				; Show
	move.l	a0,-(a7)
	jsr	(a2)
	move.w	d0,mouse_op
	swap	d0
;	neg.w	d0
	move.w	d0,pointer_delay
	move.l	(a7)+,a0
	used_d1
;	bra	1$	; .end
	lbra	.end,1


	dc.b	0,"v_hide_c",0
* v_hide_c - Standard Trap function
* Todo: Remove mouse through vector when necessary
* In:   a1      Parameter block
*       a0      VDI struct
v_hide_c:
	move.l	a1,-(a7)
	bsr	lib_v_hide_c
	move.l	(a7)+,a1
	move.l	vwk_real_address(a0),a2
	tst.w	wk_mouse_type(a2)		; If no mouse type, call the old VDI too
	beq	redirect			; Temporary (needs a1)
	done_return

* lib_v_hide_c - Standard Library function
* Todo: ?
* In:	a1	Parameters   lib_v_hide_c()
*	a0	VDI struct
lib_v_hide_c:
	move.l	vwk_real_address(a0),a1
	move.w	wk_mouse_hide(a1),d0
	addq.w	#1,d0
	move.w	d0,wk_mouse_hide(a1)

	cmp.w	#1,d0				; Already hidden?
;	bhi	1$	; .not_shown
	lbhi	.not_shown,1

	tst.w	wk_mouse_type(a1)		; If no mouse type, leave to old VDI
;	beq	1$	; .end
	lbeq	.not_shown,1

	move	sr,d0
;	swap	d0				; For reuse of one word
	ori	#$700,sr
;	move.w	#1,pointer_delay
;	move.w	pointer_shown,d0		;  here,
;	move.w	#0,pointer_shown
;	swap	d0
	move	d0,sr

;	swap	d0				;  and here
;	tst.w	d0				; Not yet redrawn?
;	bmi	1$	; .not_shown

	move.l	wk_r_mouse(a1),d0
;	bne	2$	; .call_r_mouse
	lbne	.call_r_mouse,2
	uses_d1
	bsr	mouse_unshow
	used_d1
;1$:			; .not_shown:
 label .not_shown,1
	rts

;2$:			; .call_r_mouse
 label .call_r_mouse,2
	uses_d1
	move.l	d0,a2
	move.w	mouse_op,d0
	swap	d0
	move.w	wk_mouse_position_x(a1),d0
	move.w	wk_mouse_position_y(a1),d1
	moveq	#2,d2				; Hide
	move.l	a0,-(a7)
	jsr	(a2)
	move.w	d0,mouse_op
	swap	d0
;	neg.w	d0
	move.w	d0,pointer_delay
	move.l	(a7)+,a0
	used_d1
;	bra	1$	; .not_shown
	lbra	.not_shown,1


	dc.b	0,"mouse_move",0
* mouse_move - Support function
* Todo: ?
* In:	d0/d1	New x, y
mouse_move:
_mouse_move:
	swap	d0
	move.w	d1,d0
	move.l	d0,mouse_first			; Atomic
	
;	tst.w	pointer_shown			; If not hidden,
;	beq	1$	; .end	
;	move.w	#-1,pointer_delay		;  show mouse on next timer interrupt
;1$:			; .end
;	move.l	_old_curv,-(a7)			; Continue to next mouse movement routine?

	rts


	dc.b	0,0,"mouse_timer",0
* mouse_timer - Support function
* Todo: ?
* In:	-
mouse_timer:
_mouse_timer:
	tas	mouse_semaphore		; To prevent overruns
	bne	.fast_return		; Already drawing - abort!

	move.l	d0,-(sp)		; This is only useful to get rid of back and forth moves
	move.l	mouse_first,d0
 ifne 1
	cmp.l	mouse_x,d0
	bne	.moved

	addq.w	#1,pointer_delay	; <0 waiting
	beq	.moved
	bmi	.return
	move.w	#0,pointer_delay	; We don't want overflows
	bra	.return

.moved:
	; Do a proper redraw
 endc
	move.l	d0,mouse_x		; Should this be done?

	movem.l	d1-d2/a0-a2,-(a7)

;	movem.l	d0-d2/a0-a2,-(a7)
	move.l	_screen_wk,a1
;	move.l	mouse_first,d0

	move.w	d0,d1
	move.w	mouse_op,d0
	swap	d0
	move.w	d0,wk_mouse_position_x(a1)
	move.w	d1,wk_mouse_position_y(a1)
	move.l	wk_driver(a1),a0
	move.l	driver_default_vwk(a0),a0

	move.l	wk_r_mouse(a1),d2
	beq	.no_accel
	move.l	d2,a2
	moveq	#1,d2			; Assume move hidden
	tst.w	wk_mouse_hide(a1)	; Shown if zero
	bne	.move_hidden
	moveq	#0,d2
.move_hidden:
	jsr	(a2)
;	tst.w	d0
;	beq	.no_error
.no_error:
	move.w	d0,mouse_op
	swap	d0
	move.w	d0,pointer_delay
;	move.w	#1,pointer_shown
.no_draw:
	movem.l	(a7)+,d1-d2/a0-a2
.return:
	move.l	(a7)+,d0
.no_draw_yet:
	clr.b	mouse_semaphore
.fast_return:
	move.l	_old_timv,-(a7)
	rts

.no_accel:
;	tst.w	pointer_shown
;	beq	.already_hidden
	movem.l	d0-d1/a0-a1,-(a7)
	bsr	mouse_unshow
;	move.w	#0,pointer_shown
	movem.l	(a7)+,d0-d1/a0-a1
.already_hidden:
	bsr	mouse_show
	moveq	#0,d0
	bra	.no_error


	dc.b	0,"mouse_unshow",0
* mouse_unshow - Support function
* Todo: ?
* In:	a0	VDI struct
mouse_unshow:
	movem.l	d5/d7/a3/a6,-(a7)
	move.l	#0,-(a7)
	move.l	a0,-(a7)
	move.l	vwk_real_address(a0),a1
	move.l	a7,a0
	move.l	wk_r_set_pixel(a1),a3
;	movem.w	wk_mouse_position(a1),d1-d2
	move.l	wk_mouse_extra_info(a1),a6
	move.w	(a6)+,d1		; Fetch old coordinates
	move.w	(a6)+,d2
;	sub.w	wk_mouse_hotspot_x(a1),d1
	move.w	d1,d7
;	sub.w	wk_mouse_hotspot_y(a1),d2
	moveq	#mouse_size,d5
.rows_hide:
	swap	d5
	move.w	#mouse_size,d5
	move.w	d7,d1
.cols_hide:
	cmp.w	wk_screen_coordinates_min_x(a1),d1
	blt	.outside_hide
	cmp.w	wk_screen_coordinates_max_x(a1),d1
	bgt	.outside_hide
	cmp.w	wk_screen_coordinates_min_y(a1),d2
	blt	.outside_hide
	cmp.w	wk_screen_coordinates_max_y(a1),d2
	bgt	.outside_hide
	move.w	(a6)+,d0
	jsr	(a3)
.next:
	addq.w	#1,d1
	dbra	d5,.cols_hide
	addq.w	#1,d2
	swap	d5
	dbra	d5,.rows_hide

	move.l	(a7),a0
	addq.l	#8,a7
	movem.l	(a7)+,d5/d7/a3/a6
	rts

.outside_hide:
	addq.l	#2,a6
	bra	.next


	dc.b	0,"mouse_show",0
* mouse_show - Support function
* Todo: ?
* In:	a0	VDI struct
mouse_show:
	movem.l	d3-d7/a3-a6,-(a7)
	move.l	#0,-(a7)
	move.l	a0,-(a7)
	move.l	vwk_real_address(a0),a1
	move.l	a7,a0
	move.l	wk_mouse_colour(a1),d6
	movem.w	wk_mouse_position(a1),d1-d2
	sub.w	wk_mouse_hotspot_x(a1),d1
	move.w	d1,d7
	sub.w	wk_mouse_hotspot_y(a1),d2
	move.l	wk_r_set_pixel(a1),a3
	move.l	wk_r_get_pixel(a1),a4
	lea	wk_mouse_mask(a1),a2
	lea	wk_mouse_data(a1),a5
	move.l	wk_mouse_extra_info(a1),a6
	move.w	d1,(a6)+		; Remember coordinates for unshow
	move.w	d2,(a6)+
	moveq	#mouse_size,d5
.rows_show:
	swap	d5
	move.w	#mouse_size,d5
	move.w	(a2)+,d3
	move.w	(a5)+,d4
	move.w	d7,d1
.cols_show:
	cmp.w	wk_screen_coordinates_min_x(a1),d1
	blt	.outside_show
	cmp.w	wk_screen_coordinates_max_x(a1),d1
	bgt	.outside_show
	cmp.w	wk_screen_coordinates_min_y(a1),d2
	blt	.outside_show
	cmp.w	wk_screen_coordinates_max_y(a1),d2
	bgt	.outside_show
	jsr	(a4)		; Save old data
	move.w	d0,(a6)+
	move.l	d6,d0		;  and then write new
	add.w	d3,d3
	bcc	.no_pixel
	add.w	d4,d4
	bcc	.background
	jsr	(a3)
	bra	.plotted
.background:
	swap	d0
	jsr	(a3)
	swap	d0
.plotted:
	lsr.w	#1,d4		; Shift back again
.no_pixel:
	add.w	d4,d4		;  to make this possible
	addq.w	#1,d1
	dbra	d5,.cols_show
	addq.w	#1,d2
	swap	d5
	dbra	d5,.rows_show

	move.l	(a7),a0
	addq.l	#8,a7
	movem.l	(a7)+,d3-d7/a3-a6
	rts

.outside_show:
	addq.l	#2,a6
	bra	.no_pixel


pointer_delay:
	dc.w	0
;pointer_shown:
;	dc.w	0
mouse_op:
	dc.w	0
mouse_x:
	dc.w	100
mouse_y:
	dc.w	100
mouse_first:
	dc.w	100,100
mouse_semaphore:
	dc.b	0

	end
