# createTiles.nim
# Create however many tiles of the requested geometry from the daily numbers
import system
import os

var status: bool
type Flavors = array[3,string]
let flavor: Flavors = ["orig", "negate", "normalize" ]

if paramCount() != 1:
  echo "createTiles <geometry>"
  quit(QuitFailure)

let geom = paramStr(1)
status = existsOrCreateDir( geom )
for dir in flavor:
  status = existsOrCreateDir( geom & "/" & dir )
  

for infile in walkFiles "./daily-numbers/*.gif":
  let pathSplit = splitPath( infile )
  let fileSplit = splitFile( pathSplit.tail  )
  let number = fileSplit.name

  for dir in flavor:
    let outfile = geom & "/" & dir & "/" & number & ".png"
    if false == fileExists( outfile ):
      #echo "Need to create", outfile
      var option = ""
      case dir
      of "negate": option = " -" & dir
      else: discard
      let command = "convert " & infile & " -resize " & geom & option & " " & outfile
      var err: int = execShellCmd( command )
#
#    #mean=$( printf "%.0f" $( identify -format "%[mean]" $outfileorig ) );
#    #rgb=$( convert $outfileorig -format '#%[hex:u]' info:- )
#    #hsl=$( convert $outfileorig -scale 1x1 -colorspace HSL -depth 16 txt:- | grep -o "hsl(.*" | tr [:punct:] ' ' )
#    #echo $hsl ./GEOM/orig/$number.png >> ./means
#
#done
