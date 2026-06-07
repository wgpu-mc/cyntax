/* pp_tests.h
 * Preprocessor test suite.
 * No #include — feed this through your preprocessor and check the output.
 * Expected output is noted in comments as: EXPECT: <tokens>
 */

/* ─── Object-like macros ─────────────────────────────────────────── */

#define ZERO 0
#define ONE 1
#define FORTY_TWO 42
#define PI_APPROX 3

ZERO        /* EXPECT: 0 */
ONE         /* EXPECT: 1 */
FORTY_TWO   /* EXPECT: 42 */
PI_APPROX   /* EXPECT: 3 */

/* Redefinition with same body should be fine */
#define FORTY_TWO 42
FORTY_TWO   /* EXPECT: 42 */

/* Chained object macros */
#define BASE 10
#define DOUBLE_BASE BASE + BASE
DOUBLE_BASE /* EXPECT: 10 + 10 */

/* ─── Function-like macros ───────────────────────────────────────── */

#define IDENTITY(x) x
#define ADD(a, b) a + b
#define MUL(a, b) a * b
#define MAX(a, b) a > b ? a : b
#define SQUARE(x) x * x

IDENTITY(99)        /* EXPECT: 99 */
ADD(1, 2)           /* EXPECT: 1 + 2 */
MUL(3, 4)           /* EXPECT: 3 * 4 */
MAX(10, 20)         /* EXPECT: 10 > 20 ? 10 : 20 */
SQUARE(5)           /* EXPECT: 5 * 5 */

/* Nested macro calls */
#define INNER(x) x + 1
#define OUTER(x) INNER(x) * 2
OUTER(3)            /* EXPECT: 3 + 1 * 2 */

/* Macro argument that is itself a macro */
IDENTITY(FORTY_TWO) /* EXPECT: 42 */
ADD(ONE, ZERO)      /* EXPECT: 1 + 0 */

/* ─── #ifdef / #ifndef / #endif ──────────────────────────────────── */

#define DEFINED_FLAG

#ifdef DEFINED_FLAG
yes_defined         /* EXPECT: yes_defined */
#endif

#ifdef UNDEFINED_FLAG
should_not_appear
#endif

#ifndef UNDEFINED_FLAG
yes_not_defined     /* EXPECT: yes_not_defined */
#endif

#ifndef DEFINED_FLAG
should_not_appear
#endif

/* ─── #else ──────────────────────────────────────────────────────── */

#ifdef UNDEFINED_FLAG
wrong_branch
#else
correct_else_branch /* EXPECT: correct_else_branch */
#endif

#ifndef DEFINED_FLAG
wrong_branch
#else
correct_ifndef_else /* EXPECT: correct_ifndef_else */
#endif

/* ─── #elif ──────────────────────────────────────────────────────── */

#define MODE 2

#if MODE == 1
mode_one
#elif MODE == 2
mode_two            /* EXPECT: mode_two */
#elif MODE == 3
mode_three
#else
mode_unknown
#endif

/* elif chain where none match — should hit else */
#define VAL 99

#if VAL == 1
nope_1
#elif VAL == 2
nope_2
#elif VAL == 3
nope_3
#else
val_else            /* EXPECT: val_else */
#endif

/* ─── #if constant expressions ───────────────────────────────────── */

/* Arithmetic */
#if 1 + 1 == 2
arith_ok            /* EXPECT: arith_ok */
#endif

#if 10 - 3 == 7
sub_ok              /* EXPECT: sub_ok */
#endif

#if 3 * 4 == 12
mul_ok              /* EXPECT: mul_ok */
#endif

#if 10 / 2 == 5
div_ok              /* EXPECT: div_ok */
#endif

/* Relational */
#if 5 > 4
gt_ok               /* EXPECT: gt_ok */
#endif

#if 4 < 5
lt_ok               /* EXPECT: lt_ok */
#endif

#if 5 >= 5
gte_ok              /* EXPECT: gte_ok */
#endif

#if 4 <= 4
lte_ok              /* EXPECT: lte_ok */
#endif

/* Logical */
#if 1 && 1
and_ok              /* EXPECT: and_ok */
#endif

#if 0 && 1
should_not_appear
#endif

#if 0 || 1
or_ok               /* EXPECT: or_ok */
#endif

#if !0
not_ok              /* EXPECT: not_ok */
#endif

/* Compound */
#if (1 + 2) * 3 == 9
compound_ok         /* EXPECT: compound_ok */
#endif

#if 2 * 2 == 4 && 3 * 3 == 9
both_ok             /* EXPECT: both_ok */
#endif

/* Macro in #if condition */
#if ZERO == 0
zero_check_ok       /* EXPECT: zero_check_ok */
#endif

#if ONE == 1 && ZERO == 0
one_zero_ok         /* EXPECT: one_zero_ok */
#endif

#if FORTY_TWO > 41
forty_two_gt_ok     /* EXPECT: forty_two_gt_ok */
#endif

/* defined() operator */
#if defined(DEFINED_FLAG)
defined_op_ok       /* EXPECT: defined_op_ok */
#endif

#if !defined(UNDEFINED_FLAG)
not_defined_op_ok   /* EXPECT: not_defined_op_ok */
#endif

#if defined(DEFINED_FLAG) && !defined(UNDEFINED_FLAG)
defined_combo_ok    /* EXPECT: defined_combo_ok */
#endif

/* ─── #undef ──────────────────────────────────────────────────────── */

#define TEMP_MACRO 55
TEMP_MACRO          /* EXPECT: 55 */
#undef TEMP_MACRO

#ifdef TEMP_MACRO
should_not_appear_after_undef
#else
undef_ok            /* EXPECT: undef_ok */
#endif

/* ─── Macro self-reference (blue paint / non-recursive) ───────────── */

/* A macro that references its own name should NOT recurse —
   the second RECURSE should be left as-is (blue-painted). */
#define RECURSE RECURSE + 1
RECURSE             /* EXPECT: RECURSE + 1 */

/* ─── Whitespace/empty argument edge cases ────────────────────────── */

#define EMPTY
#ifdef EMPTY
empty_defined_ok    /* EXPECT: empty_defined_ok */
#endif

/* ─── Token pasting (## operator) ────────────────────────────────── */

/* Uncomment if your preprocessor supports ##.
   GLSL does not require it, so these are optional.

#define PASTE(a, b) a ## b
#define MAKE_NAME(n) var_ ## n

PASTE(foo, bar)         // EXPECT: foobar
MAKE_NAME(x)            // EXPECT: var_x
PASTE(1, 2)             // EXPECT: 12
*/