# UniProt disorder_annotation_test（井手）* Disorderの配列取得(テスト用) 

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

SELECT DISTINCT ?leaf ?label ?Diorder_seq ?value ?seq_length ?begin_position #?range 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   #VALUES ?leaf {upid:A6NJT0}
   ?leaf a up:Protein ;
            up:mnemonic ?label;
            up:annotation ?annotation;
            up:reviewed 1 .
   ?annotation a up:Region_Annotation;
               rdfs:comment "Disordered";
               up:range ?range .
   ?range rdf:type faldo:Region;
          faldo:begin/faldo:position ?begin_position;
          faldo:end/faldo:position ?end_position .
   ?range faldo:begin/faldo:reference/rdf:value ?seq_value .
   BIND (STRLEN(?seq_value) AS ?seq_length)
   BIND ((?end_position-?begin_position+1) AS ?value)
   BIND ((SUBSTR(?seq_value,?begin_position,?value)) AS ?Diorder_seq )
   ?leaf up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
#ORDER BY ?leaf  #Order入れると、Sortの上限を超えるらしい。
limit 10
```

## `results`

```javascript
({disorder})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let tree = [];
  let id_match;
  let total_length = 0 ;
  disorder.results.bindings.map(d => {
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      length: d.value.value,
      disorder_seq: d.Diorder_seq.value 
    })
   });
    return tree;
}
```