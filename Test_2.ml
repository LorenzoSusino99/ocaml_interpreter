(*Testing interpreter*)
let env = emptyenv Unbound;;
let exp = Dictionary([("mele", Eint(430)); ("banane", Eint(312)); ("arance",Eint(525)); ("pere",Eint(217))]);;
eval exp env;;

(*INSERT*)
(*Duplicate*)
let ins_wrong = Insert("mele", Eint(200), exp);;
eval ins_wrong env;;
(*Correct one*)
let exp = Insert("kiwi", Eint(300), exp);;
eval exp env;;

(*DELETE*)
(*Key not found*)
let del_wrong = Delete(exp, "ananas");;
eval del_wrong env;;
(*Correct one*)
let exp = Delete(exp, "mele");;
eval exp env;;

(*HAS_KEY*)
(*Key not found*)
let has_not = Has_key("ananas", exp);;
eval has_not env;;
(*Key founded*)
let has = Has_key("banane", exp);;
eval has env;;

(*ITERATE*)
let funz = Fun("x", Sum(Den "x", Eint 1));;
let exp = Iterate(funz, Dictionary([("mele", Eint(430)); ("banane", Eint(312)); ("arance",Eint(525)); ("pere",Eint(217))]));;
eval exp env;;

(*FOLD*)
let funz = Fun("x", Sum(Den "x", Eint 1));;
let exp = Fold(funz, Dictionary([("mele", Eint(430)); ("banane", Eint(312)); ("arance",Eint(525)); ("pere",Eint(217))]));;
eval exp env;;

(*FILTER*)
let keyList : ide list= ["mele"; "banane"];;
let exp = Filter(keyList, Dictionary([("mele", Eint(430)); ("banane", Eint(312)); ("arance",Eint(525)); ("pere",Eint(217))]));;
eval exp env;;