# OCaml Mini-Language Interpreter with Dictionary Extension

## Panoramica del Progetto
Questo progetto consiste in un interprete per un mini-linguaggio di programmazione funzionale progettato e sviluppato interamente da zero in **OCaml**. L'interprete implementa una semantica operazionale big-step e supporta operazioni matematiche, costrutti di controllo del flusso, e funzioni di ordine superiore tramite chiusure statiche. 

Il cuore distintivo di questo progetto è **l'estensione nativa per i Dizionari**, che introduce una struttura dati chiave-valore nel linguaggio, dotata di operazioni primitive e operatori funzionali avanzati come Map (`Iterate`), `Fold` e `Filter`.

## Caratteristiche Principali

L'interprete supporta una vasta gamma di costrutti, definiti attraverso un Abstract Syntax Tree (AST) tipizzato rigidamente:

* **Tipi Primitivi**: Interi (`Eint`), Booleani (`Ebool`) e Stringhe.
* **Aritmetica e Logica**: Somma, Sottrazione, Moltiplicazione, operatori relazionali (`Eq`, `IsZero`) e logici (`And`, `Or`, `Not`).
* **Binding e Funzioni**: 
    * Dichiarazione di variabili locali tramite `Let`.
    * Funzioni anonime (`Fun`) e chiamate a funzione (`FunCall`).
    * Ricorsione supportata nativamente tramite `Letrec`.
    * Risoluzione statica dello scope ambientale basata su **Chiusure (Closures)** (`FunVal`, `RecFunVal`).
* **Type Checking Dinamico**: Il sistema include funzioni di type-checking a runtime (`typecheck`) per garantire che le operazioni vengano eseguite sui tipi corretti, sollevando eccezioni in caso di discrepanze.

## Estensione Dizionari (Dictionary Extension)

I dizionari sono implementati come liste di coppie identificatore-espressione `(ide * exp) list` e valutati come `DictVal`. Il linguaggio fornisce le seguenti primitive per manipolarli in modo sicuro:

* **Creazione**: Inizializzazione di un nuovo dizionario.
* **Manipolazione base**: `Insert` (inserisce un elemento, solleva un'eccezione se la chiave esiste già), `Delete` (rimuove una chiave) e `Has_key` (verifica l'esistenza di una chiave).
* **Operazioni Funzionali di Ordine Superiore**:
    * `Iterate`: Applica una funzione a tutti i valori del dizionario, restituendo un nuovo dizionario (comportamento analogo a *Map*).
    * `Fold`: Riduce il dizionario a un singolo valore accumulando i risultati dell'applicazione di una funzione ai suoi elementi.
    * `Filter`: Restituisce un nuovo dizionario contenente solo le chiavi specificate in una determinata lista.

## Esempi di Utilizzo

Gli esempi seguenti (estratti dai test di validazione dell'interprete) mostrano come il linguaggio interagisce con i dizionari.

### 1. Inizializzazione e Inserimento
Creazione di un inventario e aggiunta di un nuovo elemento:

```ocaml
(* Inizializzazione del dizionario base *)
let env = emptyenv Unbound;;
let exp = Dictionary([("mele", Eint(430)); ("banane", Eint(312)); ("arance",Eint(525)); ("pere",Eint(217))]);;

(* Inserimento di una nuova chiave con gestione degli errori *)
let exp = Insert("kiwi", Eint(300), exp);;
eval exp env;;
```

### 2. Funzioni di Ordine Superiore sui Dizionari
Definizione di una funzione di incremento e sua applicazione tramite `Iterate` e `Fold`:

```ocaml
(* Definizione di una funzione f(x) = x + 1 *)
let funz = Fun("x", Sum(Den "x", Eint 1));;

(* Iterate (Map): Incrementa tutti i valori nel dizionario di 1 *)
let exp_iterate = Iterate(funz, exp);;
eval exp_iterate env;;

(* Fold: Accumula il risultato della funzione sui valori del dizionario *)
let exp_fold = Fold(funz, exp);;
eval exp_fold env;;
```

### 3. Filtraggio
Mantenere nel dizionario solo le chiavi desiderate tramite una query list:

```ocaml
let keyList : ide list = ["mele"; "banane"];;
let exp_filter = Filter(keyList, exp);;
eval exp_filter env;;
```

## Iniziare / Testing
L'interprete utilizza un ambiente base (Environment) che mappa gli identificatori ai loro valori esprimibili (`evT`). L'ambiente vuoto gestisce le eccezioni sollevando valori `Unbound`. I test forniti in `Test_2.ml` verificano la robustezza delle operazioni sui dizionari, includendo la gestione degli edge cases (chiavi mancanti o duplicate).
