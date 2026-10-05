	.syntax unified
	.arch armv7-a
	.thumb
	.fpu softvfp
	.text

	.global __adddf3
	.type __adddf3, %function
	.thumb_func
__adddf3:
	b lw_ref___adddf3

	.global __addsf3
	.type __addsf3, %function
	.thumb_func
__addsf3:
	b lw_ref___addsf3

	.global __aeabi_cdcmpeq
	.type __aeabi_cdcmpeq, %function
	.thumb_func
__aeabi_cdcmpeq:
	b lw_ref___aeabi_cdcmpeq

	.global __aeabi_cdcmple
	.type __aeabi_cdcmple, %function
	.thumb_func
__aeabi_cdcmple:
	b lw_ref___aeabi_cdcmple

	.global __aeabi_cdrcmple
	.type __aeabi_cdrcmple, %function
	.thumb_func
__aeabi_cdrcmple:
	b lw_ref___aeabi_cdrcmple

	.global __aeabi_cfcmpeq
	.type __aeabi_cfcmpeq, %function
	.thumb_func
__aeabi_cfcmpeq:
	b lw_ref___aeabi_cfcmpeq

	.global __aeabi_cfcmple
	.type __aeabi_cfcmple, %function
	.thumb_func
__aeabi_cfcmple:
	b lw_ref___aeabi_cfcmple

	.global __aeabi_cfrcmple
	.type __aeabi_cfrcmple, %function
	.thumb_func
__aeabi_cfrcmple:
	b lw_ref___aeabi_cfrcmple

	.global __aeabi_d2f
	.type __aeabi_d2f, %function
	.thumb_func
__aeabi_d2f:
	b lw_ref___aeabi_d2f

	.global __aeabi_d2iz
	.type __aeabi_d2iz, %function
	.thumb_func
__aeabi_d2iz:
	b lw_ref___aeabi_d2iz

	.global __aeabi_d2uiz
	.type __aeabi_d2uiz, %function
	.thumb_func
__aeabi_d2uiz:
	b lw_ref___aeabi_d2uiz

	.global __aeabi_dadd
	.type __aeabi_dadd, %function
	.thumb_func
__aeabi_dadd:
	b lw_ref___aeabi_dadd

	.global __aeabi_dcmpeq
	.type __aeabi_dcmpeq, %function
	.thumb_func
__aeabi_dcmpeq:
	b lw_ref___aeabi_dcmpeq

	.global __aeabi_dcmpge
	.type __aeabi_dcmpge, %function
	.thumb_func
__aeabi_dcmpge:
	b lw_ref___aeabi_dcmpge

	.global __aeabi_dcmpgt
	.type __aeabi_dcmpgt, %function
	.thumb_func
__aeabi_dcmpgt:
	b lw_ref___aeabi_dcmpgt

	.global __aeabi_dcmple
	.type __aeabi_dcmple, %function
	.thumb_func
__aeabi_dcmple:
	b lw_ref___aeabi_dcmple

	.global __aeabi_dcmplt
	.type __aeabi_dcmplt, %function
	.thumb_func
__aeabi_dcmplt:
	b lw_ref___aeabi_dcmplt

	.global __aeabi_dcmpun
	.type __aeabi_dcmpun, %function
	.thumb_func
__aeabi_dcmpun:
	b lw_ref___aeabi_dcmpun

	.global __aeabi_ddiv
	.type __aeabi_ddiv, %function
	.thumb_func
__aeabi_ddiv:
	b lw_ref___aeabi_ddiv

	.global __aeabi_dmul
	.type __aeabi_dmul, %function
	.thumb_func
__aeabi_dmul:
	b lw_ref___aeabi_dmul

	.global __aeabi_drsub
	.type __aeabi_drsub, %function
	.thumb_func
__aeabi_drsub:
	b lw_ref___aeabi_drsub

	.global __aeabi_dsub
	.type __aeabi_dsub, %function
	.thumb_func
__aeabi_dsub:
	b lw_ref___aeabi_dsub

	.global __aeabi_f2d
	.type __aeabi_f2d, %function
	.thumb_func
__aeabi_f2d:
	b lw_ref___aeabi_f2d

	.global __aeabi_f2iz
	.type __aeabi_f2iz, %function
	.thumb_func
__aeabi_f2iz:
	b lw_ref___aeabi_f2iz

	.global __aeabi_f2uiz
	.type __aeabi_f2uiz, %function
	.thumb_func
__aeabi_f2uiz:
	b lw_ref___aeabi_f2uiz

	.global __aeabi_fadd
	.type __aeabi_fadd, %function
	.thumb_func
