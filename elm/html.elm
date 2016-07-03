import Html exposing (..)
import Html.Attributes exposing (..)

tableStyle = 
  style
    [ ("border", "1")
    ]


main =
 main' []
  [ header [] [ text "This is a header", hr[][] ]
  , body   [] [ maintable ]
  , footer [] [ hr[][], a [href "html.elm"] [ text "elm source file for this page" ] ] 
  ]
  
maintable =
  table [ tableStyle ]
    [ tbody []
      [ tr []
        [ td [] [ headers ]
        , td [] [ grouping ]
        ]
      , tr []
        [ td [] [ lists ]
        , td [] [ texttags ]
        ]
      ]
    ]

texttag =  text "Hello, World!"

headers = div []
  [ h1 [] [ text "Level 1 Header" ]
  , h2 [] [ text "Level 2 Header" ]
  , h3 [] [ text "Level 3 Header" ]
  , h4 [] [ text "Level 4 Header" ]
  , h5 [] [ text "Level 5 Header" ]
  , h6 [] [ text "Level 6 Header" ]
  ] 

lists = div []
 [
   ol [] 
     [ li [] [ text "first ordered item" ]
     , li [] [ text "second ordered item" ]
     , li [] [ text "third ordered item" ]
     ]
   ,
   ul [] 
     [ li [] [ text "first unordered item" ]
     , li [] [ text "second unordered item" ]
     , li [] [ text "third unordered item" ]
     ]
   ,
   dl [] 
     [ dt [] [ text "some term" ], dd [] [ text "and its definition" ]
     , dt [] [ text "another term" ], dd [] [ text "and its" ]
     ]
 ]

grouping = div []
  [ p [] [ text "This sentence is a complete paragraph" ]
  , p [] [ text( "And these sentences make up a second paragraph.  " ++
                  "(Me, too)  " ++ 
                   " and me") ]
  , blockquote [] [ text "This one is a blocked quote." ]
  , pre [] [ text ("This text    ----    is pre-formatted,   
" ++               "and followed by a horizontal line") ]
  , hr [][] 
  ]

texttags = div []
  [ p [] 
    [ text "This is a sentence.  " 
    , text "This is another.  " 
    , code [] [ text "This one is actually code.  " ]
    , text "This one is ", em [] [ text "emphatic.  " ]
    , text "This one is ", strong [] [ text "strong.  " ]
    , text "This one is ", i [] [ text "italic.  " ]
    , text "This one is ", b [] [ text "bold.  " ]
    , text "This one is ", u [] [ text "underlined" ], text ".  "
    , text "This is a ", sup [] [ text "superscript.  " ]
    , text "This is a ", sub [] [ text "subscript.  " ]
    ]
  ]
