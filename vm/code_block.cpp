#include "master.hpp"

namespace factor
{

relocation_type factorvm::relocation_type_of(relocation_entry r)
{
	return (relocation_type)((r & 0xf0000000) >> 28);
}

relocation_type relocation_type_of(relocation_entry r)
{
	return vm->relocation_type_of(r);
}

relocation_class factorvm::relocation_class_of(relocation_entry r)
{
	return (relocation_class)((r & 0x0f000000) >> 24);
}

relocation_class relocation_class_of(relocation_entry r)
{
	return vm->relocation_class_of(r);
}

cell factorvm::relocation_offset_of(relocation_entry r)
{
	return  (r & 0x00ffffff);
}

cell relocation_offset_of(relocation_entry r)
{
	return vm->relocation_offset_of(r);
}

void factorvm::flush_icache_for(code_block *block)
{
	flush_icache((cell)block,block->size);
}

void flush_icache_for(code_block *block)
{
	return vm->flush_icache_for(block);
}

int factorvm::number_of_parameters(relocation_type type)
{
	switch(type)
	{
	case RT_PRIMITIVE:
	case RT_XT:
	case RT_XT_PIC:
	case RT_XT_PIC_TAIL:
	case RT_IMMEDIATE:
	case RT_HERE:
	case RT_UNTAGGED:
		return 1;
	case RT_DLSYM:
		return 2;
	case RT_THIS:
	case RT_STACK_CHAIN:
	case RT_MEGAMORPHIC_CACHE_HITS:
		return 0;
	default:
		critical_error("Bad rel type",type);
		return -1; /* Can't happen */
	}
}

int number_of_parameters(relocation_type type)
{
	return vm->number_of_parameters(type);
}

void *factorvm::object_xt(cell obj)
{
	switch(tagged<object>(obj).type())
	{
	case WORD_TYPE:
		return untag<word>(obj)->xt;
	case QUOTATION_TYPE:
		return untag<quotation>(obj)->xt;
	default:
		critical_error("Expected word or quotation",obj);
		return NULL;
	}
}

void *object_xt(cell obj)
{
	return vm->object_xt(obj);
}

void *factorvm::xt_pic(word *w, cell tagged_quot)
{
	if(tagged_quot == F || max_pic_size == 0)
		return w->xt;
	else
	{
		quotation *quot = untag<quotation>(tagged_quot);
		if(quot->code)
			return quot->xt;
		else
			return w->xt;
	}
}

void *xt_pic(word *w, cell tagged_quot)
{
	return vm->xt_pic(w,tagged_quot);
}

void *factorvm::word_xt_pic(word *w)
{
	return xt_pic(w,w->pic_def);
}

void *word_xt_pic(word *w)
{
	return vm->word_xt_pic(w);
}

void *factorvm::word_xt_pic_tail(word *w)
{
	return xt_pic(w,w->pic_tail_def);
}

void *word_xt_pic_tail(word *w)
{
	return vm->word_xt_pic_tail(w);
}

/* References to undefined symbols are patched up to call this function on
image load */
void factorvm::undefined_symbol()
{
	general_error(ERROR_UNDEFINED_SYMBOL,F,F,NULL);
}

void undefined_symbol()
{
	return vm->undefined_symbol();
}

/* Look up an external library symbol referenced by a compiled code block */
void *factorvm::get_rel_symbol(array *literals, cell index)
{
	cell symbol = array_nth(literals,index);
	cell library = array_nth(literals,index + 1);

	dll *d = (library == F ? NULL : untag<dll>(library));

	if(d != NULL && !d->dll)
		return (void *)factor::undefined_symbol;

	switch(tagged<object>(symbol).type())
	{
	case BYTE_ARRAY_TYPE:
		{
			symbol_char *name = alien_offset(symbol);
			void *sym = ffi_dlsym(d,name);

			if(sym)
				return sym;
			else
			{
				return (void *)factor::undefined_symbol;
			}
		}
	case ARRAY_TYPE:
		{
			cell i;
			array *names = untag<array>(symbol);
			for(i = 0; i < array_capacity(names); i++)
			{
				symbol_char *name = alien_offset(array_nth(names,i));
				void *sym = ffi_dlsym(d,name);

				if(sym)
					return sym;
			}
			return (void *)factor::undefined_symbol;
		}
	default:
		critical_error("Bad symbol specifier",symbol);
		return (void *)factor::undefined_symbol;
	}
}

void *get_rel_symbol(array *literals, cell index)
{
	return vm->get_rel_symbol(literals,index);
}

cell factorvm::compute_relocation(relocation_entry rel, cell index, code_block *compiled)
{
	array *literals = untag<array>(compiled->literals);
	cell offset = relocation_offset_of(rel) + (cell)compiled->xt();

#define ARG array_nth(literals,index)

	switch(relocation_type_of(rel))
	{
	case RT_PRIMITIVE:
		return (cell)primitives[untag_fixnum(ARG)];
	case RT_DLSYM:
		return (cell)get_rel_symbol(literals,index);
	case RT_IMMEDIATE:
		return ARG;
	case RT_XT:
		return (cell)object_xt(ARG);
	case RT_XT_PIC:
		return (cell)word_xt_pic(untag<word>(ARG));
	case RT_XT_PIC_TAIL:
		return (cell)word_xt_pic_tail(untag<word>(ARG));
	case RT_HERE:
	{
		fixnum arg = untag_fixnum(ARG);
		return (arg >= 0 ? offset + arg : (cell)(compiled +1) - arg);
	}
	case RT_THIS:
		return (cell)(compiled + 1);
	case RT_STACK_CHAIN:
		return (cell)&stack_chain;
	case RT_UNTAGGED:
		return untag_fixnum(ARG);
	case RT_MEGAMORPHIC_CACHE_HITS:
		return (cell)&megamorphic_cache_hits;
	default:
		critical_error("Bad rel type",rel);
		return 0; /* Can't happen */
	}

#undef ARG
}

cell compute_relocation(relocation_entry rel, cell index, code_block *compiled)
{
	return vm->compute_relocation(rel,index,compiled);
}

void factorvm::iterate_relocations(code_block *compiled, relocation_iterator iter)
{
	if(compiled->relocation != F)
	{
		byte_array *relocation = untag<byte_array>(compiled->relocation);

		cell index = stack_traces_p() ? 1 : 0;

		cell length = array_capacity(relocation) / sizeof(relocation_entry);
		for(cell i = 0; i < length; i++)
		{
			relocation_entry rel = relocation->data<relocation_entry>()[i];
			iter(rel,index,compiled);
			index += number_of_parameters(relocation_type_of(rel));			
		}
	}
}

void iterate_relocations(code_block *compiled, relocation_iterator iter)
{
	return vm->iterate_relocations(compiled,iter);
}

/* Store a 32-bit value into a PowerPC LIS/ORI sequence */
void factorvm::store_address_2_2(cell *ptr, cell value)
{
	ptr[-1] = ((ptr[-1] & ~0xffff) | ((value >> 16) & 0xffff));
	ptr[ 0] = ((ptr[ 0] & ~0xffff) | (value & 0xffff));
}

void store_address_2_2(cell *ptr, cell value)
{
	return vm->store_address_2_2(ptr,value);
}

/* Store a value into a bitfield of a PowerPC instruction */
void factorvm::store_address_masked(cell *ptr, fixnum value, cell mask, fixnum shift)
{
	/* This is unaccurate but good enough */
	fixnum test = (fixnum)mask >> 1;
	if(value <= -test || value >= test)
		critical_error("Value does not fit inside relocation",0);

	*ptr = ((*ptr & ~mask) | ((value >> shift) & mask));
}

void store_address_masked(cell *ptr, fixnum value, cell mask, fixnum shift)
{
	return vm->store_address_masked(ptr,value,mask,shift);
}

/* Perform a fixup on a code block */
void factorvm::store_address_in_code_block(cell klass, cell offset, fixnum absolute_value)
{
	fixnum relative_value = absolute_value - offset;

	switch(klass)
	{
	case RC_ABSOLUTE_CELL:
		*(cell *)offset = absolute_value;
		break;
	case RC_ABSOLUTE:
		*(u32*)offset = absolute_value;
		break;
	case RC_RELATIVE:
		*(u32*)offset = relative_value - sizeof(u32);
		break;
	case RC_ABSOLUTE_PPC_2_2:
		store_address_2_2((cell *)offset,absolute_value);
		break;
	case RC_ABSOLUTE_PPC_2:
		store_address_masked((cell *)offset,absolute_value,rel_absolute_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_2:
		store_address_masked((cell *)offset,relative_value,rel_relative_ppc_2_mask,0);
		break;
	case RC_RELATIVE_PPC_3:
		store_address_masked((cell *)offset,relative_value,rel_relative_ppc_3_mask,0);
		break;
	case RC_RELATIVE_ARM_3:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			rel_relative_arm_3_mask,2);
		break;
	case RC_INDIRECT_ARM:
		store_address_masked((cell *)offset,relative_value - sizeof(cell),
			rel_indirect_arm_mask,0);
		break;
	case RC_INDIRECT_ARM_PC:
		store_address_masked((cell *)offset,relative_value - sizeof(cell) * 2,
			rel_indirect_arm_mask,0);
		break;
	default:
		critical_error("Bad rel class",klass);
		break;
	}
}

void store_address_in_code_block(cell klass, cell offset, fixnum absolute_value)
{
	return vm->store_address_in_code_block(klass,offset,absolute_value);
}

void factorvm::update_literal_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	if(relocation_type_of(rel) == RT_IMMEDIATE)
	{
		cell offset = relocation_offset_of(rel) + (cell)(compiled + 1);
		array *literals = untag<array>(compiled->literals);
		fixnum absolute_value = array_nth(literals,index);
		store_address_in_code_block(relocation_class_of(rel),offset,absolute_value);
	}
}

