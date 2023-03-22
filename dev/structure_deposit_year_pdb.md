# PDB deposit year (井手）(2022/3/17追加)

## Description

- Data sources
    - Deposit year of the PDB entry.
    - This item based on the data of January 20, 2021 of PDBj. 
        - The latest data can be obtained from the URL below. https://data.pdbj.org/pdbjplus/data/pdb/rdf/
- Query
    - Input
        - PDB ID
    - Output
        - Deposit year

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`

```sparql
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>

#SELECT DISTINCT COUNT(?leaf) AS ?count ?year
SELECT DISTINCT ?leaf ?label ?year
#FROM <http://rdf.integbio.jp/dataset/pdbj>
WHERE {
  #VALUES ?entry { pdbr:1GOF }
  ?leaf rdf:type pdbo:datablock;
        dc:title ?label .
  ?leaf pdbo:has_pdbx_database_statusCategory/
        pdbo:has_pdbx_database_status/
        pdbo:pdbx_database_status.recvd_initial_deposition_date ?date .
  BIND(SUBSTR(?date,1,4) AS ?year)
}
ORDER by ?year
#limit 50

```

## `results`

```javascript
({withAnnotation})=>{
  const idPrefix = "http://rdf.wwpdb.org/pdb/";
  return withAnnotation.results.bindings.map(d => {
    return {
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.year.value),
      binId: Number(d.year.value),
      binLabel: d.year.value
    }
  });
}
```
