import Html exposing (..)
import Html.Attributes exposing (..)

main =
 main' []
  [ header [] [ finalheader ]
  , body   [] [ finalbody ]
  , footer [] [ finalfooter ] 
  ]

finalheader = 
  section []
   [ h1 [] [ text "Ali Corbin" ]
   , nav []
     [ a [href "html.elm"] [ text "One" ], text " "
     , a [href "html.elm"] [ text "Two" ], text " "
     , a [href "html.elm"] [ text "Three" ], text " "
     , a [href "html.elm"] [ text "Forty-Two" ]
     ]  
   ]

finalbody =
  section [ ]
    [ h2 [] [ text "Favorite Foods" ]
    , ul [] 
      [ li [] [ text "Marionberries" ]
      , li [] [ text "Oatmeal" ]
      , li [] [ text "Salmon" ]
      , li [] [ text "Peanut Butter" ]
      ]

    , h2 [] [ text "Achievements" ]
    , text "Progress in this course (100%)"
    , meter [ value "1" ] []
    , br [] []
    , text "Progress in the Specialization capstone (20%)"
    , meter [ value "0.20" ] [ ]
    , br [] []
    , text "Progress in life goals (62%)"
    , meter [ value "0.62" ] []
    , br [] []

    , h2 [] [ text "More About Me" ]
    , details []
      [ summary [] [ text "My Childhood" ]
      , text "Grew up back east." 
      ]
    ]

finalfooter =
  section []
   [ img [ src "./newlogo.png", alt "" ] []
   , text( "This page was created by Ali Corbin & Colleen van Lent." ++
                  "To learn more about web design, visit ")
   , a [ href "http://www.intro-webdesign.com/" ] [ text "Intro to Web Design" ]
   ]
