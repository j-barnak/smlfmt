(** Copyright (c) 2021 Sam Westrick
  *
  * See the file LICENSE for details.
  *)

(** This is essentially an intermediate representation for pretty-printing.
  * It's similar to a pretty doc, but the elements are tokens. The primary
  * transformation on this IR is to add comments.
  *)
structure TokenDoc :>
sig
  type t
  type doc = t

  val empty: doc
  val token: Token.t -> doc

  val beside: doc * doc -> doc

  (** When an "above" is flattened by a group, it can either be replaced by a
    * a space, or it can be put exactly beside (with no extra space).
    *)
  val aboveOrSpace: doc * doc -> doc
  val aboveOrBeside: doc * doc -> doc

  val space: doc
  val softspace: doc
  val group: doc -> doc

  val insertComments: doc -> doc

  val toStringDoc: doc -> StringDoc.t
end =
struct

  (** for Space and Above, the boolean indicates whether or not to
    * keep space when undone by group.
    *)
  datatype doc =
    Empty
  | Space of bool
  | Token of Token.t
  | Beside of doc * doc
  | Above of bool * doc * doc
  | Group of doc

  type t = doc

  val empty = Empty
  val token = Token
  val group = Group

  fun beside (doc1, doc2) =
    case (doc1, doc2) of
      (Empty, _) => doc2
    | (_, Empty) => doc1
    | _ => Beside (doc1, doc2)

  fun above' withSpace (doc1, doc2) =
    case (doc1, doc2) of
      (Empty, _) => doc2
    | (_, Empty) => doc1
    | _ => Above (withSpace, doc1, doc2)

  val aboveOrSpace = above' true
  val aboveOrBeside = above' false

  val empty = Empty
  val space = Space true
  val softspace = Space false

  fun insertComments doc =
    let
      (** Does this doc most recently appear beside something,
        * or below something?
        *)
      datatype mode = BesideMode | AboveMode

      fun token mode tok =
        let
          fun combine (doc, tok) =
            case mode of
              BesideMode => beside (doc, beside (space, Token tok))
            | AboveMode => aboveOrSpace (doc, Token tok)
        in
          combine (Seq.iterate combine empty (Token.commentsBefore tok), tok)
        end

      fun traverse mode d =
        case d of
          Token tok =>
            token mode tok
        | Beside (d1, d2) =>
            Beside (traverse mode d1, traverse BesideMode d2)
        | Above (b, d1, d2) =>
            Above (b, traverse mode d1, traverse AboveMode d2)
        | Group d =>
            Group (traverse mode d)
        | _ => d
    in
      traverse AboveMode doc
    end


  fun toStringDoc d =
    case d of
      Empty =>
        StringDoc.empty
    | Space true =>
        StringDoc.space
    | Space false =>
        StringDoc.softspace
    | Beside (d1, d2) =>
        StringDoc.beside (toStringDoc d1, toStringDoc d2)
    | Above (true, d1, d2) =>
        StringDoc.aboveOrSpace (toStringDoc d1, toStringDoc d2)
    | Above (false, d1, d2) =>
        StringDoc.aboveOrBeside (toStringDoc d1, toStringDoc d2)
    | Group d =>
        StringDoc.group (toStringDoc d)
    | Token t =>
        StringDoc.text (Token.toString t)

end