# UniProt molecular mass distribution（守屋）

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - Molecular mass (kDa) range

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?leaf ?label ?value        
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?leaf a up:Protein ;
         up:mnemonic ?label ;
         up:organism taxon:9606 ;
         up:proteome ?proteome ;
         up:sequence/up:mass ?value .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}
```

## `return`
```javascript
({data})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  
  return data.results.bindings.map(d => {
    const num = parseInt(Number(d.value.value) / 10000);
    const bin_id = (num * 10) + "-" + ((num + 1) * 10);
    return {
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: num + 1,
      binLabel: bin_id + " kDa"
    }
  })
}
```