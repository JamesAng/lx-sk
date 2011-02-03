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

#include <plat/serial.h>

#define omap_uart_v2p(x)	((x) - PAGE_OFFSET + PLAT_PHYS_OFFSET)

		.pushsection .data
omap_uart_phys:	.word	0x0
omap_uart_virt:	.word	0x0
		.popsection

		.macro	inituart, id, a, v
		.endm

		/*
		 * Note that this code won't work if the bootloader passes
		 * a wrong machine ID number in r1. To debug, just hardcode
		 * the desired UART phys and virt addresses temporarily into
		 * the omap_uart_phys and omap_uart_virt above.
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
