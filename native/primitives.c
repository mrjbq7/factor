#include "factor.h"

XT primitives[] = {
	undefined,
	call,
	primitive_execute,
	primitive_call,
	primitive_ifte,
	primitive_consp,
	primitive_cons,
	primitive_car,
	primitive_cdr,
	primitive_set_car,
	primitive_set_cdr,
	primitive_vectorp,
	primitive_vector,
	primitive_vector_length,
	primitive_set_vector_length,
	primitive_vector_nth,
	primitive_set_vector_nth,
	primitive_stringp,
	primitive_string_length,
	primitive_string_nth,
	primitive_string_compare,
	primitive_string_eq,
	primitive_string_hashcode,
	primitive_index_of,
	primitive_substring,
	primitive_sbufp,
	primitive_sbuf,
	primitive_sbuf_length,
	primitive_set_sbuf_length,
	primitive_sbuf_nth,
	primitive_set_sbuf_nth,
	primitive_sbuf_append,
	primitive_sbuf_to_string,
	primitive_numberp,
	primitive_to_fixnum,
	primitive_to_bignum,
	primitive_to_integer,
	primitive_to_float,
	primitive_number_eq,
	primitive_fixnump,
	primitive_bignump,
	primitive_ratiop,
	primitive_numerator,
	primitive_denominator,
	primitive_floatp,
	primitive_str_to_float,
	primitive_float_to_str,
	primitive_complexp,
	primitive_real,
	primitive_imaginary,
	primitive_to_rect,
	primitive_from_rect,
	primitive_add,
	primitive_subtract,
	primitive_multiply,
	primitive_divint,
	primitive_divfloat,
	primitive_divide,
	primitive_mod,
	primitive_divmod,
	primitive_and,
	primitive_or,
	primitive_xor,
	primitive_not,
	primitive_shiftleft,
	primitive_shiftright,
	primitive_less,
	primitive_lesseq,
	primitive_greater,
	primitive_greatereq,
	primitive_wordp,
	primitive_word,
	primitive_word_primitive,
	primitive_set_word_primitive,
	primitive_word_parameter,
	primitive_set_word_parameter,
	primitive_word_plist,
	primitive_set_word_plist,
	primitive_drop,
	primitive_dup,
	primitive_swap,
	primitive_over,
	primitive_pick,
	primitive_nip,
	primitive_tuck,
	primitive_rot,
	primitive_to_r,
	primitive_from_r,
	primitive_eq,
	primitive_getenv,
	primitive_setenv,
	primitive_open_file,
	primitive_gc,
	primitive_save_image,
	primitive_datastack,
	primitive_callstack,
	primitive_set_datastack,
	primitive_set_callstack,
	primitive_handlep,
	primitive_exit,
	primitive_server_socket,
	primitive_close_fd,
	primitive_accept_fd,
	primitive_read_line_fd_8,
	primitive_write_fd_8,
	primitive_flush_fd,
	primitive_shutdown_fd,
	primitive_room,
	primitive_os_env,
	primitive_millis,
	primitive_init_random,
	primitive_random_int
};

CELL primitive_to_xt(CELL primitive)
{
	if(primitive < 0 || primitive >= PRIMITIVE_COUNT)
		general_error(ERROR_BAD_PRIMITIVE,tag_fixnum(primitive));

	return (CELL)primitives[primitive];
}
