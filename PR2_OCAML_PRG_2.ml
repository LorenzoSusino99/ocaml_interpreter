type ide = string;;

type exp = Eint of int 
  | Ebool of bool 
  | Den of ide 
  | Prod of exp * exp 
  | Sum of exp * exp 
  | Diff of exp * exp 
  | Eq of exp * exp 
  | Minus of exp 
  | IsZero of exp 
  | Or of exp * exp 
  | And of exp * exp 
  | Not of exp 
  | Ifthenelse of exp * exp * exp 
  | Let of ide * exp * exp 
  | Fun of ide * exp 
  | FunCall of exp * exp 
  | Letrec of ide * exp * exp
  (*Extension of language*)
  | Dictionary of (ide * exp) list
  | Insert of ide * exp * exp 
  | Delete of exp * ide 
  | Has_key of ide * exp
  | Iterate of exp * exp
  | Fold of exp * exp
  | Filter of (ide list) * exp;;

(*Environment*)
type 't env = ide -> 't;;
let emptyenv (v : 't) = function x -> v;;
let applyenv (r : 't env) (i : ide) = r i;;
let bind (r : 't env) (i : ide) (v : 't) = function x -> if x = i then v else applyenv r x;;

(*Expressible values*)
type evT =
    Int of int
  | Bool of bool
  | String of string
  | Unbound
  | FunVal of evFun
  | RecFunVal of ide * evFun
  | DictVal of (ide * evT) list
  and evFun = ide * exp * evT env;;

(*Type checking*)
let typecheck (s : string) (v : evT) : bool =
  match s with
  | "int" -> (match v with
              | Int(_) -> true
              | _ -> false)
  | "bool" -> (match v with
               | Bool(_) -> true
               | _ -> false)
  | _ -> failwith("not a valid type");;

(*Primitive function*)
let prod x y = if (typecheck "int" x) && (typecheck "int" y)
	then (match (x,y) with
		|(Int(n),Int(u)) -> Int(n*u))
	else failwith("Type error");;

let sum x y = if (typecheck "int" x) && (typecheck "int" y)
	then (match (x,y) with
		|(Int(n),Int(u)) -> Int(n+u))
	else failwith("Type error");;

let diff x y = if (typecheck "int" x) && (typecheck "int" y)
	then (match (x,y) with
		|(Int(n),Int(u)) -> Int(n-u))
	else failwith("Type error");;

let eq x y = if (typecheck "int" x) && (typecheck "int" y)
	then (match (x,y) with
		|(Int(n),Int(u)) -> Bool(n=u))
	else failwith("Type error");;

let minus x = if (typecheck "int" x) 
	then (match x with
	   	|Int(n) -> Int(-n))
	else failwith("Type error");;

let iszero x = if (typecheck "int" x)
	then (match x with
		|Int(n) -> Bool(n=0))
	else failwith("Type error");;

let vel x y = if (typecheck "bool" x) && (typecheck "bool" y)
	then (match (x,y) with
		|(Bool(b),Bool(e)) -> (Bool(b||e)))
	else failwith("Type error");;

let et x y = if (typecheck "bool" x) && (typecheck "bool" y)
	then (match (x,y) with
		|(Bool(b),Bool(e)) -> Bool(b&&e))
	else failwith("Type error");;

let non x = if (typecheck "bool" x)
	then (match x with
		|Bool(true) -> Bool(false) 
		|Bool(false) -> Bool(true))
	else failwith("Type error");;

(*Interprete*)
let rec eval (e : exp) (r : evT env) : evT =
	match e with
	| Eint n -> Int n
	| Ebool b -> Bool b
	| IsZero a -> iszero (eval a r)
	| Den i -> applyenv r i
	| Eq(a, b) -> eq (eval a r) (eval b r)
	| Prod(a, b) -> prod (eval a r) (eval b r)
	| Sum(a, b) -> sum (eval a r) (eval b r)
	| Diff(a, b) -> diff (eval a r) (eval b r)
	| Minus a -> minus (eval a r)
	| And(a, b) -> et (eval a r) (eval b r)
	| Or(a, b) -> vel (eval a r) (eval b r)
	| Not a -> non (eval a r)
	| Ifthenelse(a, b, c) ->
	  let g = (eval a r) in
		if (typecheck "bool" g) then (if g = Bool(true) then (eval b r) else (eval c r))
								else failwith ("non boolean guard")
	| Let(i, e1, e2) -> eval e2 (bind r i (eval e1 r))
	| Fun(i, a) -> FunVal(i, a, r)
	| FunCall(f, eArg) ->  let fClosure = (eval f r) in
		(match fClosure with
		 | FunVal(arg, fBody, fDecEnv) -> eval fBody (bind fDecEnv arg (eval eArg r))
		 | RecFunVal(g, (arg, fBody, fDecEnv)) ->
			 let aVal = (eval eArg r) in
			   let rEnv = (bind fDecEnv g fClosure) in
				 let aEnv = (bind rEnv arg aVal) in
				   eval fBody aEnv
		 | _ -> failwith("non functional value"))
	| Letrec(f, funDef, letBody) ->
		(match funDef with
		 | Fun(i, fBody) -> let r1 = (bind r f (RecFunVal(f, (i, fBody, r)))) in eval letBody r1
		 | _ -> failwith("non functional def"))
	| Dictionary(list) -> DictVal( evalList list r )
	| Insert(i, v, d) ->  
		(match eval d r with
		| DictVal(l) -> if(hasKey i l) then failwith("the key already exists")
						else DictVal(l @ [(i, eval v r)])
		| _ -> failwith("Insert must be used in a dictionary"))
	| Delete(d, i) ->
		(match eval d r with
		| DictVal(l) -> if(hasKey i l) then DictVal(delete l i)
						else failwith("The element doesn't exists")
		| _ -> failwith("Delete must be used in a dictionary"))
	| Has_key(i, d) ->
		(match eval d r with
		| DictVal(l) -> Bool(hasKey i l)
		| _ -> failwith("Has_key must be used in a dictionary"))
	| Iterate(f, d) ->
		(match d with
		| Dictionary(l) -> match eval f r with
						|FunVal(_,_,_) ->
							let rec apply (f : exp) (d : (ide * exp) list) (r1 : evT env) : (ide * evT) list = match d with
								|[] -> []
								|(i, v) :: t -> (i, (eval(FunCall(f, v)) r)) :: (apply f t r)
								in DictVal(apply f l r)
						|_ -> failwith("Iterate needs a function")
		| _ -> failwith("Iterate must be used in a dictionary"))
	| Fold(f, d) ->
		(match d with
			| Dictionary(l) -> match eval f r with
						|FunVal(_,_,_) ->
							let rec fold (acc : evT) (f : exp) (d1 : (ide * exp) list) (r1 : evT env) : evT = match d1 with
								|[] -> acc
								|(_, v) :: t -> match acc, (eval (FunCall(f, v)) r) with
												|Int(a), Int(v1) -> (fold (Int(v1 + a)) f t r)
												|_ -> failwith ("Problem with the function")
								in fold (Int(0)) f l r
						|_ -> failwith("Fold needs a function")
		| _ -> failwith("Fold must be used in a dictionary"))
	| Filter (kl, d) ->
		(match eval d r with
		| DictVal(l) -> let rec filter (kl1 : ide list) (d : (ide * evT) list) : (ide * evT) list = match d with
						|[] -> []
						|(i, v) :: t -> if (List.mem i kl1) then (i, v) :: filter kl1 t
										else filter kl1 t
						in DictVal(filter kl l)
		| _ -> failwith("Filter must be used in a dictionary"))
	(*evalList is outside becouse is the main operation*)
	and evalList (l : (ide * exp) list) (r : evT env) : (ide * evT) list =
		match l with
		| [] -> []
		| (i, v) :: t -> (i, eval v r) :: (evalList t r)
	(*hasKey is outside becouse i use it to do other operation like "Insert" and "Delete"*)
	and hasKey (i : ide) (d : (ide * evT) list) : bool = 
		match d with 
		|[] -> false
		|(id, _) :: t -> if (i = id) then true
						 else hasKey i t
	(*delete is outside to take the code clean*)
	and delete (d : (ide * evT) list) (i : ide) : (ide * evT) list =
		(match d with
		|[] -> []
		|(id, v) :: t -> if(i = id) then delete t i 
						 else (id, v) :: delete t i);;
				