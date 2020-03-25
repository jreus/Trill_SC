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
	.file	"/root/Bela/projects/BanjoScopeInputs/build/render.bc"
	.globl	setup
	.p2align	2
	.type	setup,%function
setup:                                  @ @setup
	.fnstart
@ BB#0:
	.save	{r4, r10, r11, lr}
	push	{r4, r10, r11, lr}
	.setfp	r11, sp, #8
	add	r11, sp, #8
	mov	r4, r0
	movw	r0, :lower16:scope
	vldr	s0, [r4, #48]
	movt	r0, :upper16:scope
	mov	r1, #8
	bl	_ZN5Scope5setupEjf
	ldr	r1, [r4, #40]
	mov	r0, #1
	cmp	r1, #7
	pophi	{r4, r10, r11, pc}
	movw	r0, :lower16:stderr
	mov	r1, #62
	movt	r0, :upper16:stderr
	mov	r2, #1
	ldr	r3, [r0]
	movw	r0, :lower16:.L.str
	movt	r0, :upper16:.L.str
	bl	fwrite
	mov	r0, #0
	pop	{r4, r10, r11, pc}
.Lfunc_end0:
	.size	setup, .Lfunc_end0-setup
	.fnend

	.globl	render
	.p2align	2
	.type	render,%function
render:                                 @ @render
	.fnstart
@ BB#0:
	.save	{r4, r5, r6, r10, r11, lr}
	push	{r4, r5, r6, r10, r11, lr}
	.setfp	r11, sp, #16
	add	r11, sp, #16
	.vsave	{d8}
	vpush	{d8}
	.pad	#56
	sub	sp, sp, #56
	mov	r4, r0
	ldr	r0, [r4, #36]
	cmp	r0, #0
	beq	.LBB1_3
@ BB#1:                                 @ %.lr.ph
	vmov.f64	d8, #-5.000000e-01
	movw	r5, :lower16:scope
	mov	r6, #0
	movt	r5, :upper16:scope
.LBB1_2:                                @ =>This Inner Loop Header: Depth=1
	ldr	r1, [r4, #40]
	ldr	r0, [r4, #8]
	mul	r1, r1, r6
	add	r0, r0, r1, lsl #2
	vldr	s0, [r0]
	vldr	s2, [r0, #4]
	vcvt.f64.f32	d16, s0
	vadd.f64	d16, d16, d8
	vmov	r2, r3, d16
	vldr	s4, [r0, #8]
	vldr	s6, [r0, #12]
	vldr	s8, [r0, #16]
	vldr	s10, [r0, #20]
	vldr	s12, [r0, #24]
	vldr	s14, [r0, #28]
	mov	r0, r5
	vcvt.f64.f32	d18, s12
	vcvt.f64.f32	d17, s14
	vcvt.f64.f32	d19, s6
	vcvt.f64.f32	d20, s4
	vcvt.f64.f32	d21, s10
	vcvt.f64.f32	d22, s8
	vcvt.f64.f32	d23, s2
	vadd.f64	d16, d17, d8
	vadd.f64	d17, d18, d8
	vadd.f64	d18, d19, d8
	vadd.f64	d19, d20, d8
	vadd.f64	d20, d21, d8
	vadd.f64	d21, d22, d8
	vadd.f64	d22, d23, d8
	vstr	d22, [sp]
	vstr	d21, [sp, #8]
	vstr	d20, [sp, #16]
	vstr	d19, [sp, #24]
	vstr	d18, [sp, #32]
	vstr	d17, [sp, #40]
	vstr	d16, [sp, #48]
	bl	_ZN5Scope3logEdz
	add	r6, r6, #1
	ldr	r0, [r4, #36]
	cmp	r6, r0
	blo	.LBB1_2
.LBB1_3:                                @ %._crit_edge
	sub	sp, r11, #24
	vpop	{d8}
	pop	{r4, r5, r6, r10, r11, pc}
.Lfunc_end1:
	.size	render, .Lfunc_end1-render
	.fnend

	.globl	cleanup
	.p2align	2
	.type	cleanup,%function
cleanup:                                @ @cleanup
	.fnstart
@ BB#0:
	bx	lr
.Lfunc_end2:
	.size	cleanup, .Lfunc_end2-cleanup
	.fnend

	.section	.text.startup,"ax",%progbits
	.p2align	2
	.type	_GLOBAL__sub_I_render.ii,%function
_GLOBAL__sub_I_render.ii:               @ @_GLOBAL__sub_I_render.ii
	.fnstart
@ BB#0:
	.save	{r4, r10, r11, lr}
	push	{r4, r10, r11, lr}
	.setfp	r11, sp, #8
	add	r11, sp, #8
	movw	r4, :lower16:scope
	movt	r4, :upper16:scope
	mov	r0, r4
	bl	_ZN5ScopeC1Ev
	movw	r0, :lower16:_ZN5ScopeD1Ev
	movw	r2, :lower16:__dso_handle
	movt	r0, :upper16:_ZN5ScopeD1Ev
	movt	r2, :upper16:__dso_handle
	mov	r1, r4
	pop	{r4, r10, r11, lr}
	b	__cxa_atexit
.Lfunc_end3:
	.size	_GLOBAL__sub_I_render.ii, .Lfunc_end3-_GLOBAL__sub_I_render.ii
	.fnend

	.type	scope,%object           @ @scope
	.bss
	.globl	scope
	.p2align	2
scope:
	.zero	212
	.size	scope, 212

	.type	.L.str,%object          @ @.str
	.section	.rodata.str1.1,"aMS",%progbits,1
.L.str:
	.asciz	"Error: for this project you need at least eight analog inputs\n"
	.size	.L.str, 63

	.section	.init_array,"aw",%init_array
	.p2align	2
	.long	_GLOBAL__sub_I_render.ii(target1)

	.ident	"clang version 3.9.1-9 (tags/RELEASE_391/rc2)"
	.section	".note.GNU-stack","",%progbits
	.eabi_attribute	30, 2	@ Tag_ABI_optimization_goals
