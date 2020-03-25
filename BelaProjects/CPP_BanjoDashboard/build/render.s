	.text
	.syntax unified
	.eabi_attribute	67, "2.09"	@ Tag_conformance
	.cpu	cortex-a8
	.eabi_attribute	6, 10	@ Tag_CPU_arch
	.eabi_attribute	7, 65	@ Tag_CPU_arch_profile
	.eabi_attribute	8, 1	@ Tag_ARM_ISA_use
	.eabi_attribute	9, 2	@ Tag_THUMB_ISA_use
	.fpu	neon
	.eabi_attribute	17, 1	@ Tag_ABI_PCS_GOT_use
	.eabi_attribute	20, 2	@ Tag_ABI_FP_denormal
	.eabi_attribute	23, 1	@ Tag_ABI_FP_number_model
	.eabi_attribute	34, 1	@ Tag_CPU_unaligned_access
	.eabi_attribute	24, 1	@ Tag_ABI_align_needed
	.eabi_attribute	25, 1	@ Tag_ABI_align_preserved
	.eabi_attribute	28, 1	@ Tag_ABI_VFP_args
	.eabi_attribute	38, 1	@ Tag_ABI_FP_16bit_format
	.eabi_attribute	18, 4	@ Tag_ABI_PCS_wchar_t
	.eabi_attribute	26, 2	@ Tag_ABI_enum_size
	.eabi_attribute	14, 0	@ Tag_ABI_PCS_R9_use
	.eabi_attribute	68, 1	@ Tag_Virtualization_use
	.file	"/root/Bela/projects/BanjoDashboard/build/render.bc"
	.globl	_Z23auxiliarySensorReadLoopPv
	.p2align	2
	.type	_Z23auxiliarySensorReadLoopPv,%function
_Z23auxiliarySensorReadLoopPv:          @ @_Z23auxiliarySensorReadLoopPv
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
	.setfp	r11, sp, #28
	add	r11, sp, #28
	.pad	#4
	sub	sp, sp, #4
	.vsave	{d8, d9, d10}
	vpush	{d8, d9, d10}
	movw	r9, :lower16:gShouldStop
	movt	r9, :upper16:gShouldStop
	ldr	r0, [r9]
	cmp	r0, #0
	bne	.LBB0_8
@ BB#1:                                 @ %.lr.ph26.preheader
	vmov.f32	d9, #1.000000e+00
	movw	r4, :lower16:touchSensor
	vmov.i32	d10, #0x0
	movw	r10, :lower16:.L_MergedGlobals
	vldr	s16, .LCPI0_0
	movt	r4, :upper16:touchSensor
	movt	r10, :upper16:.L_MergedGlobals
	mov	r8, #20
.LBB0_2:                                @ %.lr.ph26
                                        @ =>This Loop Header: Depth=1
                                        @     Child Loop BB0_4 Depth 2
	mov	r0, r4
	bl	_ZN5Trill13readLocationsEv
	mov	r0, r4
	bl	_ZN5Trill15numberOfTouchesEv
	cmp	r0, #1
	blt	.LBB0_5
@ BB#3:                                 @ %.lr.ph.preheader
                                        @   in Loop: Header=BB0_2 Depth=1
	add	r6, r10, #32
	mov	r7, #0
