# UniProt disorder_annotation（井手）* Disorderの長さをタンパク質全長における割合で示す。

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The disorder annotation in Region_Annotation of Uniprot

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `disorder`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
PREFIX faldo: <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?leaf ?label ?value ?seq_length ?begin_position #?range 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
  # VALUES ?leaf {upid:A6NJT0}
   ?leaf a up:Protein ;
            up:mnemonic ?label;
            up:annotation ?annotation .
   ?annotation a up:Region_Annotation;
               rdfs:comment "Disordered";
               up:range ?range .
   ?range rdf:type faldo:Region;
          faldo:begin/faldo:position ?begin_position;
          faldo:end/faldo:position ?end_position .
   ?range faldo:begin/faldo:reference/rdf:value ?seq_value .
   BIND (STRLEN(?seq_value) AS ?seq_length)
   BIND ((?end_position-?begin_position+1) AS ?value)
   ?leaf up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
ORDER BY ?leaf
#limit 50
```

## `withoutdisorder`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
PREFIX faldo: <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?leaf ?label ?value
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
         up:mnemonic ?label ;
   		 up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
   MINUS {
    ?leaf up:annotation ?annotation .
    ?annotation  a up:Region_Annotation ;
                 rdfs:comment "Disordered".
   }
  BIND ("0" AS ?value)
}
#limit 10
```

## `results`

```javascript
({disorder,withoutdisorder})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let tree = [];
  let id_match;
  let total_length = 0 ;
  disorder.results.bindings.map(d => {
    if (id_match == d.leaf.value){
      console.log(id_match);
      total_length = total_length + Number(d.value.value);
      tree.pop();
    }else{  
      id_match = d.leaf.value;
      total_length = Number(d.value.value);
    }
    const num = parseInt( 100* total_length/Number(d.seq_length.value));
    console.log(num);
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: num ,
      binId: num + 1 ,
      binLabel: num + "%"
    })
   });
   withoutdisorder.results.bindings.map(f => {
    tree.push({
      id: f.leaf.value.replace(idPrefix, ""),
      label: f.label.value,
      value: Number(f.value.value),
      binId: 1,
      binLabel: f.value.value
    })
   });
    return tree;
}
```