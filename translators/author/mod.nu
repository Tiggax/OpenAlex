export def parse [] {
    let input = $in
    let prefix = r#'@prefix aa: <https://openalex.org/> .
@prefix ex: <http://example.org/ontology#> .
@prefix oa: <https://db.famnit.upr.si/scheme/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .'#

    $input
    | each {|obj|

        $'<($obj.id)>
    oa:orcid ($obj.orcid);
    oa:display_name "($obj.display_name)";'
        | (
            pipe-if 
            ($obj.display_name_alternatives | is-not-empty) 
            {append (
                $obj.display_name_alternatives
                | str join "\" \""
                | $"    oa:display_name_alternatives \(\"($in)\"\);"
            )}
        )
        | append $'    oa:works_count "($obj.works_count)"^^xsd:integer;'
        | append $'    oa:cited_by_count "($obj.cited_by_count)"^^xsd:integer;'
        | append $'    oa:most_cited_work "($obj.most_cited_work)";'
        | append $'    oa:summary_stats (summary $obj.summary_stats)'
        | (
            pipe-if 
            ($obj.last_known_institution | is-not-empty)
            {append $'    oa:last_known_institutions <($obj.last_known_institution | get id | str join "> <")>;'}
        )
        | (
            pipe-if
            ($obj.counts_by_year | is-not-empty)
            {append $"    oa:counts_by_year \(\n($obj.counts_by_year | each {counts} | str join '')\n    \);"}
        )
        | append $"    oa:works_api_url <($obj.works_api_url)>;"
        | append $"    oa:updated_date \"($obj.updated_date)\"^^xsd:date;"
        | append $"    oa:created_date \"($obj.updated_date)\"^^xsd:date;"
        | append $"    oa:updated \"($obj.updated_date)\"^^xsd:date;"
        | append '.'
        | str join "\n"

    }
    | prepend $prefix
    | str join "\n"


}

def summary [
    sum
] {
    $'[
        a oa:Summary;
        oa:2yr_mean_citedness "($sum.2yr_mean_citedness)"^^xsd:integer;
        oa:h_index "($sum.h_index)"^^xsd:integer;
        oa:i10_index "($sum.i10_index)"^^xsd:integer;
        oa:oa_percent "($sum.oa_percent)"^^xsd:integer;
        oa:works_count "($sum.works_count)"^^xsd:integer;
        oa:cited_by_count "($sum.cited_by_count)"^^xsd:integer;
        oa:2yr_works_count "($sum.2yr_works_count)"^^xsd:integer;
        oa:2yr_cited_by_count "($sum.2yr_cited_by_count)"^^xsd:integer;
        oa:2yr_i10_index "($sum.2yr_i10_index)"^^xsd:integer;
        oa:2yr_h_index "($sum.2yr_h_index)"^^xsd:integer;
    ];'
}

def counts [
] {
    let counts = $in

    $'        [
            a oa:CountsByYear;
            oa:year "($counts.year)"^^xsd:integer;
            oa:works_count "($counts.works_count)"^^xsd:integer;
            oa:oa_works_count "($counts.cited_by_count)"^^xsd:integer;
            oa:cited_by_count "($counts.cited_by_count)"^^xsd:integer;
        ]'
}

def pipe-if [
    case
    value
] {
    if ($case) {
        $in
        | do $value
    } else {
        $in
    }
}