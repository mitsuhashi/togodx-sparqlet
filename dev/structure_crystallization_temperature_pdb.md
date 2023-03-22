# PDBエントリを結晶化時の温度で分類（井手)

## Description
 
- Data sources
    - The temperature of crystal formation in the PDB entry
    - This item based on the data of January 20, 2021 of PDBj. 
        - The latest data can be obtained from the URL below. https://data.pdbj.org/pdbjplus/data/pdb/rdf/
- Query
    - Input
        - PDB ID
    - Output
        - The temperature of crystal formation in each PDB entry.

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`

```sparql
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
  SELECT ?value ?leaf ?label
         WHERE {
          ?leaf            rdf:type	                            pdbo:datablock .
          ?leaf            dc:title  	                        ?label .
          ?leaf            pdbo:has_exptl_crystal_growCategory	?crystal_growCategory .
          ?crystal_growCategory pdbo:has_exptl_crystal_grow	        ?crystal_grow .
          ?crystal_grow         pdbo:exptl_crystal_grow.temp	    ?temperature_str .
          BIND(Round(10*(xsd:decimal(?temperature_str))/10) AS ?value)
      }
```

## `results`

```javascript
({withAnnotation})=>{
  const idPrefix = "https://rdf.wwpdb.org/pdb/";
  
  return withAnnotation.results.bindings.map(d => {
    return {
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: Number(d.value.value),
      binLabel: d.value.value + " K"
    }
  });
}
```