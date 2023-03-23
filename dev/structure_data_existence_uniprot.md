# UniProt PDB-existence classification（守屋）

## Description
 
- Data sources
    - Uniprot entries with links to PDB data entries
    - This item based on the data of March, 2021 of uniprot (human only).
- Query
    - Input
        - Existence (1: exists, 0 :not exists), uniprot id
    - Output
        - Uniprot entries are sorted by the presence or absence of a link to pdb.
        - If a uniprot id is entered, it returns whether pdb entry exists or not.

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?child ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?child a up:Protein ;
         up:mnemonic ?child_label ;
         up:organism taxon:9606 ;
         up:proteome ?proteome ;
         rdfs:seeAlso/up:database db:PDB .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}
```

## `withoutAnnotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?child ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?child a up:Protein ;
         up:mnemonic ?child_label ;
         up:organism taxon:9606 ;
         up:proteome ?proteome .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
  MINUS {
    ?child rdfs:seeAlso/up:database db:PDB . 
  }
}
```

## `return`
```javascript
({withAnnotation, withoutAnnotation})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  const withoutId = "unclassified";
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },{
      id: "1",
      label: "Proteins with structure data",
      parent: "root"
    },{
      id: withoutId,
      label: "Proteins without structure data",
      parent: "root"
    }
  ];  
  
  withAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      parent: "1",
      leaf: true
    })
  })
  withoutAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      parent: "unclassified",
      leaf: true
    })
  })
    
  return tree;
}
```