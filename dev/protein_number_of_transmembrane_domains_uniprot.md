# UniProt transmembrane-domain count distribution（井手, 守屋）

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The number of transmembrane site

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`
```sparql
PREFIX core: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?leaf ?label (COUNT (DISTINCT ?annotation) AS ?value)
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {    
  ?leaf a core:Protein ;
        core:mnemonic ?label ;
  		core:organism taxon:9606 ;
  		core:proteome ?proteome ;
  		core:annotation ?annotation .       
  		?annotation a core:Transmembrane_Annotation .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}   
```

## `withoutAnnotation`
```sparql
PREFIX core: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?leaf ?label ?value
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?leaf a core:Protein ;
        core:mnemonic ?label ;
        core:organism taxon:9606 ;
        core:proteome ?proteome .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
  MINUS {
    ?leaf core:annotation [ a core:Transmembrane_Annotation ] .
  }
  BIND ("0" AS ?value)
}
```

## `results`

```javascript
({withAnnotation, withoutAnnotation})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  
  return withAnnotation.results.bindings.concat(withoutAnnotation.results.bindings).map(d => {
    return {
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: Number(d.value.value) + 1,
      binLabel: d.value.value
    }
  });
}
```