;	xref	Mxalloc,Malloc,Mfree
;	xref	Cconws,Cconis,Crawcin
;	xref	Super,Setexc
;	xref	Fopen,Fread,Fclose
;	xref	Fsetdta,Fsfirst

	xdef	_Mxalloc,_Malloc,_Mfree
	xdef	_Cconws,_Cconis,_Crawcin
	xdef	_Bconout
	xdef	__ulmod,__uldiv,__ldiv,__lmul
	xdef	_Super,_Setexc
	xdef	_Fopen,_Fread,_Fclose
	xdef	_Fsetdta,_Fsfirst

	xdef	_lib_vdi_s,_lib_vdi_sp,_lib_vdi_spppp,_lib_vdi_pp

	xdef	_set_stack_call_pvlpl,_set_stack_call_lppll,_set_stack_call_lpppll
	xdef	_set_stack_call_lplll,_set_stack_call_lvplp
	xdef	_set_stack_call_lvppl

	
	text

* long set_stack_call(new_stack, stack_size, function, par1, par2, par3, par4)
* Calls with new stack function(par1, par2, par3, par4)
_set_stack_call_pvlpl:
_set_stack_call_lppll:
_set_stack_call_lplll:
_set_stack_call_lvplp:
_set_stack_call_lvppl:
	move.l	a7,a0		; Set new stack and remember old
	move.l	4(a7),a7
	move.l	a0,-(a7)

	move.l	8(a0),-(a7)
	lea	4*4+16(a0),a1	; Copy 4 longs worth of actual parameters
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	12(a0),a1
	jsr	(a1)
	add.w	#4*4+4,a7

	move.l	(a7),a7		; Return to original stack
	rts

_set_stack_call_lpppll:
	move.l	a7,a0		; Set new stack and remember old
	move.l	4(a7),a7
	move.l	a0,-(a7)

	move.l	8(a0),-(a7)
	lea	5*4+16(a0),a1	; Copy 5 longs worth of actual parameters
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	-(a1),-(a7)
	move.l	12(a0),a1
	jsr	(a1)
	add.w	#5*4+4,a7

	move.l	(a7),a7		; Return to original stack
	rts


 ifne 0
_lib_vdi_s:
_lib_vdi_sp:
_lib_vdi_spppp:
_lib_vdi_pp:
	move.l	a2,-(a7)
	move.l	8+0(a7),a2
	move.l	8+4(a7),a0
	lea	8+8(a7),a1
	jsr	(a2)
	move.l	(a7)+,a2
	rts
 else
_lib_vdi_s:
	move.l	a2,-(a7)
	move.l	8+0(a7),a2
	move.l	8+4(a7),a0
	lea	8+8(a7),a1
	move.w	2(a1),(a1)
	jsr	(a2)
	move.l	(a7)+,a2
	rts

_lib_vdi_sp:
	move.l	a2,-(a7)
	move.l	8+0(a7),a2
	move.l	8+4(a7),a0
	lea	8+8(a7),a1
	move.w	2(a1),(a1)
	move.l	4(a1),2(a1)
	jsr	(a2)
	move.l	(a7)+,a2
	rts

_lib_vdi_spppp:
	move.l	a2,-(a7)
	move.l	8+0(a7),a2
	move.l	8+4(a7),a0
	lea	8+8(a7),a1
	move.w	2(a1),(a1)
	move.l	4(a1),2(a1)
	move.l	8(a1),6(a1)
	move.l	12(a1),10(a1)
	move.l	16(a1),14(a1)
	jsr	(a2)
	move.l	(a7)+,a2
	rts

_lib_vdi_pp:
	move.l	a2,-(a7)
	move.l	8+0(a7),a2
	move.l	8+4(a7),a0
	lea	8+8(a7),a1
	jsr	(a2)
	move.l	(a7)+,a2
	rts
 endc
	
_Mxalloc:
	move.l	a2,-(a7)
	move.w	8+4(a7),-(a7)
	move.l	8+2+0(a7),-(a7)
	move.w	#$44,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	(a7)+,a2
	rts

_Malloc:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Mfree:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Cconws:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#$09,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Cconis:
	move.l	a2,-(a7)
	move.w	#$0b,-(a7)
	trap	#1
	addq.l	#2,a7
	move.l	(a7)+,a2
	rts

_Crawcin:
	move.l	a2,-(a7)
	move.w	#$07,-(a7)
	trap	#1
	addq.l	#2,a7
	move.l	(a7)+,a2
	rts

_Bconout:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Super:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Setexc:
	move.l	a2,-(a7)
	move.l	8+2(a7),-(a7)
	move.w	8+4+0(a7),-(a7)
	move.w	#$05,-(a7)
	trap	#13
	addq.l	#8,a7
	move.l	(a7)+,a2
	rts

_Fopen:
	move.l	a2,-(a7)
	move.w	8+4(a7),-(a7)
	move.l	8+2+0(a7),-(a7)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	(a7)+,a2
	rts

_Fread:
	move.l	a2,-(a7)
	move.l	8+6(a7),-(a7)
	move.l	8+4+2(a7),-(a7)
	move.w	8+4+4+0(a7),-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	add.w	#12,a7
	move.l	(a7)+,a2
	rts

_Fclose:
	move.l	a2,-(a7)
	move.w	8+0(a7),-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	move.l	(a7)+,a2
	rts

_Fsetdta:
	move.l	a2,-(a7)
	move.l	8+0(a7),-(a7)
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	(a7)+,a2
	rts

_Fsfirst:
	move.l	a2,-(a7)
	move.w	8+4(a7),-(a7)
	move.l	8+2+0(a7),-(a7)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	move.l	(a7)+,a2
	rts
	
	end
