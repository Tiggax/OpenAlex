export module author



export def load [
    folder: path  # the folder containing the parsed data
    --database(-d): path = ./database # the location of the database
] {

    let files = glob ($folder | path join "**/*.ttl")
    let total = ($files | length)

    print $"found (ansi blue)($total)(ansi reset) files. Starting..."

    try {
        print -en (ansi cursor_off)
        let initial = render-bar 0 $total --width 30
        let height = $initial | lines | length | $in - 1 

        $initial | print -ne

        $files
        | enumerate
        | each {|file|
            oxigraph load --location database --format trig -f $file.item
            let path = $file.item | path split | last 3

            let name = (ansi green)($path.0)(ansi yellow)(">")(ansi blue)($path.1)(ansi reset)
            print -ne $"    Parsed ($name)"
            print -ne ("" | fill -a l -w $height -c (ansi cursor_up)) "\r" (render-bar $file.index  $total --width 30)
        }
        | ignore
    } catch {
        ignore
    }
    print -en (ansi cursor_on)

    

}

export def parse [
folder: path # The path to the target folder : example ..*/authors
handler: closure # the parse handler on the data
--out(-o): path = output # the output folder to parse into
] {

    let manifest = open ($folder | path join manifest)
    | from json

    if not ($out | path exists) {
        print $"Target dir not found. Creating `($out)`..."
        mkdir $out
    }

    ls $folder
    | where type == "dir"
    | upsert file {|n| 
        $n.name
        | path parse 
        | get stem
    }
    | select name file
    | par-each -t 20 {|instance|

        print $"Parsing in: `($instance.file)`..."
        
        let out_dir = $out | path join ($folder | path split | last ) | path join $instance.file
        
        if not ($out_dir | path exists) {
            mkdir $out_dir
        }

        ls $instance.name
        | each {|file|
            print $"parsing file `($file.name)`"
            
            let save_file = (
                $out_dir 
                | path join (
                    $file.name 
                    | path parse 
                    | get stem 
                    | append ".ttl"
                    | str join ""
                )
            )

            gunzip -c $file.name
            | lines
            | each {from json}
            | do $handler
            | save -f $save_file

            print $"saved in: `($save_file)`"
        }

    }



}


def render-bar [
    fill: int
    total: int
    --width (-w): int = 20
    --full (-f): string = "█"
    --empty (-e): string = " "
]: nothing -> string {
    let filled_width = $fill / $total * $width | into int
    let num_len = $total | into string | str length
    let numeric = $"($fill | fill -a right -w $num_len)/($total)"
    let bar = "" | fill -w $filled_width -c $full | fill -a left -w $width -c $empty
    {$numeric: $bar} | table -e
}
