/* arch/arm/mach-omap1/include/mach/debug-macro.S
 *
 * Debugging macro include header
 *
 *  Copyright (C) 1994-1999 Russell King
 *  Moved from linux/arch/arm/kernel/debug.S by Ben Dooks
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
*/

#include <linux/serial_reg.h>

#include <asm/memory.h>
#include <asm/mach-types.h>

#include <plat/io.h>
#include <plat/serial.h>

#define omap_uart_v2p(x)	((x) - PAGE_OFFSET + PLAT_PHYS_OFFSET)

		/*
		 * Intialize the debug serial port based on machine ID
		 */
		.macro	inituart, id, a, v
		mrc	p15, 0, \a, c1, c0
		tst	\a, #1			@ MMU enabled?
		ldreq	\a, =omap_uart_v2p(omap_uart_phys)
		ldrne	\a, =omap_uart_phys
		mov	\v, #(UART_LSR << OMAP_PORT_SHIFT)
		str	\v, [\a, #8]		@ save lsr, different for 7xx

		/* omap7xx/8xx based boards using uart1 with shift 0 */
		ldr	\v, =MACH_TYPE_HERALD
		cmp	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_PERSEUS2
		cmpne	\id, \v
		ldreq	\v, =OMAP1_UART1_BASE
		streq	\v, [\a, #0]		@ save port phys addr
		ldreq	\v, =(OMAP1_UART1_BASE - OMAP1_IO_OFFSET)
		streq	\v, [\a, #4]		@ save port virt addr
		moveq	\v, #(UART_LSR << OMAP7XX_PORT_SHIFT)
		streq	\v, [\a, #8]		@ save lsr, different for 7xx
		beq	999f

		/* omap15xx/16xx based boards using uart1 */
		ldr	\v, =MACH_TYPE_AMS_DELTA
		cmp	\id, \v
		ldrne	\v, =MACH_TYPE_NOKIA770
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_H2
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_H3
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_INNOVATOR
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_OSK
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_PALMTE
		cmpne	\id, \v
		ldrne	\v, =MACH_TYPE_OMAP_PALMZ71
		cmpne	\id, \v
		ldreq	\v, =OMAP1_UART1_BASE
		streq	\v, [\a, #0]		@ save port phys addr
		ldreq	\v, =(OMAP1_UART1_BASE - OMAP1_IO_OFFSET)
		streq	\v, [\a, #4]		@ save port virt addr
		beq	999f

		/* omap15xx/16xx based boards using uart2 */
		ldr	\v, =MACH_TYPE_OMAP_PALMTT
		cmp	\id, \v
		ldreq	\v, =OMAP1_UART2_BASE
		streq	\v, [\a, #0]		@ save port phys addr
		ldreq	\v, =(OMAP1_UART2_BASE - OMAP1_IO_OFFSET)
		streq	\v, [\a, #4]		@ save port virt addr
		beq	999f

		/* omap15xx/16xx based boards using uart3 */
		ldr	\v, =MACH_TYPE_SX1
		cmp	\id, \v
		ldreq	\v, =OMAP1_UART3_BASE
		streq	\v, [\a, #0]		@ save port phys addr
		ldreq	\v, =(OMAP1_UART3_BASE - OMAP1_IO_OFFSET)
		streq	\v, [\a, #4]		@ save port virt addr
		beq	999f

999:
		.endm

		/*
		 * Note that this code won't work if the bootloader passes
		 * a wrong machine ID number in r1. To debug, just hardcode
		 * the desired omap_uart_phys, omap_uart_virt and omap_uart_lsr
		 * temporarily into mach-omap[12]/serial.c and comment out
		 * the inituart macro above.
		 */
		.macro	addruart, rp, rv

		/* Use omap_uart_phys/virt if already configured */
		mrc	p15, 0, \rp, c1, c0
		tst	\rp, #1			@ MMU enabled?
		ldreq	\rp, =omap_uart_v2p(omap_uart_phys)	@ MMU disabled
		ldrne	\rp, =omap_uart_phys	@ MMU enabled
		add	\rv, \rp, #4		@ omap_uart_virt
		ldr	\rp, [\rp, #0]
		ldr	\rv, [\rv, #0]
		.endm

		.macro	senduart,rd,rx
		strb	\rd, [\rx]
		.endm

		.macro	busyuart,rd,rx
1001:		ldrb	\rd, [\rx, #(UART_LSR << OMAP_PORT_SHIFT)]
		and	\rd, \rd, #(UART_LSR_TEMT | UART_LSR_THRE)
		teq	\rd, #(UART_LSR_TEMT | UART_LSR_THRE)
		beq	1002f
		ldrb	\rd, [\rx, #(UART_LSR << OMAP7XX_PORT_SHIFT)]
		and	\rd, \rd, #(UART_LSR_TEMT | UART_LSR_THRE)
		teq	\rd, #(UART_LSR_TEMT | UART_LSR_THRE)
		bne	1001b
1002:
		.endm

		.macro	waituart,rd,rx
		.endm