.LBB0_4:                                @ %.lr.ph
                                        @   Parent Loop BB0_2 Depth=1
                                        @ =>  This Inner Loop Header: Depth=2
	uxtb	r5, r7
	mov	r0, r4
	mov	r1, r5
	bl	_ZN5Trill13touchLocationEh
	vmov	s0, r0
	mov	r0, r4
	vcvt.f32.s32	d16, d0
	mov	r1, r5
	vmul.f32	d0, d16, d8
	vmin.f32	d1, d0, d9
	vcmpe.f32	s0, #0
	vmrs	APSR_nzcv, fpscr
	vmovlt.f32	s2, s20
	vstr	s2, [r6]
	bl	_ZN5Trill9touchSizeEh
	ldrd	r2, r3, [r10, #24]
	add	r7, r7, #1
	vmov	s0, r2
	vcvt.f32.s32	d16, d0
	vmov	s0, r3
	vcvt.f32.s32	d17, d0
	vmov	s0, r0
	mov	r0, r4
	vcvt.f32.s32	d18, d0
	vsub.f32	d0, d17, d16
	vsub.f32	d1, d18, d16
	vdiv.f32	s0, s2, s0
	vcmpe.f32	s0, #0
	vmrs	APSR_nzcv, fpscr
	vmin.f32	d1, d0, d9
	vmovlt.f32	s2, s20
	vstr	s2, [r6, #20]
	bl	_ZN5Trill15numberOfTouchesEv
	add	r6, r6, #4
	cmp	r7, r0
	blt	.LBB0_4
.LBB0_5:                                @ %._crit_edge
                                        @   in Loop: Header=BB0_2 Depth=1
	mov	r0, r4
	bl	_ZN5Trill15numberOfTouchesEv
	str	r0, [r10]
	cmp	r0, #4
	bgt	.LBB0_7
@ BB#6:                                 @ %.lr.ph23.preheader
                                        @   in Loop: Header=BB0_2 Depth=1
	sub	r5, r8, r0, lsl #2
	add	r6, r10, r0, lsl #2
	add	r0, r6, #32
	mov	r1, #0
	mov	r2, r5
	bl	memset
	add	r0, r6, #52
	mov	r1, #0
	mov	r2, r5
	bl	memset
.LBB0_7:                                @ %._crit_edge24
                                        @   in Loop: Header=BB0_2 Depth=1
	ldr	r0, [r10, #4]
	bl	usleep
	ldr	r0, [r9]
	cmp	r0, #0
	beq	.LBB0_2
.LBB0_8:                                @ %._crit_edge27
	vpop	{d8, d9, d10}
	add	sp, sp, #4
	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
	.p2align	2
@ BB#9:
.LCPI0_0:
	.long	967038730               @ float 3.12499993E-4
.Lfunc_end0:
	.size	_Z23auxiliarySensorReadLoopPv, .Lfunc_end0-_Z23auxiliarySensorReadLoopPv
	.fnend

	.globl	_Z9updateGuiv
	.p2align	2
	.type	_Z9updateGuiv,%function
_Z9updateGuiv:                          @ @_Z9updateGuiv
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r7, r8, r9, r11, lr}
	push	{r4, r5, r6, r7, r8, r9, r11, lr}
	.setfp	r11, sp, #24
	add	r11, sp, #24
	.pad	#8
	sub	sp, sp, #8
	movw	r0, :lower16:_ZTIi
	movw	r8, :lower16:.L_MergedGlobals
	movt	r0, :upper16:_ZTIi
	movt	r8, :upper16:.L_MergedGlobals
	ldr	r0, [r0, #4]
	mov	r6, r8
	ldr	r1, [r6], #32
	movw	r9, :lower16:gui
	str	r1, [sp, #4]
	mov	r3, #4
	mov	r1, r0
	movt	r9, :upper16:gui
	ldrb	r2, [r1], #1
	str	r3, [sp]
	add	r3, sp, #4
	cmp	r2, #42
	mov	r2, #0
	movne	r1, r0
	mov	r0, r9
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	movw	r0, :lower16:_ZTIf
	mov	r4, #20
	movt	r0, :upper16:_ZTIf
	mov	r2, #1
	ldr	r7, [r0, #4]
	mov	r3, r6
	mov	r5, r7
	mov	r1, r7
	ldrb	r0, [r5], #1
	str	r4, [sp]
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	mov	r1, r7
	add	r3, r8, #52
	mov	r2, #2
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	str	r4, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigString1
	mov	r1, r7
	mov	r6, #2048
	cmp	r0, #42
	movt	r3, :upper16:sigString1
	moveq	r1, r5
	mov	r0, r9
	mov	r2, #3
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigString2
	mov	r1, r7
	movt	r3, :upper16:sigString2
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	mov	r2, #4
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigString3
	mov	r1, r7
	movt	r3, :upper16:sigString3
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	mov	r2, #5
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigString4
	mov	r1, r7
	movt	r3, :upper16:sigString4
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	mov	r2, #6
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigString5
	mov	r1, r7
	movt	r3, :upper16:sigString5
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	mov	r2, #7
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigMag1
	mov	r1, r7
	movt	r3, :upper16:sigMag1
	cmp	r0, #42
	mov	r0, r9
	moveq	r1, r5
	mov	r2, #8
	str	r6, [sp]
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	ldrb	r0, [r7]
	movw	r3, :lower16:sigMag2
	movt	r3, :upper16:sigMag2
	mov	r2, #9
	cmp	r0, #42
	mov	r0, r9
	movne	r5, r7
	str	r6, [sp]
	mov	r1, r5
	bl	_ZN3Gui12doSendBufferEPKcjPKvj
	sub	sp, r11, #24
	pop	{r4, r5, r6, r7, r8, r9, r11, pc}
.Lfunc_end1:
	.size	_Z9updateGuiv, .Lfunc_end1-_Z9updateGuiv
	.fnend

	.globl	setup
	.p2align	2
	.type	setup,%function
setup:                                  @ @setup
.Lfunc_begin0:
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r10, r11, lr}
	push	{r4, r5, r6, r10, r11, lr}
	.setfp	r11, sp, #16
	add	r11, sp, #16
	.pad	#64
	sub	sp, sp, #64
	mov	r5, r0
	vmov.f32	d1, #1.000000e+00
	vldr	s0, [r5, #32]
	movw	r6, :lower16:.L_MergedGlobals
	movt	r6, :upper16:.L_MergedGlobals
	mov	r4, #0
	vdiv.f32	s0, s2, s0
	movw	r0, :lower16:sigString1
	movt	r0, :upper16:sigString1
	mov	r1, #0
	mov	r2, #2048
	vstr	s0, [r6, #20]
	str	r4, [r6, #16]
	vmov.f64	d17, #1.000000e+00
	vldr	s0, [r6, #8]
	vcvt.f64.s32	d16, s0
	vdiv.f64	d16, d17, d16
	vcvt.f32.f64	s0, d16
	vstr	s0, [r6, #12]
	bl	memset
	movw	r0, :lower16:sigString2
	mov	r1, #0
	movt	r0, :upper16:sigString2
	mov	r2, #2048
	bl	memset
	movw	r0, :lower16:sigString3
	mov	r1, #0
	movt	r0, :upper16:sigString3
	mov	r2, #2048
	bl	memset
	movw	r0, :lower16:sigString4
	mov	r1, #0
	movt	r0, :upper16:sigString4
	mov	r2, #2048
	bl	memset
	movw	r0, :lower16:sigString5
	mov	r1, #0
	movt	r0, :upper16:sigString5
	mov	r2, #2048
	bl	memset
	movw	r0, :lower16:sigMag1
	mov	r1, #0
	movt	r0, :upper16:sigMag1
	mov	r2, #2048
	bl	memset
	movw	r0, :lower16:sigMag2
	mov	r1, #0
	movt	r0, :upper16:sigMag2
	mov	r2, #2048
	bl	memset
	ldr	r1, [r6, #120]
	mov	r2, #24
	ldr	r0, [r6, #72]
	movw	r6, :lower16:touchSensor
	movt	r6, :upper16:touchSensor
	str	r1, [sp]
	str	r0, [sp, #4]
	mov	r0, r6
	mov	r1, #1
	mov	r3, #0
	bl	_ZN5Trill5setupEiiiii
	cmp	r0, #0
	bne	.LBB2_16
@ BB#1:
	ldrb	r1, [r6, #17]
	movw	r0, :lower16:.L.str.5
	movt	r0, :upper16:.L.str.5
	bl	printf
	ldrb	r1, [r6, #18]
	movw	r0, :lower16:.L.str.6
	movt	r0, :upper16:.L.str.6
	bl	printf
	ldrb	r0, [r6, #17]
	cmp	r0, #1
	bne	.LBB2_17
@ BB#2:
	movw	r0, :lower16:_Z23auxiliarySensorReadLoopPv
	movw	r2, :lower16:.L.str.3
	movt	r0, :upper16:_Z23auxiliarySensorReadLoopPv
	movt	r2, :upper16:.L.str.3
	mov	r1, #50
	mov	r3, #0
	bl	Bela_createAuxiliaryTask
	bl	Bela_scheduleAuxiliaryTask
	add	r4, r5, #92
	add	r0, sp, #36
	add	r6, r0, #8
	str	r6, [sp, #36]
	mov	r0, r4
	bl	strlen
	mov	r5, r0
	cmp	r5, #15
	str	r5, [r11, #-20]
	bls	.LBB2_5
@ BB#3:                                 @ %.noexc8.i
.Ltmp0:
	add	r0, sp, #36
	sub	r1, r11, #20
	mov	r2, #0
	bl	_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERjj
.Ltmp1:
@ BB#4:                                 @ %.noexc
	ldr	r1, [r11, #-20]
	str	r0, [sp, #36]
	str	r1, [sp, #44]
	b	.LBB2_6
.LBB2_5:                                @ %._crit_edge.i.i.i.i
	mov	r0, r6
.LBB2_6:
	cmp	r5, #0
	beq	.LBB2_10
@ BB#7:
	cmp	r5, #1
	bne	.LBB2_9
@ BB#8:
	ldrb	r1, [r4]
	strb	r1, [r0]
	b	.LBB2_10
.LBB2_9:
	mov	r1, r4
	mov	r2, r5
	bl	memcpy
.LBB2_10:                               @ %._crit_edge.i.i.i.i19
	ldr	r0, [r11, #-20]
	mov	r2, #0
	str	r0, [sp, #40]
	add	r3, sp, #8
	ldr	r1, [sp, #36]
	add	r5, r3, #8
	strb	r2, [r1, r0]
	mov	r0, #105
	str	r5, [sp, #8]
	strb	r0, [sp, #18]
	movw	r0, #30055
	strh	r0, [sp, #16]
	mov	r0, #3
	str	r0, [sp, #12]
	strb	r2, [sp, #19]
.Ltmp3:
	movw	r0, :lower16:gui
	add	r1, sp, #36
	movt	r0, :upper16:gui
	movw	r2, #5555
	bl	_ZN3Gui5setupENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEjS5_
.Ltmp4:
@ BB#11:
	ldr	r0, [sp, #8]
	cmp	r0, r5
	beq	.LBB2_13
@ BB#12:
	bl	_ZdlPv
.LBB2_13:                               @ %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit24
	ldr	r0, [sp, #36]
	mov	r4, #1
	cmp	r0, r6
	beq	.LBB2_15
@ BB#14:
	bl	_ZdlPv
.LBB2_15:                               @ %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit25
	mov	r0, r4
	sub	sp, r11, #16
	pop	{r4, r5, r6, r10, r11, pc}
.LBB2_16:
	movw	r0, :lower16:stderr
	mov	r1, #34
	movt	r0, :upper16:stderr
	ldr	r3, [r0]
	movw	r0, :lower16:.L.str
	movt	r0, :upper16:.L.str
	b	.LBB2_18
.LBB2_17:
	movw	r0, :lower16:stderr
	mov	r1, #144
	movt	r0, :upper16:stderr
	ldr	r3, [r0]
	movw	r0, :lower16:.L.str.2
	movt	r0, :upper16:.L.str.2
.LBB2_18:                               @ %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit25
	mov	r2, #1
	bl	fwrite
	b	.LBB2_15
.LBB2_19:
.Ltmp2:
	mov	lr, pc
	b	_Unwind_Resume
.LBB2_20:
.Ltmp5:
	mov	r4, r0
	ldr	r0, [sp, #8]
	cmp	r0, r5
	beq	.LBB2_22
@ BB#21:
	bl	_ZdlPv
.LBB2_22:                               @ %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit26
	ldr	r0, [sp, #36]
	cmp	r0, r6
	beq	.LBB2_24
@ BB#23:
	bl	_ZdlPv
.LBB2_24:                               @ %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
	mov	r0, r4
	mov	lr, pc
	b	_Unwind_Resume
.Lfunc_end2:
	.size	setup, .Lfunc_end2-setup
	.globl	__gxx_personality_v0
	.personality __gxx_personality_v0
	.handlerdata
	.p2align	2
GCC_except_table2:
.Lexception0:
	.byte	255                     @ @LPStart Encoding = omit
	.byte	0                       @ @TType Encoding = absptr
	.asciz	"\303\200"              @ @TType base offset
	.byte	3                       @ Call site Encoding = udata4
	.byte	65                      @ Call site table length
	.long	.Lfunc_begin0-.Lfunc_begin0 @ >> Call Site 1 <<
	.long	.Ltmp0-.Lfunc_begin0    @   Call between .Lfunc_begin0 and .Ltmp0
	.long	0                       @     has no landing pad
	.byte	0                       @   On action: cleanup
	.long	.Ltmp0-.Lfunc_begin0    @ >> Call Site 2 <<
	.long	.Ltmp1-.Ltmp0           @   Call between .Ltmp0 and .Ltmp1
	.long	.Ltmp2-.Lfunc_begin0    @     jumps to .Ltmp2
	.byte	0                       @   On action: cleanup
	.long	.Ltmp1-.Lfunc_begin0    @ >> Call Site 3 <<
	.long	.Ltmp3-.Ltmp1           @   Call between .Ltmp1 and .Ltmp3
	.long	0                       @     has no landing pad
	.byte	0                       @   On action: cleanup
	.long	.Ltmp3-.Lfunc_begin0    @ >> Call Site 4 <<
	.long	.Ltmp4-.Ltmp3           @   Call between .Ltmp3 and .Ltmp4
	.long	.Ltmp5-.Lfunc_begin0    @     jumps to .Ltmp5
	.byte	0                       @   On action: cleanup
	.long	.Ltmp4-.Lfunc_begin0    @ >> Call Site 5 <<
	.long	.Lfunc_end2-.Ltmp4      @   Call between .Ltmp4 and .Lfunc_end2
	.long	0                       @     has no landing pad
	.byte	0                       @   On action: cleanup
	.p2align	2
	.fnend

	.globl	render
	.p2align	2
	.type	render,%function
render:                                 @ @render
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
	push	{r4, r5, r6, r7, r8, r9, r10, r11, lr}
	.setfp	r11, sp, #28
	add	r11, sp, #28
	.pad	#4
	sub	sp, sp, #4
	.vsave	{d8}
	vpush	{d8}
	mov	r4, r0
	ldr	r0, [r4, #20]
	cmp	r0, #0
	beq	.LBB3_7
@ BB#1:                                 @ %.lr.ph
	vmov.f32	d8, #-5.000000e-01
	movw	r6, :lower16:.L_MergedGlobals.2
	movw	r9, :lower16:sigMag1
	movw	r10, :lower16:sigMag2
	movw	r7, :lower16:.L_MergedGlobals
	mov	r5, #0
	movt	r6, :upper16:.L_MergedGlobals.2
	movt	r9, :upper16:sigMag1
	movt	r10, :upper16:sigMag2
	movt	r7, :upper16:.L_MergedGlobals
	mov	r8, #0
.LBB3_2:                                @ =>This Inner Loop Header: Depth=1
	cmp	r8, #0
	bne	.LBB3_4
@ BB#3:                                 @   in Loop: Header=BB3_2 Depth=1
	ldr	r2, [r4, #8]
	movw	r3, :lower16:sigString1
	ldr	r1, [r6, #4]
	movt	r3, :upper16:sigString1
	vldr	s0, [r2]
	add	r3, r3, r1, lsl #2
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	movw	r3, :lower16:sigString2
	vldr	s0, [r2]
	movt	r3, :upper16:sigString2
	add	r3, r3, r1, lsl #2
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	movw	r3, :lower16:sigString3
	vldr	s0, [r2]
	movt	r3, :upper16:sigString3
	add	r3, r3, r1, lsl #2
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	movw	r3, :lower16:sigString4
	vldr	s0, [r2, #4]
	movt	r3, :upper16:sigString4
	add	r3, r3, r1, lsl #2
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	movw	r3, :lower16:sigString5
	vldr	s0, [r2, #4]
	movt	r3, :upper16:sigString5
	add	r3, r3, r1, lsl #2
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	add	r3, r9, r1, lsl #2
	vldr	s0, [r2, #8]
	vadd.f32	d0, d0, d8
	vstr	s0, [r3]
	vldr	s0, [r2, #12]
	add	r2, r10, r1, lsl #2
	add	r1, r1, #1
	vadd.f32	d0, d0, d8
	cmp	r5, r1, lsr #9
	movwne	r1, #0
	str	r1, [r6, #4]
	vstr	s0, [r2]
.LBB3_4:                                @   in Loop: Header=BB3_2 Depth=1
	ldr	r1, [r6]
	vldr	s0, [r4, #32]
	vldr	s2, [r7, #12]
	vmul.f32	d0, d0, d1
	vmov	s2, r1
	vcvt.f32.u32	d1, d1
	vcmpe.f32	s2, s0
	vmrs	APSR_nzcv, fpscr
	blt	.LBB3_6
@ BB#5:                                 @   in Loop: Header=BB3_2 Depth=1
	str	r5, [r6]
	bl	_Z9updateGuiv
	ldr	r0, [r4, #20]
	ldr	r1, [r6]
.LBB3_6:                                @   in Loop: Header=BB3_2 Depth=1
	add	r8, r8, #1
	add	r1, r1, #1
	str	r1, [r6]
	cmp	r8, r0
	blo	.LBB3_2
.LBB3_7:                                @ %._crit_edge
	vpop	{d8}
	add	sp, sp, #4
	pop	{r4, r5, r6, r7, r8, r9, r10, r11, pc}
.Lfunc_end3:
	.size	render, .Lfunc_end3-render
	.fnend

	.globl	cleanup
	.p2align	2
	.type	cleanup,%function
cleanup:                                @ @cleanup
	.fnstart
@ BB#0:
	bx	lr
.Lfunc_end4:
	.size	cleanup, .Lfunc_end4-cleanup
	.fnend

	.section	.text.startup,"ax",%progbits
	.p2align	2
	.type	_GLOBAL__sub_I_render.ii,%function
_GLOBAL__sub_I_render.ii:               @ @_GLOBAL__sub_I_render.ii
	.fnstart
@ BB#0:
	.save	{r4, r5, r11, lr}
	push	{r4, r5, r11, lr}
	.setfp	r11, sp, #8
	add	r11, sp, #8
	movw	r4, :lower16:touchSensor
	movt	r4, :upper16:touchSensor
	mov	r0, r4
	bl	_ZN5TrillC1Ev
	movw	r5, :lower16:__dso_handle
	movw	r0, :lower16:_ZN5TrillD1Ev
	movt	r5, :upper16:__dso_handle
	movt	r0, :upper16:_ZN5TrillD1Ev
	mov	r1, r4
	mov	r2, r5
	bl	__cxa_atexit
	movw	r4, :lower16:gui
	movt	r4, :upper16:gui
	mov	r0, r4
	bl	_ZN3GuiC1Ev
	movw	r0, :lower16:_ZN3GuiD1Ev
	mov	r1, r4
	movt	r0, :upper16:_ZN3GuiD1Ev
	mov	r2, r5
	pop	{r4, r5, r11, lr}
	b	__cxa_atexit
.Lfunc_end5:
	.size	_GLOBAL__sub_I_render.ii, .Lfunc_end5-_GLOBAL__sub_I_render.ii
	.fnend

	.type	touchSensor,%object     @ @touchSensor
	.bss
	.globl	touchSensor
	.p2align	2
touchSensor:
	.zero	204
	.size	touchSensor, 204

	.type	gui,%object             @ @gui
	.globl	gui
	.p2align	2
gui:
	.zero	136
	.size	gui, 136

	.type	sigString1,%object      @ @sigString1
	.globl	sigString1
	.p2align	2
sigString1:
	.zero	2048
	.size	sigString1, 2048

	.type	sigString2,%object      @ @sigString2
	.globl	sigString2
	.p2align	2
sigString2:
	.zero	2048
	.size	sigString2, 2048

	.type	sigString3,%object      @ @sigString3
	.globl	sigString3
	.p2align	2
sigString3:
	.zero	2048
	.size	sigString3, 2048

	.type	sigString4,%object      @ @sigString4
	.globl	sigString4
	.p2align	2
sigString4:
	.zero	2048
	.size	sigString4, 2048

	.type	sigString5,%object      @ @sigString5
	.globl	sigString5
	.p2align	2
sigString5:
	.zero	2048
	.size	sigString5, 2048

	.type	sigMag1,%object         @ @sigMag1
	.globl	sigMag1
	.p2align	2
sigMag1:
	.zero	2048
	.size	sigMag1, 2048

	.type	sigMag2,%object         @ @sigMag2
	.globl	sigMag2
	.p2align	2
sigMag2:
	.zero	2048
	.size	sigMag2, 2048

	.type	gFrequency,%object      @ @gFrequency
	.data
	.globl	gFrequency
	.p2align	2
gFrequency:
	.long	1036831949              @ float 0.100000001
	.size	gFrequency, 4

	.type	.L.str,%object          @ @.str
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str:
	.asciz	"Unable to initialise touch sensor\n"
	.size	.L.str, 35

	.type	.L.str.2,%object        @ @.str.2
.L.str.2:
	.asciz	"This example is supposed to work only with a One-Dimensional Trill Sensor. \n You may have to adapt it to make it work with other Trill devices.\n"
	.size	.L.str.2, 145

	.type	.L.str.3,%object        @ @.str.3
.L.str.3:
	.asciz	"I2C-read"
	.size	.L.str.3, 9

	.type	.L.str.4,%object        @ @.str.4
.L.str.4:
	.asciz	"gui"
	.size	.L.str.4, 4

	.type	.L.str.5,%object        @ @.str.5
.L.str.5:
	.asciz	"Device type: %d\n"
	.size	.L.str.5, 17

	.type	.L.str.6,%object        @ @.str.6
.L.str.6:
	.asciz	"Firmware version: %d\n"
	.size	.L.str.6, 22

	.section	.init_array,"aw",%init_array
	.p2align	2
	.long	_GLOBAL__sub_I_render.ii(target1)
	.type	.L_MergedGlobals,%object @ @_MergedGlobals
	.data
	.p2align	4
.L_MergedGlobals:
	.long	0                       @ 0x0
	.long	1000                    @ 0x3e8
	.long	30                      @ 0x1e
	.long	0                       @ float 0
	.long	0                       @ float 0
	.long	0                       @ float 0
	.long	100                     @ 0x64
	.long	6000                    @ 0x1770
	.zero	20
	.zero	20
	.long	1                       @ 0x1
	.long	2                       @ 0x2
	.long	4                       @ 0x4
	.long	8                       @ 0x8
	.long	16                      @ 0x10
	.long	32                      @ 0x20
	.long	0                       @ 0x0
	.long	10                      @ 0xa
	.long	20                      @ 0x14
	.long	30                      @ 0x1e
	.long	40                      @ 0x28
	.long	50                      @ 0x32
	.long	60                      @ 0x3c
	.size	.L_MergedGlobals, 124

	.type	.L_MergedGlobals.2,%object @ @_MergedGlobals.2
	.local	.L_MergedGlobals.2
	.comm	.L_MergedGlobals.2,8,4

	.globl	gNumActiveTouches
gNumActiveTouches = .L_MergedGlobals
	.size	gNumActiveTouches, 4
	.globl	gTaskSleepTime
gTaskSleepTime = .L_MergedGlobals+4
	.size	gTaskSleepTime, 4
	.globl	gFrameRate
gFrameRate = .L_MergedGlobals+8
	.size	gFrameRate, 4
	.globl	gTimePeriod
gTimePeriod = .L_MergedGlobals+12
	.size	gTimePeriod, 4
	.globl	gPhase
gPhase = .L_MergedGlobals+16
	.size	gPhase, 4
	.globl	gInverseSampleRate
gInverseSampleRate = .L_MergedGlobals+20
	.size	gInverseSampleRate, 4
	.globl	gTouchSizeRange
gTouchSizeRange = .L_MergedGlobals+24
	.size	gTouchSizeRange, 8
	.globl	gTouchLocation
gTouchLocation = .L_MergedGlobals+32
	.size	gTouchLocation, 20
	.globl	gTouchSize
gTouchSize = .L_MergedGlobals+52
	.size	gTouchSize, 20
	.globl	gPrescalerOpts
gPrescalerOpts = .L_MergedGlobals+72
	.size	gPrescalerOpts, 24
	.globl	gThresholdOpts
gThresholdOpts = .L_MergedGlobals+96
	.size	gThresholdOpts, 28
_ZZ6renderE5count = .L_MergedGlobals.2
	.size	_ZZ6renderE5count, 4
_ZZ6renderE1c = .L_MergedGlobals.2+4
	.size	_ZZ6renderE1c, 4
	.ident	"clang version 3.9.1-9 (tags/RELEASE_391/rc2)"
	.section	".note.GNU-stack","",%progbits
	.eabi_attribute	30, 2	@ Tag_ABI_optimization_goals