void update_literal_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	return vm->update_literal_references_step(rel,index,compiled);
}

/* Update pointers to literals from compiled code. */
void factorvm::update_literal_references(code_block *compiled)
{
	if(!compiled->needs_fixup)
	{
		iterate_relocations(compiled,factor::update_literal_references_step);
		flush_icache_for(compiled);
	}
}

void update_literal_references(code_block *compiled)
{
	return vm->update_literal_references(compiled);
}

/* Copy all literals referenced from a code block to newspace. Only for
aging and nursery collections */
void factorvm::copy_literal_references(code_block *compiled)
{
	if(collecting_gen >= compiled->last_scan)
	{
		if(collecting_accumulation_gen_p())
			compiled->last_scan = collecting_gen;
		else
			compiled->last_scan = collecting_gen + 1;

		/* initialize chase pointer */
		cell scan = newspace->here;

		copy_handle(&compiled->literals);
		copy_handle(&compiled->relocation);

		/* do some tracing so that all reachable literals are now
		at their final address */
		copy_reachable_objects(scan,&newspace->here);

		update_literal_references(compiled);
	}
}

void copy_literal_references(code_block *compiled)
{
	return vm->copy_literal_references(compiled);
}

/* Compute an address to store at a relocation */
void factorvm::relocate_code_block_step(relocation_entry rel, cell index, code_block *compiled)
{
#ifdef FACTOR_DEBUG
	tagged<array>(compiled->literals).untag_check();
	tagged<byte_array>(compiled->relocation).untag_check();
#endif

	store_address_in_code_block(relocation_class_of(rel),
				    relocation_offset_of(rel) + (cell)compiled->xt(),
				    compute_relocation(rel,index,compiled));
}