__aeabi_fadd:
	b lw_ref___aeabi_fadd

	.global __aeabi_fcmpeq
	.type __aeabi_fcmpeq, %function
	.thumb_func
__aeabi_fcmpeq:
	b lw_ref___aeabi_fcmpeq

	.global __aeabi_fcmpge
	.type __aeabi_fcmpge, %function
	.thumb_func
__aeabi_fcmpge:
	b lw_ref___aeabi_fcmpge

	.global __aeabi_fcmpgt
	.type __aeabi_fcmpgt, %function
	.thumb_func
__aeabi_fcmpgt:
	b lw_ref___aeabi_fcmpgt

	.global __aeabi_fcmple
	.type __aeabi_fcmple, %function
	.thumb_func
__aeabi_fcmple:
	b lw_ref___aeabi_fcmple

	.global __aeabi_fcmplt
	.type __aeabi_fcmplt, %function
	.thumb_func
__aeabi_fcmplt:
	b lw_ref___aeabi_fcmplt

	.global __aeabi_fcmpun
	.type __aeabi_fcmpun, %function
	.thumb_func
__aeabi_fcmpun:
	b lw_ref___aeabi_fcmpun

	.global __aeabi_fdiv
	.type __aeabi_fdiv, %function
	.thumb_func
__aeabi_fdiv:
	b lw_ref___aeabi_fdiv

	.global __aeabi_fmul
	.type __aeabi_fmul, %function
	.thumb_func
__aeabi_fmul:
	b lw_ref___aeabi_fmul

	.global __aeabi_frsub
	.type __aeabi_frsub, %function
	.thumb_func
__aeabi_frsub:
	b lw_ref___aeabi_frsub

	.global __aeabi_fsub
	.type __aeabi_fsub, %function
	.thumb_func
__aeabi_fsub:
	b lw_ref___aeabi_fsub

	.global __aeabi_i2d
	.type __aeabi_i2d, %function
	.thumb_func
__aeabi_i2d:
	b lw_ref___aeabi_i2d

	.global __aeabi_i2f
	.type __aeabi_i2f, %function
	.thumb_func
__aeabi_i2f:
	b lw_ref___aeabi_i2f

	.global __aeabi_l2d
	.type __aeabi_l2d, %function
	.thumb_func
__aeabi_l2d:
	b lw_ref___aeabi_l2d

	.global __aeabi_l2f
	.type __aeabi_l2f, %function
	.thumb_func
__aeabi_l2f:
	b lw_ref___aeabi_l2f

	.global __aeabi_lasr
	.type __aeabi_lasr, %function
	.thumb_func
__aeabi_lasr:
	b lw_ref___aeabi_lasr

	.global __aeabi_llsl
	.type __aeabi_llsl, %function
	.thumb_func
__aeabi_llsl:
	b lw_ref___aeabi_llsl

	.global __aeabi_llsr
	.type __aeabi_llsr, %function
	.thumb_func
__aeabi_llsr:
	b lw_ref___aeabi_llsr

	.global __aeabi_lmul
	.type __aeabi_lmul, %function
	.thumb_func
__aeabi_lmul:
	b lw_ref___aeabi_lmul

	.global __aeabi_ui2d
	.type __aeabi_ui2d, %function
	.thumb_func
__aeabi_ui2d:
	b lw_ref___aeabi_ui2d

	.global __aeabi_ui2f
	.type __aeabi_ui2f, %function
	.thumb_func
__aeabi_ui2f:
	b lw_ref___aeabi_ui2f

	.global __aeabi_ul2d
	.type __aeabi_ul2d, %function
	.thumb_func
__aeabi_ul2d:
	b lw_ref___aeabi_ul2d

	.global __aeabi_ul2f
	.type __aeabi_ul2f, %function
	.thumb_func
__aeabi_ul2f:
	b lw_ref___aeabi_ul2f

	.global __ashldi3
	.type __ashldi3, %function
	.thumb_func
__ashldi3:
	b lw_ref___ashldi3

	.global __ashrdi3
	.type __ashrdi3, %function
	.thumb_func
__ashrdi3:
	b lw_ref___ashrdi3

	.global __cmpdf2
	.type __cmpdf2, %function
	.thumb_func
__cmpdf2:
	b lw_ref___cmpdf2

	.global __cmpsf2
	.type __cmpsf2, %function
	.thumb_func
__cmpsf2:
	b lw_ref___cmpsf2

	.global __divdf3
	.type __divdf3, %function
	.thumb_func
__divdf3:
	b lw_ref___divdf3

	.global __divsf3
	.type __divsf3, %function
	.thumb_func
