# UniProt interacting human proteins (IntAct) count distribution（守屋）

- human protein - human protein のみ
  - endpoint に human しか入っていないため
  - 本家 UniProt には virus protein との相互作用もあるが、RDF が種に依存してるので TogoSite endpoint では相手が取れない

## Description

- Data sources
    - The number of interacting proteins from UniProt
    - This item based on the data of March, 2021 of UniProt (human only).
- Query
    - Input
        - UniProt ID, Number of interacting human proteins
    - Output
        - The number of interacting human proteins from UniProt
        - If a UniProt ID is entered, it returns the number of interacting proteins

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?leaf ?label ?value
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  # union non-self-, self-, non-
  {
    SELECT ?leaf ?label (COUNT (DISTINCT ?target) AS ?value)
    WHERE {
      { # non-self-interaction
        ?leaf a up:Protein ;
              up:mnemonic ?label ;
              up:organism taxon:9606 ;
              up:proteome ?proteome ;
              up:interaction ?interaction .
        ?interaction a up:Non_Self_Interaction ;  # non self
                     ^up:interaction ?target .
        FILTER(REGEX(STR(?proteome), "UP000005640"))
        FILTER (?target != ?leaf)
      } UNION { # self-interaction
        ?leaf a up:Protein ;
              up:mnemonic ?label ;
              up:organism taxon:9606 ;
              up:proteome ?proteome ;
              up:interaction ?interaction .
        ?interaction a up:Self_Interaction ;  # self
                     ^up:interaction ?target .
        FILTER(REGEX(STR(?proteome), "UP000005640"))
        FILTER (?target = ?leaf)
      } 
    }
  } UNION { # non-interaction
    SELECT ?leaf ?label ?value
    WHERE {
      ?leaf a up:Protein ;
             up:mnemonic ?label ;
             up:organism taxon:9606 ;
             up:proteome ?proteome .
      FILTER(REGEX(STR(?proteome), "UP000005640"))    
      MINUS { ?leaf up:interaction [] . }   
      BIND (0 AS ?value)
    }
  }
}
```

## `results`

```javascript
({data})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  
  return data.results.bindings.map(d => {
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