void relocate_code_block_step(relocation_entry rel, cell index, code_block *compiled)
{
	return vm->relocate_code_block_step(rel,index,compiled);
}

void factorvm::update_word_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	relocation_type type = relocation_type_of(rel);
	if(type == RT_XT || type == RT_XT_PIC || type == RT_XT_PIC_TAIL)
		relocate_code_block_step(rel,index,compiled);
}

void update_word_references_step(relocation_entry rel, cell index, code_block *compiled)
{
	return vm->update_word_references_step(rel,index,compiled);
}

/* Relocate new code blocks completely; updating references to literals,
dlsyms, and words. For all other words in the code heap, we only need
to update references to other words, without worrying about literals
or dlsyms. */
void factorvm::update_word_references(code_block *compiled)
{
	if(compiled->needs_fixup)
		relocate_code_block(compiled);
	/* update_word_references() is always applied to every block in
	   the code heap. Since it resets all call sites to point to
	   their canonical XT (cold entry point for non-tail calls,
	   standard entry point for tail calls), it means that no PICs
	   are referenced after this is done. So instead of polluting
	   the code heap with dead PICs that will be freed on the next
	   GC, we add them to the free list immediately. */
	else if(compiled->type == PIC_TYPE)
		heap_free(&code,compiled);
	else
	{
		iterate_relocations(compiled,factor::update_word_references_step);
		flush_icache_for(compiled);
	}
}

void update_word_references(code_block *compiled)
{
	return vm->update_word_references(compiled);
}

void factorvm::update_literal_and_word_references(code_block *compiled)
{
	update_literal_references(compiled);
	update_word_references(compiled);
}

void update_literal_and_word_references(code_block *compiled)
{
	return vm->update_literal_and_word_references(compiled);
}

void factorvm::check_code_address(cell address)
{
#ifdef FACTOR_DEBUG
	assert(address >= code.seg->start && address < code.seg->end);
#endif
}

void check_code_address(cell address)
{
	return vm->check_code_address(address);
}

/* Update references to words. This is done after a new code block
is added to the heap. */

/* Mark all literals referenced from a word XT. Only for tenured
collections */
void factorvm::mark_code_block(code_block *compiled)
{
	check_code_address((cell)compiled);

	mark_block(compiled);

	copy_handle(&compiled->literals);
	copy_handle(&compiled->relocation);
}

void mark_code_block(code_block *compiled)
{
	return vm->mark_code_block(compiled);
}

