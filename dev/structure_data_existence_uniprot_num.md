# UniProt PDB-existence classification（守屋）何個のPDBエントリーに結びついているかを提示

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
SELECT DISTINCT COUNT(?pdb_link) AS ?count ?child ?child_label
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
  ?child a up:Protein ;
         up:mnemonic ?child_label;
         up:organism taxon:9606;
         up:proteome ?proteome;
         rdfs:seeAlso ?pdb_link .
  ?pdb_link up:database db:PDB .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
 }
ORDER BY DESC(?count)
#limit 10
```

## `binIDgen`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX db: <http://purl.uniprot.org/database/>
SELECT DISTINCT ?count_label 
{SELECT DISTINCT  COUNT(?pdb_link) AS ?count_label ?child
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
  ?child a up:Protein ;
         up:organism taxon:9606;
         up:proteome ?proteome;
         rdfs:seeAlso ?pdb_link .
  ?pdb_link up:database db:PDB .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
 }}
ORDER BY DESC(?count_label)
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
#limit 5
```

## `return`
```javascript
({withAnnotation, binIDgen, withoutAnnotation})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  const withoutId = "unclassified";
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },{
      id: withoutId,
      label: "Proteins without structure data",
      parent: "root"
    }
  ];  

  binIDgen.results.bindings.map(d => {
    tree.push({
      id: d.count_label.value,
      label: d.count_label.value + " Link(s)",
      parent: "root"
    })
  })
  
  withAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      parent: d.count.value,
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