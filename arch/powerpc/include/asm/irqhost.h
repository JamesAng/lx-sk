#ifndef _ASM_POWERPC_IRQHOST_H
#define _ASM_POWERPC_IRQHOST_H

#include <linux/list.h>
#include <linux/radix-tree.h>
#include <linux/irq.h>
#include <linux/of.h>

struct irq_host {
	struct list_head	link;

	/* type of reverse mapping technique */
	unsigned int		revmap_type;
	union {
		struct {
			unsigned int size;
			unsigned int *revmap;
		} linear;
		struct radix_tree_root tree;
	} revmap_data;
	struct irq_host_ops	*ops;
	void			*host_data;
	irq_hw_number_t		inval_irq;

	/* Optional device node pointer */
	struct device_node	*of_node;
};

#endif /* _ASM_POWERPC_IRQHOST_H */
