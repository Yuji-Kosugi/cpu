.macro check_rg1 rg1
	.ifc \rg1, sp
	register sp cannot be used for rg1 of ld/st insn
	.endif
.endm

.macro check_sim8 sim8
	.if (\sim8 < -128) || (127 < \sim8)
	immediate \sim8 out of range
	.endif
	.align 4
.endm


# -----------------------------------------------
# LD & ST

.macro zLD	sim8, rg1, rg2
	check_rg1 \rg1
	check_sim8 \sim8
	movl	\sim8(%e\rg1), %e\rg2
	nop
	.if (\sim8 == 0)
	nop
	.endif
.endm

.macro zST	rg2, sim8, rg1
	check_rg1 \rg1
	check_sim8 \sim8
	movl	%e\rg2, \sim8(%e\rg1)
	nop
	.if (\sim8 == 0)
	nop
	.endif
.endm

.macro zLIL	im16, rg2
	.align 4
	movw	$\im16, %\rg2
.endm

# -----------------------------------------------
# Binary Operations  -- register-register

.macro zMOV	rg1, rg2
	.align 4
	movl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zADD	rg1, rg2
	.align 4
	addl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zSUB	rg1, rg2
	.align 4
	subl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zCMP	rg1, rg2
	.align 4
	cmpl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zAND	rg1, rg2
	.align 4
	andl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zOR	rg1, rg2
	.align 4
	orl	%e\rg1, %e\rg2
	nop
	nop
.endm

.macro zXOR	rg1, rg2
	.align 4
	xorl	%e\rg1, %e\rg2
	nop
	nop
.endm

# -----------------------------------------------
# Binary Operations  -- register-immediate

.macro zADDI	sim8, rg2
	check_sim8 \sim8
	addl	$\sim8, %e\rg2
	nop
.endm

.macro zSUBI	sim8, rg2
	check_sim8 \sim8
	subl	$\sim8, %e\rg2
	nop
.endm

.macro zCMPI	sim8, rg2
	check_sim8 \sim8
	cmpl	$\sim8, %e\rg2
	nop
.endm

.macro zANDI	sim8, rg2
	check_sim8 \sim8
	andl	$\sim8, %e\rg2
	nop
.endm

.macro zORI	sim8, rg2
	check_sim8 \sim8
	orl	$\sim8, %e\rg2
	nop
.endm

.macro zXORI	sim8, rg2
	check_sim8 \sim8
	xorl	$\sim8, %e\rg2
	nop
.endm

# -----------------------------------------------
# Unary Operation -- NEG & NOT

.macro zNEG	rg2
	.align 4
	negl	%e\rg2
	nop
	nop
.endm

.macro zNOT	rg2
	.align 4
	notl	%e\rg2
	nop
	nop
.endm

# -----------------------------------------------
# Shift

.macro zSLL	sim8, rg2
	check_sim8 \sim8
	shll	$\sim8, %e\rg2
	nop
	.if (\sim8 == 1)
	nop
	.endif
.endm

.macro zSLA	sim8, rg2
	check_sim8 \sim8
	sall	$\sim8, %e\rg2
	nop
	.if (\sim8 == 1)
	nop
	.endif
.endm

.macro zSRL	sim8, rg2
	check_sim8 \sim8
	shrl	$\sim8, %e\rg2
	nop
	.if (\sim8 == 1)
	nop
	.endif
.endm

.macro zSRA	sim8, rg2
	check_sim8 \sim8
	sarl	$\sim8, %e\rg2
	nop
	.if (\sim8 == 1)
	nop
	.endif
.endm

# -----------------------------------------------
# Branch & Jump

.macro zB	label
	nop
	jmp	\label
	nop
.endm

.macro zBcc	cc, label
	nop
	j\cc	\label
	nop
.endm

.macro zJR	rg2
	.align 4
	jmp	*%e\rg2
	nop
	nop
.endm

# -----------------------------------------------
# Push & Pop

.macro	zPUSH	rg2
	.align 4
	nop
	pushl	%e\rg2
	nop
	nop
.endm

.macro	zPOP	rg2
	.align 4
	nop
	popl	%e\rg2
	nop
	nop
.endm

# -----------------------------------------------
# Call & Return

.macro	zCALL	rg2
	.align 4
	call	*%e\rg2
	nop
	nop
.endm

.macro	zJALR	rg2
	.align 4
	call	*%e\rg2
	nop
	nop
.endm

.macro	zRET
	.align 4
	ret
	nop
	nop
	nop
.endm

# -----------------------------------------------
# Halt & NOP

.macro	zHLT
	.align 4
	hlt
	nop
	nop
	nop
.endm

.macro	zNOP
	.align 4
	nop
	nop
	nop
	nop
.endm

# -----------------------------------------------
# Pseudo Instructions

.macro zCLR	rg2
	zXOR	\rg2, \rg2
.endm

.macro zSET16	imm, rg2
	zCLR	\rg2
	zLIL	"(\imm & 0xFFFF)", \rg2
.endm

.macro zSET32	imm, rg2
	zLIL	"(\imm >> 16)", \rg2
	zSLL	16, \rg2
	zLIL	"(\imm & 0xFFFF)", \rg2
.endm

.macro zSETLABEL	label, start, rg2
	zSET32	"(\label - \start)", \rg2
.endm

# -----------------------------------------------
# Pseudo Instructions for ones w/o zPUSH/zPOP nor zCALL/zRET

#.macro zPUSH2	rg2
#	zADDI	-4, sp
#	zST	\rg2, 0, sp
#.endm

#.macro zPOP2	rg2
#	zLD	0, sp, \rg2
#	zADDI	4, sp
#.endm

#.macro zRET2	rg2
#	zPOP2	\rg2
#	zJR	\rg2
#.endm

.macro zLEAVE	
	zMOV	bp, sp
	zPOP	bp
.endm
