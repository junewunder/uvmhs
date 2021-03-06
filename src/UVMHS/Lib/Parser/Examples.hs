module UVMHS.Lib.Parser.Examples where

import UVMHS.Core
import UVMHS.Lib.Pretty
import UVMHS.Lib.Parser.Core
import UVMHS.Lib.Parser.ParserInput
import UVMHS.Lib.Parser.Regex
import UVMHS.Lib.Parser.CParser

testParsingSmall ∷ IO ()
testParsingSmall = parseIOMain parser input
  where
    parser = cpWord "xyzxyz"
    input = tokens "xyzxycxyz"

testParsingMultiline ∷ IO ()
testParsingMultiline = parseIOMain parser input
  where
    parser = exec $ inbetween (void $ cpWord "\n") $ list $ repeatI 7 $ \ n → cpNewContext "line" $ void $ cpWord ("xyz" ⧺ show𝕊 n)
    input = tokens "xyz0\nxyz1\nxyz2\nxyc3\nxyz4\nxyz5\nxyz6\n"

testParsingBranching ∷ IO ()
testParsingBranching = parseIOMain parser input
  where
    parser ∷ CParser ℂ 𝕊
    parser = tries
      [ cpNewContext "XXX*" $ tries
          [ cpRender (formats [FG pink]) $ cpWord "xxxy"
          , cpRender (formats [FG pink]) $ cpWord "xxxz"
          ]
      , cpNewContext "XXXZ" $ do
          x ← cpErr "XX" $ cpRender (formats [FG blue]) $ cpWord "xx"
          y ← cpErr "XZ" $ cpRender (formats [FG green]) $ cpWord "xz"
          return $ x ⧺ y
      , cpNewContext "XXZZ" $ cpWord "xxzz"
      , cpNewContext "XXXAorB" $ cpRender (formats [FG teal]) $ do
          x ← cpWord "xxx"
          y ← single ^$ tries
            [ toCParser $ pToken 'a'
            , toCParser $ pToken 'b'
            ]
          return $ x ⧺ y
      ]
    input ∷ 𝕍 (ParserToken ℂ)
    input = tokens "xxxx"
    
-- testParsingAmbiguity ∷ IO ()
-- testParsingAmbiguity = parseIOMain parser input
--   where
--     parser = concat ^$ pOneOrMore $ tries 
--       [ ppFG yellow ∘ ppString ∘ single ^$ pToken 'y'
--       , ppFG green ∘ ppString ∘ single ^$ pToken 'x'
--       , ppFG blue ∘ ppString ^$ pWord "xx" 
--       ]
--     input = tokens "xxx"

testParsingGreedy ∷ IO ()
testParsingGreedy = parseIOMain parser input
  where
    parser = concat ^$ cpOneOrMore $ tries 
      [ ppFG yellow ∘ ppString ∘ single ^$ cpRender (formats [FG yellow]) $ toCParser $ pToken 'y'
      , ppFG green ∘ ppString ∘ single ^$ cpRender (formats [FG green]) $ toCParser $ pToken 'x'
      , ppFG blue ∘ ppString ^$ cpRender (formats [FG yellow]) $ cpWord "xx" 
      ]
    input = tokens "xxx"

testParsingGreedyAmbiguity ∷ IO ()
testParsingGreedyAmbiguity = parseIOMain parser input
  where
    parser = concat ^$ cpOneOrMore $ tries 
      [ ppFG yellow ∘ ppString ∘ single ^$ cpRender (formats [FG yellow]) $ toCParser $ pToken 'y'
      , tries
          [ ppFG blue ∘ ppString ^$ cpRender (formats [FG blue]) $ cpWord "x" 
          , ppFG pink ∘ ppString ^$ cpRender (formats [FG pink]) $ cpWord "xx" 
          ]
      , ppFG green ∘ ppString ∘ single ^$ cpRender (formats [FG green]) $ toCParser $ pToken 'x'
      ]
    input = tokens "xxx"

testParsingSuccess ∷ IO ()
testParsingSuccess = parseIOMain parser input
  where
    parser = concat ^$ cpOneOrMore $ tries 
      [ cpRender (formats [FG green]) $ cpWord "xx"
      , cpRender (formats [FG blue]) $ cpWord "yy"
      ]
    input = tokens "xxxxyyxxyy"

testParsingErrorNewline ∷ IO ()
testParsingErrorNewline = parseIOMain (string ^$ cpMany $ toCParser $ pToken 'x') $ tokens "xxx\nx"

testParsingErrorEof ∷ IO ()
testParsingErrorEof = parseIOMain (exec $ repeat 3 $ cpToken 'x') $ tokens "xx"

testTokenizeSimple ∷ IO ()
testTokenizeSimple = 
  let rgx = lWord "x" ▷ oepsRegex ()
      dfa = compileRegex rgx
  in tokenizeIOMain (Lexer (const dfa) (const ∘ ((:*) False) ∘ string) ()) $ tokens "xxx"

testTokenize ∷ IO ()
testTokenize = 
  let rgx = concat [lWord "x",lWord "xy",lWord "y"] ▷ oepsRegex ()
      dfa = compileRegex rgx
  in tokenizeIOMain (Lexer (const dfa) (const ∘ ((:*) False) ∘ string) ()) $ tokens "xxyxyxyxyxxyy"

testTokenizeFailure1 ∷ IO ()
testTokenizeFailure1 = 
  let rgx = concat
        [ lWord "x" ▷ fepsRegex (formats [FG green]) ▷ lepsRegex (𝕟64 2)
        , lWord "x" ▷ fepsRegex (formats [FG yellow]) ▷ lepsRegex (𝕟64 1)
        , lWord "xx" ▷ fepsRegex (formats [FG blue])
        , lWord "xy" ▷ fepsRegex (formats [FG teal])
        , lWord "xz" ▷ fepsRegex (formats [FG pink])
        ] ▷ oepsRegex ()
      dfa = compileRegex rgx
  in tokenizeIOMain (Lexer (const dfa) (const ∘ ((:*) False) ∘ string) ()) $ tokens "xxxxy"

testTokenizeFailure2 ∷ IO ()
testTokenizeFailure2 = 
  let rgx = concat
        [ lWord "x" ▷ fepsRegex (formats [FG green]) ▷ lepsRegex (𝕟64 2)
        , lWord "x" ▷ fepsRegex (formats [FG yellow]) ▷ lepsRegex (𝕟64 1)
        , lWord "xx" ▷ fepsRegex (formats [FG blue])
        , lWord "xy" ▷ fepsRegex (formats [FG teal])
        , lWord "xz" ▷ fepsRegex (formats [FG pink])
        ] ▷ oepsRegex ()
      dfa = compileRegex rgx
  in tokenizeIOMain (Lexer (const dfa) (const ∘ ((:*) False) ∘ string) ()) $ tokens "xxxyxxxzxc"
