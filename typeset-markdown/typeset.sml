(****
 * Read all text from standard input into a string
 *)
fun readAll () : string = (
  case (TextIO.inputLine TextIO.stdIn)
    of NONE => ""
     | SOME x => x ^ (readAll ())
  )
  handle _ => ""

(****
 * Decode the remaining possible URL-encoded characters:
 *    %3D -> =
 *    %26 -> &
 *    %25 -> %
 *)
val urlDecode : string -> string =
let
  fun urlDecode' (#"%" :: #"3" :: #"D" :: rest) = #"=" :: (urlDecode' rest)
    | urlDecode' (#"%" :: #"3" :: #"d" :: rest) = #"=" :: (urlDecode' rest)
    | urlDecode' (#"%" :: #"2" :: #"6" :: rest) = #"&" :: (urlDecode' rest)
    | urlDecode' (#"%" :: #"2" :: #"5" :: rest) = #"%" :: (urlDecode' rest)
    | urlDecode' (x :: (rest as _ :: _ :: _)) = x :: (urlDecode' rest)
    | urlDecode' (xs : char list) : char list = xs
in
  String.implode o urlDecode' o String.explode
end

(****
 * Parse variables into a list of URL-decoded (key, value) pairs
 *)
exception InputSyntaxError
fun parseVars (s : string) : (string * string) list =
let
  val assignments = String.tokens (fn c => c = #"&") s
  fun parseAssignment s' = (
    case String.fields (fn c => c = #"=") s'
      of [k, v] => (String.map Char.toLower (urlDecode k), urlDecode v)
       | _ => raise InputSyntaxError
  )
in
  List.map parseAssignment assignments
end

(****
 * Create a temporary directory. By default, the Basis library only supports
 * creating temporary files, so we use that functionality to create a temp file
 * in the right place and then replace it with a directory of similar name. 
 *)
fun tmpDir () = 
let
  val tmpFile = OS.FileSys.tmpName ()
  val _ = OS.FileSys.remove tmpFile
  val result = OS.Path.base tmpFile
  val _ = OS.FileSys.mkDir result
in
  result
end

(****
 * Convert markdown.md -> latex.tex in directory dir using Pandoc
 *)
fun runPandoc (dir : string) = OS.Process.system (
    "pandoc " ^ 
    "--template template.tex " ^
    "--from markdown \"" ^
    (OS.Path.joinDirFile {dir = dir, file = "markdown.md"}) ^ "\" " ^ 
    "--to latex " ^
    "--output \"" ^ (OS.Path.joinDirFile {dir = dir, file = "latex.tex"}) ^ "\" " ^ 
    " 1>&2" (* Redirect all output to stderr *)
)

(****
 * Run pdflatex
 *)
fun runLatex (dir : string) = OS.Process.system (
    "pdflatex " ^ 
    "-output-directory=\"" ^ dir ^ "\" \"" ^
    (OS.Path.joinDirFile {dir = dir, file = "latex.tex"}) ^ "\" " ^ 
    " 1>&2" (* Redirect all output to stderr *)
)

(****
 * Open a file and print it to stdout
 *)
fun readFile (path : string) : unit = 
let
  val instream = TextIO.openIn path
  val outstream = TextIO.stdOut
  val _ = TextIO.output (outstream, TextIO.inputAll instream)
  val _ = TextIO.closeIn instream
in
  ()
end

(****
 * Write the a string to a file 
 *)
fun writeFile (path : string) (data : string) : unit =
let
  val outstream = TextIO.openOut path
  val _ = TextIO.output (outstream, (CharVector.fromList o String.explode) data)
  val _ = TextIO.closeOut outstream
in
  ()
end

(****
 * Copy a file from the src path to the dst path
 *)
fun copyFile (src : string) (dst : string) : unit = 
let
  val instream = TextIO.openIn src
  val outstream = TextIO.openOut dst
  val _ = TextIO.output (outstream, TextIO.inputAll instream)
  val _ = TextIO.closeIn instream
  val _ = TextIO.closeOut outstream
in
  ()
end

(****
 * Get the value corresponding to the key "markdown" from the input form
 *)
fun getMarkdown (("markdown", markdown) :: _) = markdown
  | getMarkdown (_ :: rest) = getMarkdown rest
  | getMarkdown [] = ""

(****
 * Main function
 *)
fun main () = 
let
  val markdown = (getMarkdown o parseVars o readAll) ()
  val dir = tmpDir ()
  val _ = (
    copyFile 
    "jstrieb-doc.cls" 
    (OS.Path.joinDirFile {dir = dir, file = "jstrieb-doc.cls"})
  )
  val _ = 
    writeFile (OS.Path.joinDirFile {dir = dir, file = "markdown.md"}) markdown
  val _ = runPandoc dir
  val _ = runLatex dir
  val _ = readFile (OS.Path.joinDirFile {dir = dir, file = "latex.pdf"})
in
  ()
end

val _ = main ()