__divsf3:
	b lw_ref___divsf3

	.global __eqdf2
	.type __eqdf2, %function
	.thumb_func
__eqdf2:
	b lw_ref___eqdf2

	.global __eqsf2
	.type __eqsf2, %function
	.thumb_func
__eqsf2:
	b lw_ref___eqsf2

	.global __extendsfdf2
	.type __extendsfdf2, %function
	.thumb_func
__extendsfdf2:
	b lw_ref___extendsfdf2

	.global __fixdfsi
	.type __fixdfsi, %function
	.thumb_func
__fixdfsi:
	b lw_ref___fixdfsi

	.global __fixsfsi
	.type __fixsfsi, %function
	.thumb_func
__fixsfsi:
	b lw_ref___fixsfsi

	.global __fixunsdfsi
	.type __fixunsdfsi, %function
	.thumb_func
__fixunsdfsi:
	b lw_ref___fixunsdfsi

	.global __fixunssfsi
	.type __fixunssfsi, %function
	.thumb_func
__fixunssfsi:
	b lw_ref___fixunssfsi

	.global __floatdidf
	.type __floatdidf, %function
	.thumb_func
__floatdidf:
	b lw_ref___floatdidf

	.global __floatdisf
	.type __floatdisf, %function
	.thumb_func
__floatdisf:
	b lw_ref___floatdisf

	.global __floatsidf
	.type __floatsidf, %function
	.thumb_func
__floatsidf:
	b lw_ref___floatsidf

	.global __floatsisf
	.type __floatsisf, %function
	.thumb_func
__floatsisf:
	b lw_ref___floatsisf

	.global __floatundidf
	.type __floatundidf, %function
	.thumb_func
__floatundidf:
	b lw_ref___floatundidf

	.global __floatundisf
	.type __floatundisf, %function
	.thumb_func
__floatundisf:
	b lw_ref___floatundisf

	.global __floatunsidf
	.type __floatunsidf, %function
	.thumb_func
__floatunsidf:
	b lw_ref___floatunsidf

	.global __floatunsisf
	.type __floatunsisf, %function
	.thumb_func
__floatunsisf:
	b lw_ref___floatunsisf

	.global __gedf2
	.type __gedf2, %function
	.thumb_func
__gedf2:
	b lw_ref___gedf2

	.global __gesf2
	.type __gesf2, %function
	.thumb_func
__gesf2:
	b lw_ref___gesf2

	.global __gtdf2
	.type __gtdf2, %function
	.thumb_func
__gtdf2:
	b lw_ref___gtdf2

	.global __gtsf2
	.type __gtsf2, %function
	.thumb_func
__gtsf2:
	b lw_ref___gtsf2

	.global __ledf2
	.type __ledf2, %function
	.thumb_func
__ledf2:
	b lw_ref___ledf2

	.global __lesf2
	.type __lesf2, %function
	.thumb_func
__lesf2:
	b lw_ref___lesf2

	.global __lshrdi3
	.type __lshrdi3, %function
	.thumb_func
__lshrdi3:
	b lw_ref___lshrdi3

	.global __ltdf2
	.type __ltdf2, %function
	.thumb_func
__ltdf2:
	b lw_ref___ltdf2

	.global __ltsf2
	.type __ltsf2, %function
	.thumb_func
__ltsf2:
	b lw_ref___ltsf2

	.global __muldf3
	.type __muldf3, %function
	.thumb_func
__muldf3:
	b lw_ref___muldf3

	.global __muldi3
	.type __muldi3, %function
	.thumb_func
__muldi3:
	b lw_ref___muldi3

	.global __mulsf3
	.type __mulsf3, %function
	.thumb_func
__mulsf3:
	b lw_ref___mulsf3

	.global __nedf2
	.type __nedf2, %function
	.thumb_func
__nedf2:
	b lw_ref___nedf2

	.global __nesf2
	.type __nesf2, %function
	.thumb_func
__nesf2:
	b lw_ref___nesf2

	.global __subdf3
	.type __subdf3, %function
	.thumb_func
__subdf3:
	b lw_ref___subdf3

	.global __subsf3
	.type __subsf3, %function
	.thumb_func
__subsf3:
	b lw_ref___subsf3

	.global __truncdfsf2
	.type __truncdfsf2, %function
	.thumb_func
__truncdfsf2:
	b lw_ref___truncdfsf2

	.global __unorddf2
	.type __unorddf2, %function
	.thumb_func
__unorddf2:
	b lw_ref___unorddf2

	.global __unordsf2
	.type __unordsf2, %function
	.thumb_func
__unordsf2:
	b lw_ref___unordsf2

