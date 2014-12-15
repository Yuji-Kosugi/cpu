#include "ia-32z.s"

	zLIL	1, cx
	zST	cx, 100, ax
	zLIL	9, dx
	zPUSH	cx
	zJALR	dx
	zLIL	3, si
	zCMP	bp, si
	zBcc	E, label	
	zHLT
	zLD	100, ax, bx
	zLIL	2, bp
	zADD	bx, bp
	zRET
label:	zPOP	di
	zHLT
