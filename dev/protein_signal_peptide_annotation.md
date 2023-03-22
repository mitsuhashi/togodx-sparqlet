# UniProt signal_peptide_annotation（井手）* 220119作業中

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The length of signal peptide annotation in Uniprot

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `withannotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX faldo:  <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?leaf ?label ?value 
#SELECT DISTINCT COUNT(?value) AS ?count ?value 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein;
         up:mnemonic ?label;
         up:annotation ?annotation;
         up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
   ?annotation a up:Signal_Peptide_Annotation;
               up:range/faldo:end/faldo:position ?value .
}
Order by ?value
limit 100
```

## `withoutannotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX faldo:  <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?leaf ?label ?value 
#SELECT DISTINCT COUNT(?value) AS ?count ?value 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein;
         up:mnemonic ?label;
         up:annotation ?annotation;
         up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
   MINUS {
    ?leaf up:annotation ?annotation .
    ?annotation  a up:Signal_Peptide_Annotation.
    }
   BIND ("0" AS ?value)
 }
Order by ?value
limit 100

```

## `binIDgen`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX faldo:  <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?length_label
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein;
         up:mnemonic ?label;
         up:annotation ?annotation;
         up:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))
   ?annotation a up:Signal_Peptide_Annotation;
               up:range/faldo:end/faldo:position ?length_label .
}
Order by ?length_label
```


## `results`

```javascript
({withannotation,withoutannotation,binIDgen})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let valrank = []; 
  let valarray=[[1,0]];
  let length = Object.keys(binIDgen.results.bindings).length;    //length of length_label
  let i =2;
  let tree = [];
  binIDgen.results.bindings.map(b => {							 //[binId, length_label]
    valrank=[ i, Number(b.length_label.value)];
    valarray.push(valrank);
    i++;
  });
  console.log(valarray);
  withannotation.results.bindings.map(d => {
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: binidgen(Number(d.value.value)),
      binLabel: d.value.value
    })
   });
   withoutannotation.results.bindings.map(f => {
    tree.push({
      id: f.leaf.value.replace(idPrefix, ""),
      label: f.label.value,
      value: Number(f.value.value),
      binId: binidgen(Number(f.value.value)),
      binLabel: f.value.value
    })
   });
    return tree;
    function binidgen(s) {                                   //generate binId from length_label value
    let target = valarray.filter( e => e[1] === s );
    return target[0][0];
    }
}
```