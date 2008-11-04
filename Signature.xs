#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_PL_parser
#include "ppport.h"

#include "hook_op_check.h"
#include "hook_parser.h"

typedef struct userdata_St {
	char *f_class;
	SV *class;
} userdata_t;

STATIC void
call_to_perl (SV *class, UV offset, char *proto) {
	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK (SP);
	EXTEND (SP, 3);
	PUSHs (class);
	mPUSHu (offset);
	mPUSHp (proto, strlen (proto));
	PUTBACK;

	call_method ("callback", G_VOID|G_DISCARD);

	FREETMPS;
	LEAVE;
}

STATIC SV *
qualify_func_name (const char *s) {
	SV *ret = newSVpvs ("");

	if (strstr (s, ":") == NULL) {
		sv_catpv (ret, SvPVX (PL_curstname));
		sv_catpvs (ret, "::");
	}

	sv_catpv (ret, s);

	return ret;
}

STATIC OP *
handle_proto (pTHX_ OP *op, void *user_data) {
	SV *op_sv, *name;
	char *s, *tmp, *tmp2, *proto;
	char tmpbuf[sizeof (PL_tokenbuf)];
	STRLEN retlen = 0;
	userdata_t *ud = (userdata_t *)user_data;

	if (strNE (ud->f_class, SvPVX (PL_curstname))) {
		return op;
	}

	if (!PL_parser) {
		return op;
	}

	if (!PL_lex_stuff) {
		return op;
	}

	op_sv = cSVOPx (op)->op_sv;

	if (!SvPOK (op_sv)) {
		return op;
	}

	/* sub $name */
	s = PL_parser->oldbufptr;
	s = hook_toke_skipspace (aTHX_ s);

	if (strnNE (s, "sub", 3)) {
		return op;
	}

	if (!isSPACE (s[4])) {
		return op;
	}

	s = hook_toke_skipspace (aTHX_ s + 4);

	if (strNE (SvPVX (PL_subname), "?")) {
		(void)hook_toke_scan_word (aTHX_ (s - SvPVX (PL_linestr)), 1, tmpbuf, sizeof (tmpbuf), &retlen);

		if (!tmpbuf) {
			return op;
		}

		name = qualify_func_name (tmpbuf);

		if (!sv_eq (PL_subname, name)) {
			SvREFCNT_dec (name);
			return op;
		}

		SvREFCNT_dec (name);
	}

	/* ($proto) */
	s = hook_toke_skipspace (aTHX_ s + retlen);
	if (s[0] != '(') {
		return op;
	}

	tmp = hook_toke_scan_str (aTHX_ s);
	proto = hook_parser_get_lex_stuff (aTHX);
	hook_parser_clear_lex_stuff (aTHX);

	if (s == tmp || !proto) {
		return op;
	}

	s++;
	tmp2 = proto;

	while (tmp > s + 1) {
		if (isSPACE (s[0])) {
			s++;
			continue;
		}

		if (*tmp2 != *s) {
			return op;
		}

		tmp2++;
		s++;
	}

	s = hook_toke_skipspace (aTHX_ s + 1);
	if (s[0] != '{') {
		return op;
	}

	call_to_perl (ud->class, s - hook_parser_get_linestr (aTHX), proto);

	op_free (op);
	return NULL;
}

MODULE = Sub::Signature  PACKAGE = Sub::Signature

PROTOTYPES: DISABLE

UV
setup (class, f_class)
		SV *class
		char *f_class
	PREINIT:
		userdata_t *ud;
	INIT:
		Newx (ud, 1, userdata_t);
		ud->class = newSVsv (class);
		ud->f_class = f_class;
	CODE:
		RETVAL = (UV)hook_op_check (OP_CONST, handle_proto, ud);
	OUTPUT:
		RETVAL

void
teardown (class, id)
		UV id
	PREINIT:
		userdata_t *ud;
	CODE:
		ud = (userdata_t *)hook_op_check_remove (OP_CONST, id);

		if (ud) {
			SvREFCNT_dec (ud->class);
			Safefree (ud);
		}
