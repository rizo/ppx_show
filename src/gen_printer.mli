(*
 * gen_printer.mli
 * ---------------
 * Copyright : (c) 2011-2015, Jeremie Dimino <jeremie@dimino.org>
 * Licence   : BSD3
 *)

val map_impl : Parsetree.structure -> Parsetree.structure

(** Register a generator. *)
val register_generator
  :  string
  -> generate:(Env.t -> Types.type_expr -> Location.t -> Parsetree.expression)
  -> combinator_type:(Parsetree.core_type -> Parsetree.core_type)
  -> unit

(** A single location. *)
module type Loc = sig
  val loc : Location.t
end

type tuple_or_record =
  | Tuple  of Parsetree.expression list
  | Record of (string * Parsetree.expression) list

(** Signature of combinator-based generators. *)
module type Combinators = sig

  open Parsetree

  val typ : core_type -> core_type
    (** The type of combinators. For example, applied to the
        representation of the [int] type, it builds the representation
        of the type of the [int] combinator. *)

  val get_param : Types.type_expr -> Types.type_expr
    (** Returns the type parameter from a combinator type. For
        example, for ['a -> string] genetors, it must returns the
        value of ['a]. *)

  val prefix : string
    (** The prefix of generators. For example "string_of_", "print_",
        ... *)

  val int : expression
  val char : expression
  val string : expression
  val float : expression
  val bool : expression
  val unit : expression
  val exn : expression
  val array : expression
  val list : expression
  val nativeint : expression
  val int32 : expression
  val int64 : expression
  val lazy_t : expression

  val var : expression
  val abstract : expression
  val arrow : expression
  val tuple : expression list -> expression
  val obj : expression
  val poly_variant : (string * expression option) list -> expression
  val package : expression

  val variant : (Longident.t * string * tuple_or_record) list -> expression
  val record : (Longident.t * string * expression) list -> expression

  val extension_constructor : expression

  val map : expression -> f:expression -> expression
end

(** Create a generator from combinators. *)
module GeneratorOfCombinators(Make : functor (Loc : Loc) -> Combinators) : sig
  val generate : Env.t -> Types.type_expr -> Location.t -> Parsetree.expression
end

(* This is now super-seeded by Ast_helper *)
(** Create helpers for generating parsetrees. *)
module MakeHelpers(Loc : Loc) : sig

  open Parsetree

  val gen_vars : 'a list -> string list

  val exp_unit : expression
  val exp_ifthenelse : expression -> expression -> expression -> expression
  val exp_letrec : (pattern * expression) list -> expression -> expression
  val exp_let : pattern -> expression -> expression -> expression
  val exp_string : string -> expression
  val exp_int : int -> expression
  val exp_fun : pattern -> expression -> expression
  val exp_function : (pattern * expression) list -> expression
  val exp_apply : expression -> expression list -> expression
  val exp_tuple : expression list -> expression
  val exp_ident : string list -> expression
  val exp_var : string -> expression
  val exp_field : expression -> Longident.t -> expression
  val exp_seq : expression list -> expression

  val pat_array : pattern list -> pattern
  val pat_lazy : pattern -> pattern
  val pat_any : pattern
  val pat_construct : Longident.t -> pattern option -> pattern
  val pat_variant : string -> pattern option -> pattern
  val pat_var : string -> pattern
  val pat_tuple : pattern list -> pattern
  val pat_constraint : pattern -> core_type -> pattern

  val typ_var : string -> core_type
  val typ_arrow : core_type -> core_type -> core_type
  val typ_constr : Longident.t -> core_type list -> core_type
  val typ_poly : string Asttypes.loc list -> core_type -> core_type

  val longident_of_list : string list -> Longident.t
  val longident_of_path : Path.t -> Longident.t
end
