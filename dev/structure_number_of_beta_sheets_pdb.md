# PDB beta_sheet distribution （井手, 守屋) (10/27-pdb更新版)

## Description

- Data sources
    - The number of beta-sheets recorded in the PDB entry.
    - This item based on the data of January 20, 2021 of PDBj. 
        - The latest data can be obtained from the URL below. https://data.pdbj.org/pdbjplus/data/pdb/rdf/
- Query
    - Input
        - PDB ID
    - Output
        - The beta-sheets value contained in each entry.
## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`

```sparql
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>

SELECT DISTINCT ?leaf ?label (COUNT(?sheet) AS ?value) 
WHERE {
      ?leaf  a pdbo:datablock ;
  			 pdbo:has_struct_sheetCategory ?sheet .
      ?sheet pdbo:has_struct_sheet ?sheet_each .
      ?leaf  dc:title ?label .  
      {
        SELECT DISTINCT ?leaf {
           ?leaf ( (pdbo:has_entity_src_genCategory /
                       pdbo:has_entity_src_gen ) | 
                      (pdbo:has_entity_src_natCategory /
                       pdbo:has_entity_src_nat ) )
                  / rdfs:seeAlso <http://identifiers.org/taxonomy/9606> .  
        }
      }
}

```

## `withoutAnnotation`
- ヘリックスを持たないタンパク質の数
```sparql
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 
    SELECT DISTINCT ?leaf ?label ?value
    WHERE {
      ?leaf a pdbo:datablock ;
                 dc:title ?label .
      MINUS {?leaf pdbo:has_struct_sheetCategory ?sheet. }
      {
        SELECT DISTINCT ?leaf {
           ?leaf ( (pdbo:has_entity_src_genCategory /
                       pdbo:has_entity_src_gen ) | 
                      (pdbo:has_entity_src_natCategory /
                       pdbo:has_entity_src_nat ) )
                  / rdfs:seeAlso <http://identifiers.org/taxonomy/9606> .  
        }
      }
      BIND ("0" AS ?value)
      }

```

## `results`

```javascript
({withAnnotation, withoutAnnotation})=>{
  const idPrefix = "https://rdf.wwpdb.org/pdb/";
  
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