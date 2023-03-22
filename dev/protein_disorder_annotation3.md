# UniProt disorder_annotation（井手）* Disorderの長さを0,1-100,101-200,201-300,,,,でbinning

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

SELECT DISTINCT ?leaf ?label ?value
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
            up:mnemonic ?label;
            up:annotation ?annotation .
   ?annotation a up:Region_Annotation;
               rdfs:comment "Disordered";
               up:range ?range .
   ?range rdf:type faldo:Region;
          faldo:begin/faldo:position ?begin_position;
          faldo:end/faldo:position ?end_position .
   BIND ((?end_position-?begin_position) AS ?value)
   ?leaf up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
#limit 10
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
  disorder.results.bindings.map(d => {
    const num = parseInt(Number(d.value.value) / 100);
    //console.log(num);
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: num + 2,
      binLabel: d.value.value
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