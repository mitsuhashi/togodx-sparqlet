# UniProtKB section (SwissProt, TrEMBL) in the UniProt reference proteome（守屋）

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - Reviewd flag (Swiss-Prot/TrEMBL)

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?child ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?child a up:Protein ;
         up:mnemonic ?child_label ;
         up:proteome ?proteome ;
         up:reviewed 1 .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}
```

## `withoutAnnotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?leaf ?leaf_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?leaf a up:Protein ;
        up:mnemonic ?leaf_label ;
        up:proteome ?proteome .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
  MINUS { ?leaf up:reviewed 1 .}
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
      root: true
    },{
      id: "reviewed",
      label: "Swiss-Prot",
      parent: "root"
    },{
      id: withoutId,
      label: "TrEMBL",
      parent: "root"
    }
  ];

  // アノテーション関係
  withAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      leaf: true,
      parent: "reviewed"
    })
  });
  // アノテーション無し要素
  withoutAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.leaf_label.value,
      leaf: true,
      parent: withoutId
    });
  })
  
  return tree;
}
```