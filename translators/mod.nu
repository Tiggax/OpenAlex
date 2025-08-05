export def load [

] {

}

def parse [
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
        $n 
        | path parse 
        | get stem
    }
    | select name file
    | par-each {|instance|

    ls $instance.name
    | each {|file|
        open $file
        | lines
        | each {from json}
        | do $handler


    }


    }



}
