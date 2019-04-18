module WriteParser where

import Char

import Pappy


-- Generate the source code for a packrat parser
writeParser :: [Identifier] -> Grammar -> String
writeParser memos (parsername, topcode, topnts, nonterms) =

    "-- Parser generated by Pappy - do not edit\n" ++
    "module " ++ upcase parsername ++ " where\n\n" ++
    "import Pos\n" ++
    "import Parse\n" ++
    topcode ++ "\n" ++
    tie2level ++			-- tie1level or tie2level
    patpfuncs 0 nonterms		-- patpfuncs or monadpfuncs

    where

    -- Names of identifiers used throughout the parser
    derivstype = upcase parsername ++ "Derivs"
    pfuncname = locase parsername ++ "Parse"
    dfuncname = locase parsername ++ "Derivs"
    dvname n = locase parsername ++ n
    pname n = if n `elem` memos
		then locase parsername ++ "Parse" ++ n
		else dvname n

    -- Build an expression to reference nonterminal accessor n in d
    dvexp n d = dvname n ++ " " ++ d

    -- Names of temporaries used in the parsing functions
    --valname i = "pappyVal" ++ show i
    --dvsname i = "pappyDvs" ++ show i
    --errname i = "pappyErr" ++ show i
    valname i = "v" ++ show i	-- easier for debugging
    dvsname i = "d" ++ show i
    errname i = "e" ++ show i



    ---------- Single-level parser generation
    tie1level =
	derivsdecl ++
	derivsinstance ++
	parsefunc ++
	derivsfunc 0

	where

	-- Generate the Derivs type declaration
	derivsdecl =
		"data " ++ derivstype ++ " = " ++ derivstype ++ " {\n" ++
		components nonterms ++
		"\t\t" ++ dvname "Char" ++ " :: Result " ++ derivstype ++
							" Char,\n" ++
		"\t\t" ++ dvname "Pos" ++ " :: Pos\n" ++
		"\t}\n" ++
		"\n"

		where
		components ((name, typ, rule) : rest) | name `elem` memos =
			"\t\t" ++ dvname name ++
			" :: Result " ++ derivstype ++
			" (" ++ typ ++ "),\n" ++ components rest
		components(_ : rest) = components rest
		components [] = ""

	-- Generate the "instance Derivs" declaration
	derivsinstance =
		"instance Derivs " ++ derivstype ++ " where\n" ++
		"\tdvChar d = " ++ dvname "Char" ++ " d\n" ++
		"\tdvPos d = " ++ dvname "Pos" ++ " d\n" ++
		"\n"

	-- Generate the top-level parse function
	parsefunc =
		pfuncname ++ " :: String -> String -> " ++ derivstype ++ "\n" ++
		pfuncname ++ " name text = " ++ dfuncname ++
			" (Pos name 1 1) text\n\n"

	-- Generate the derivs-creation function
	derivsfunc i =
		ind i ++ dfuncname ++ " :: Pos -> String -> " ++
			derivstype ++ "\n" ++
		ind i ++ dfuncname ++ " pos text = dvs where\n" ++
		ind (i+1) ++ "dvs = " ++ derivstype ++ "\n" ++
		parsercalls nonterms ++
		ind (i+2) ++ "chr pos\n" ++
		ind (i+1) ++ "chr = case text of\n" ++
		ind (i+2) ++ "[] -> NoParse (eofError dvs)\n" ++
		ind (i+2) ++ "(c:cs) -> Parsed c (" ++ dfuncname ++
			" (nextPos pos c) cs) (nullError dvs)\n\n"

		where
		parsercalls ((name, typ, rule) : rest) | name `elem` memos =
			ind (i+2) ++ "(" ++ pname name ++ " dvs)\n" ++
			parsercalls rest
		parsercalls (_ : rest) = parsercalls rest
		parsercalls [] = ""



    ---------- Two-level parser generation
    tie2level =
	derivsdecl ++
	derivsinstance ++
	derivs2decls 0 ++
	aliases 0 nonterms ++ "\n" ++
	parsefunc ++
	derivsfunc 0 ++
	dsubfuncs 0

	where

	-- Total number of nonterminals in the grammar
	nmemos :: Int
	nmemos = length memos

	-- The number of sub-derivation structures to use
	nsubderivs :: Int
	nsubderivs = round (sqrt (fromInteger (toEnum nmemos)) / 2.0)

	-- Find the appropriate sub-derivation structure
	-- for a particular nonterminal index
	derivsofk :: Int -> Int
	derivsofk k = (k * nsubderivs) `div` nmemos

	-- Find the appropriate sub-derivation structure
	-- for a particular nonterminal name
	derivsof :: Identifier -> Int
	derivsof n = scan 0 nonterms where
		scan k ((n', t', r') : nts) | n' `elem` memos =
			if n' == n then derivsofk k
			else scan (k+1) nts
		scan k (_ : nts) = scan k nts
		scan k [] = error "derivsof: oops!"

	-- Names for types and identifiers relating to the derivs structures
	derivstype = upcase parsername ++ "Derivs"
	derivs2type j = upcase parsername ++ "Derivs" ++ show j
	dsubfuncname j = locase parsername ++ "Derivs" ++ show j
	dvsub j = locase parsername ++ "Sub" ++ show j
	dvsubname n = locase parsername ++ "Sub" ++ n


	-- Generate the top-level Derivs type declaration
	derivsdecl =
		"data " ++ derivstype ++ " = " ++ derivstype ++ " {\n" ++
		components 0 ++
		"\t" ++ dvname "Char" ++ " :: Result " ++ derivstype ++
							" Char,\n" ++
		"\t" ++ dvname "Pos" ++ " :: Pos\n" ++
		"}\n\n"

		where
		components j | j < nsubderivs =
			"\t" ++ dvsub j ++
			" :: " ++ derivs2type j ++ ",\n" ++
			components (j+1)

		components _ = []

	-- Generate the "instance Derivs" declaration
	derivsinstance =
		"instance Derivs " ++ derivstype ++ " where\n" ++
		"\tdvChar d = " ++ dvname "Char" ++ " d\n" ++
		"\tdvPos d = " ++ dvname "Pos" ++ " d\n" ++
		"\n"

	-- Generate the second-level Derivs type declarations
	derivs2decls j | j < nsubderivs =
		"data " ++ derivs2type j ++ " = " ++ derivs2type j ++
			" {" ++
		components True j 0 nonterms ++
		"}\n\n" ++
		derivs2decls (j+1)

		where
		components first j k ((name, typ, rule) : rest) 
			| name `elem` memos && derivsofk k == j =
			(if first then "\n\t" else ",\n\t") ++
			dvsubname name ++ " :: Result " ++ derivstype ++
			" (" ++ typ ++ ")" ++ components False j (k+1) rest

		components first j k ((name, typ, rule) : rest)
			| name `elem` memos =
			components first j (k+1) rest

		components first j k (_ : rest) =
			components first j k rest

		components first j k [] = ""

	derivs2decls _ = ""

	-- Generate the second-level accessor aliases
	aliases k ((n, t, r) : nts) | n `elem` memos =
		dvname n ++ " = " ++ dvsubname n ++ " . " ++
			dvsub (derivsofk k) ++ "\n" ++
		aliases (k+1) nts

	aliases k (_ : nts) =
		aliases k nts

	aliases k [] = ""

	-- Generate the top-level parse function
	parsefunc =
		pfuncname ++ " :: String -> String -> " ++ derivstype ++ "\n" ++
		pfuncname ++ " name text = " ++ dfuncname ++
			" (Pos name 1 1) text\n\n"

	-- Generate the top-level derivs-creation function
	derivsfunc i =
		ind i ++ dfuncname ++ " :: Pos -> String -> " ++
			derivstype ++ "\n" ++
		ind i ++ dfuncname ++ " pos text = dvs where\n" ++
		ind (i+1) ++ "dvs = " ++ derivstype ++ "\n" ++
		subcalls 0 ++
		ind (i+2) ++ "chr pos\n" ++
		ind (i+1) ++ "chr = case text of\n" ++
		ind (i+2) ++ "[] -> NoParse (eofError dvs)\n" ++
		ind (i+2) ++ "(c:cs) -> Parsed c (" ++ dfuncname ++
			" (nextPos pos c) cs) (nullError dvs)\n\n"

		where
		subcalls j | j < nsubderivs =
			ind (i+2) ++ "(" ++ dsubfuncname j ++ " dvs)\n" ++
			subcalls (j+1)
		subcalls _ = ""


	-- Generate the second-level derivs creation functions.
	-- Note: GHC's evaluation model makes it very important
	-- that these actually be separate functions!
	dsubfuncs j | j < nsubderivs =
		dsubfuncname j ++ " dvs = " ++ derivs2type j ++ "\n" ++
		parsercalls j 0 nonterms ++ "\n" ++
		dsubfuncs (j+1)

		where
		parsercalls j k ((name, typ, rule) : rest) | name `elem` memos =
			if derivsofk k == j
			then "\t(" ++ pname name ++ " dvs)\n" ++
				parsercalls j (k+1) rest
			else parsercalls j (k+1) rest

		parsercalls j k (_ : rest) =
			parsercalls j k rest

		parsercalls j k [] = ""

	dsubfuncs _ = ""



    ---------- Monadic parsing function code generation
    monadpfuncs i [] = ""
    monadpfuncs i ((name, typ, rule) : rest) =
	ind i ++ pname name ++ " :: " ++ derivstype ++
		" -> Result " ++ derivstype ++ " (" ++ typ ++ ")\n" ++
	ind i ++ "Parser " ++ pname name ++ " =\n" ++
	prule (i+1) rule ++ "\n" ++
	monadpfuncs i rest

	where

	-- Generate the code for a parse rule.
	prule i (RulePrim n) = ind i ++ "(Parser " ++ dvname n ++ ")\n"
	prule i (RuleChar c) = ind i ++ "(char " ++ show c ++ ")\n"
	prule i (RuleString s) = ind i ++ "(string " ++ show s ++ ")\n"

	prule i (RuleSeq matches prod) =
		ind i ++ "(do\n" ++ pseq matches where

		-- Match a rule without binding its semantic value
		pseq (MatchAnon r : ms) =
			prule (i+1) r ++ pseq ms

		-- Match a rule and give its semantic value the name 'id'
		pseq (MatchName r id : ms) =
			ind (i+1) ++ id ++ " <-\n" ++
			prule (i+2) r ++ pseq ms

		-- Match the semantic value of a rule
		-- against a Haskell pattern
		pseq (MatchPat r p : ms) =
			ind (i+1) ++ p ++ " <-\n" ++
			prule (i+2) r ++ pseq ms

		-- Match the semantic value of a rule against a string:
		-- typically used for keywords, operators, etc.
		pseq (MatchString r s : ms) =
			ind (i+1) ++ "satisfy\n" ++
			prule (i+2) r ++
			ind (i+2) ++ "((==) " ++ show s ++ ")\n" ++
			ind (i+2) ++ "<?!> " ++ show (show s) ++ "\n" ++
			pseq ms

		-- and-followed-by syntactic predicate
		pseq (MatchAnd r : ms) =
			ind (i+1) ++ "followedBy\n" ++
			prule (i+2) r ++ pseq ms

		-- not-followed-by syntactic predicate
		pseq (MatchNot r : ms) =
			ind (i+1) ++ "notFollowedBy\n" ++
			prule (i+2) r ++ pseq ms

		-- semantic predicate
		pseq (MatchPred pred : ms) =
			ind (i+1) ++ "if not (" ++ pred ++ ") then fail " ++
				show ("failed predicate " ++ show pred) ++
				" else return ()\n" ++ pseq ms

		-- end of sequence
		pseq [] =
			ind (i+1) ++ "return " ++ code prod ++ ")\n"
			where	code (ProdName id) = id
				code (ProdCode c) = "(" ++ c ++ ")"

	prule i (RuleAlt []) = error "prule: no alternatives!"
	prule i (RuleAlt [r]) = prule i r
	prule i (RuleAlt (r : rs)) =
		ind i ++ "(\n" ++ prule (i+1) r ++
		concat (map (\r -> ind i ++ " <|>\n" ++ prule (i+1) r) rs) ++
		ind i ++ " )\n"

	prule i (RuleOpt r) =
		ind i ++ "optional\n" ++ prule (i+1) r

	prule i (RuleStar r) =
		ind i ++ "many\n" ++ prule (i+1) r

	prule i (RulePlus r) =
		ind i ++ "many1\n" ++ prule (i+1) r



    ---------- Pattern-matching parsing function code generation
    patpfuncs i [] = ""
    patpfuncs i ((name, typ, rule) : rest) =
		ind i ++ pname name ++ " :: " ++ derivstype ++
			" -> Result " ++ derivstype ++ " (" ++ typ ++ ")\n" ++
		ind i ++ pname name ++ " d =\n" ++
		prule (i+1) "d" [] (\e -> "NoParse " ++ e) rule ++ "\n" ++
		patpfuncs i rest

	where

	-- Generate the code for a parse rule,
	-- directly generating a result on success
	-- but using a continutation to produce failure results.
	-- The failure continuation may be called multiple times.
	-- prule indent derivs-name error-names fail-cont rule
	prule i d es f (RulePrim n) =
		ind i ++ "case " ++ dvexp n d ++ " of\n" ++
		ind (i+1) ++ "Parsed " ++ v ++ " " ++ d' ++ " " ++ e' ++
			" -> Parsed " ++ v ++ " " ++ d' ++ " " ++
			join d es' ++ "\n" ++
		ind (i+1) ++ "NoParse " ++ e' ++ " -> " ++
			f (join d es') ++ "\n"

		where	v = valname i
			d' = dvsname i
			e' = errname i
			es' = e' : es

	prule i d es f (RuleChar c) =
		ind i ++ "case " ++ dvexp "Char" d ++ " of\n" ++
		ind (i+1) ++ "r @ (Parsed " ++ show c ++ " _ _) -> r\n" ++
		ind (i+1) ++ "_ -> " ++ f (join d es) ++ "\n"

	prule i d es f (RuleSeq [MatchName r n] (ProdName n')) | n' == n =
		prule i d es f r
	prule i d es f (RuleSeq matches prod) = pseq i d es matches

		where

		-- Special handling for characters in sequences,
		-- preventing unnecessary generation of intermediates.
		pseq i d es (MatchAnon (RuleChar c) : ms) =
			ind i ++ "case " ++ dvexp "Char" d ++ " of\n" ++
			ind (i+1) ++ "Parsed " ++ show c ++ " " ++ d' ++
				" _ ->\n" ++
			pseq (i+2) d' es ms ++
			ind (i+1) ++ "_ -> " ++ f (join d es) ++ "\n"

			where	d' = dvsname i

		-- Match a rule without binding its semantic value
		pseq i d es (MatchAnon r : ms) =
			pseq i d es (MatchName r "_" : ms)

		-- Match a rule and give its semantic value the name 'id'
		pseq i d es (MatchName r id : ms) =
			ind i ++ "case " ++ prexp i d r ++ " of\n" ++
			ind (i+1) ++ "Parsed " ++ id ++ " " ++ d' ++ " " ++
				e' ++ " ->\n" ++
			pseq (i+2) d' (e':es) ms ++
			ind (i+1) ++ "NoParse " ++ e' ++ " -> " ++
				f (join d (e':es)) ++ "\n" ++
			prexpdef i d r

			where	d' = dvsname i
				e' = errname i

		-- Match the semantic value of a rule
		-- against a Haskell pattern
		pseq i d es (MatchPat r p : ms) =
			ind i ++ "case " ++ prexp i d r ++ " of\n" ++
			ind (i+1) ++ "Parsed (" ++ p ++ ") " ++ d' ++ " " ++
				e' ++ " ->\n" ++
			pseq (i+2) d' (e':es) ms ++
			ind (i+1) ++ "Parsed _ _ _ -> " ++
				f (join d es) ++ "\n" ++
			ind (i+1) ++ "NoParse " ++ e' ++ " -> " ++
				f (join d (e':es)) ++ "\n" ++
			prexpdef i d r

			where	d' = dvsname i
				e' = errname i

		-- match the semantic value of a rule against a string:
		-- typically used for keywords, operators, etc.
		pseq i d es (MatchString r s : ms) =
			ind i ++ "case " ++ prexp i d r ++ " of\n" ++
			ind (i+1) ++ "Parsed " ++ show s ++ " " ++ d' ++ " " ++
				e' ++ " ->\n" ++
			pseq (i+2) d' (e':es) ms ++
			ind (i+1) ++ "_ -> " ++
				f (join d (exp:es)) ++ "\n" ++
			prexpdef i d r

			where	d' = dvsname i
				e' = errname i
				exp = "(ParseError (" ++ dvexp "Pos" d ++
					") [Expected " ++ show s ++ "])"

		-- and-followed-by syntactic predicate
		pseq i d es (MatchAnd r : ms) =
			ind i ++ "case " ++ prexp i d r ++ " of\n" ++
			ind (i+1) ++ "Parsed _ _ " ++ e' ++ " ->\n" ++
			pseq (i+2) d (e':es) ms ++
			ind (i+1) ++ "NoParse " ++ e' ++ " -> " ++
				f (join d (e':es)) ++ "\n" ++
			prexpdef i d r

			where	e' = errname i

		-- not-followed-by syntactic predicate
		pseq i d es (MatchNot r : ms) =
			ind i ++ "case " ++ prexp i d r ++ " of\n" ++
			ind (i+1) ++ "NoParse " ++ e' ++ " ->\n" ++
			pseq (i+2) d (e':es) ms ++
			ind (i+1) ++ "Parsed _ _ " ++ e' ++ " -> " ++
				f (join d (e':es)) ++ "\n" ++
			prexpdef i d r

			where	e' = errname i

		-- semantic predicate
		pseq i d es (MatchPred pred : ms) =
			ind i ++ "case (" ++ pred ++ ") of\n" ++
			ind (i+1) ++ "True ->\n" ++
			pseq (i+2) d es ms ++
			ind (i+1) ++ "False -> " ++ f (join d es) ++ "\n"

		-- end of sequence
		pseq i d es [] =
			ind i ++ "Parsed (" ++ code prod ++ ") " ++ d ++
				" " ++ join d es ++ "\n"

			where	code (ProdName id) = id
				code (ProdCode c) = c

	prule i d es f (RuleAlt []) = error "prule: no alternatives!"
	prule i d es f (RuleAlt [r]) = prule i d es f r
	prule i d es f (RuleAlt rs) =
		ind i ++ alt 1 (join d es) ++ " where\n" ++ ralt 1 rs
		where

		ralt j (r:rs) =
			ind (i+1) ++ alt j e' ++ " =\n" ++
				prule (i+2) d [e']
					(\e'' -> alt (j+1) e'') r ++
			ralt (j+1) rs
		ralt j [] =
			ind (i+1) ++ alt j e' ++ " = " ++ f e' ++ "\n"

		alt j e = "pappyAlt" ++ show i ++ "_" ++ show j ++ " " ++ e
		e' = errname i

	prule i d es f (RuleOpt r) =
		ind i ++ "case " ++ prexp i d r ++ " of\n" ++
		ind (i+1) ++ "Parsed " ++ v ++ " " ++ d' ++ " " ++ e' ++
			" -> " ++ "Parsed (Just " ++ v ++ ") " ++ d' ++
			" " ++ join d es' ++ "\n" ++
		ind (i+1) ++ "NoParse " ++ e' ++ " -> " ++
			"Parsed (Nothing) " ++ d ++ " " ++ join d es' ++
			"\n" ++
		prexpdef i d r

		where	v = valname i
			d' = dvsname i
			e' = errname i
			es' = e' : es

	-- Special low-level rule for single-choice alternation on characters.
	-- The left factoring code in the simplifier produces these.
	prule i d es f (RuleSwitchChar alts dfl) =
		ind i ++ "case " ++ dvexp "Char" d ++ " of\n" ++
		cases alts ++
		deflt dfl

		where
		cases ((c, r) : crs) =
			ind (i+1) ++ "Parsed " ++ show c ++ " " ++
				d' ++ " _ ->\n" ++
			prule (i+2) d' es f r ++
			cases crs
			where	d' = dvsname i
		cases [] = ""

		deflt (Just r) =
			ind (i+1) ++ "_ ->\n" ++
			prule (i+2) d es f r
		deflt (Nothing) =
			ind (i+1) ++ "_ -> " ++ f (join d es) ++ "\n"

	-- Override any errors produced by the associated rule
	-- with a given set of Expected strings.
	prule i d es f (RuleExpect r (s:ss)) = prule i d es f' r where
		f' _ = "ParseError (" ++ dvexp "Pos" d ++
			") [Expected " ++ show (show s) ++
			concat (map (\s -> ", Expected " ++ show (show s)) ss)
			++ "]\n"

	-- Produce a short expression for a rule.
	-- Any associated definition is produced by prexpdef below.
	prexp i d (RulePrim n) = dvexp n d
	prexp i d r = prexpname i

	prexpdef i d (RulePrim n) = ""
	prexpdef i d r = ind i ++ "where\n" ++
			ind (i+1) ++ prexpname i ++ " =\n" ++
				prule (i+2) d [] (\e -> "NoParse " ++ e) r

	prexpname i = "pappyResult" ++ show i

	-- Helper: generate expression to join a list of errors
	join d [] = "(ParseError (" ++ dvexp "Pos" d ++ ") [])"
	join d [e] = e
	join d [e,e'] = "(max " ++ e ++ " " ++ e' ++ ")"
	join d (e:es) = "(maximum [" ++ e ++
		concat (map (\e -> "," ++ e) es) ++ "])"



-- Helper: generate variable indentation for rule code
ind i = replicate (i*2) ' ' 

-- Convert the first letter of a string to uppercase or lowercase,
-- to produce Haskell type/constructor names or identifiers.
upcase (c:cs) = toUpper c : cs
locase (c:cs) = toLower c : cs