void factorvm::mark_stack_frame_step(stack_frame *frame)
{
	mark_code_block(frame_code(frame));
}

void mark_stack_frame_step(stack_frame *frame)
{
	return vm->mark_stack_frame_step(frame);
}

/* Mark code blocks executing in currently active stack frames. */
void factorvm::mark_active_blocks(context *stacks)
{
	if(collecting_gen == data->tenured())
	{
		cell top = (cell)stacks->callstack_top;
		cell bottom = (cell)stacks->callstack_bottom;

		iterate_callstack(top,bottom,factor::mark_stack_frame_step);
	}
}

void mark_active_blocks(context *stacks)
{
	return vm->mark_active_blocks(stacks);
}

void factorvm::mark_object_code_block(object *object)
{
	switch(object->h.hi_tag())
	{
	case WORD_TYPE:
		{
			word *w = (word *)object;
			if(w->code)
				mark_code_block(w->code);
			if(w->profiling)
				mark_code_block(w->profiling);
			break;
		}
	case QUOTATION_TYPE:
		{
			quotation *q = (quotation *)object;
			if(q->code)
				mark_code_block(q->code);
			break;
		}
	case CALLSTACK_TYPE:
		{
			callstack *stack = (callstack *)object;
			iterate_callstack_object(stack,factor::mark_stack_frame_step);
			break;
		}
	}
}

void mark_object_code_block(object *object)
{
	return vm->mark_object_code_block(object);
}

/* Perform all fixups on a code block */
void factorvm::relocate_code_block(code_block *compiled)
{
	compiled->last_scan = data->nursery();
	compiled->needs_fixup = false;
	iterate_relocations(compiled,factor::relocate_code_block_step);
	flush_icache_for(compiled);
}

void relocate_code_block(code_block *compiled)
{
	return vm->relocate_code_block(compiled);
}

/* Fixup labels. This is done at compile time, not image load time */
void factorvm::fixup_labels(array *labels, code_block *compiled)
{
	cell i;
	cell size = array_capacity(labels);

	for(i = 0; i < size; i += 3)
	{
		cell klass = untag_fixnum(array_nth(labels,i));
		cell offset = untag_fixnum(array_nth(labels,i + 1));
		cell target = untag_fixnum(array_nth(labels,i + 2));

		store_address_in_code_block(klass,
			offset + (cell)(compiled + 1),
			target + (cell)(compiled + 1));
	}
}

void fixup_labels(array *labels, code_block *compiled)
{
	return vm->fixup_labels(labels,compiled);
}

/* Might GC */
code_block *factorvm::allot_code_block(cell size)
{
	heap_block *block = heap_allot(&code,size + sizeof(code_block));

	/* If allocation failed, do a code GC */
	if(block == NULL)
	{
		gc();
		block = heap_allot(&code,size + sizeof(code_block));

		/* Insufficient room even after code GC, give up */
		if(block == NULL)
		{
			cell used, total_free, max_free;
			heap_usage(&code,&used,&total_free,&max_free);

			print_string("Code heap stats:\n");
			print_string("Used: "); print_cell(used); nl();
			print_string("Total free space: "); print_cell(total_free); nl();
			print_string("Largest free block: "); print_cell(max_free); nl();
			fatal_error("Out of memory in add-compiled-block",0);
		}
	}

	return (code_block *)block;
}

code_block *allot_code_block(cell size)
{
	return vm->allot_code_block(size);
}

/* Might GC */
code_block *factorvm::add_code_block(cell type,cell code_,cell labels_,cell relocation_,cell literals_)
{
	gc_root<byte_array> code(code_,this);
	gc_root<object> labels(labels_,this);
	gc_root<byte_array> relocation(relocation_,this);
	gc_root<array> literals(literals_,this);

	cell code_length = align8(array_capacity(code.untagged()));
	code_block *compiled = allot_code_block(code_length);

	/* compiled header */
	compiled->type = type;
	compiled->last_scan = data->nursery();
	compiled->needs_fixup = true;
	compiled->relocation = relocation.value();

	/* slight space optimization */
	if(literals.type() == ARRAY_TYPE && array_capacity(literals.untagged()) == 0)
		compiled->literals = F;
	else
		compiled->literals = literals.value();

	/* code */
	memcpy(compiled + 1,code.untagged() + 1,code_length);

	/* fixup labels */
	if(labels.value() != F)
		fixup_labels(labels.as<array>().untagged(),compiled);

	/* next time we do a minor GC, we have to scan the code heap for
	literals */
	last_code_heap_scan = data->nursery();

	return compiled;
}

code_block *add_code_block(cell type,cell code_,cell labels_,cell relocation_,cell literals_)
{
	return vm->add_code_block(type,code_,labels_,relocation_,literals_);
}

}
