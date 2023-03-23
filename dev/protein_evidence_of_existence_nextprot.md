# neXtProt protein-existence-level classification（守屋）

## Description

- Data sources
    - [neXtProt](https://www.nextprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - Protein existence obtained

## Endpoint 
{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX : <http://nextprot.org/rdf#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX core: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?child ?parent ?child_label ?parent_label
FROM <http://rdf.integbio.jp/dataset/togosite/nextprot>
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?child core:mnemonic ?child_label ;
         ^skos:exactMatch/:existence [
           :level ?parent ;
           rdfs:label ?parent_label
  ] .
}
```

## `return`
```javascript
({data, allLeaf}) => {
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  const withoutId = "without_annotation";
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];

  let edge = {};
  // アノテーション関係
  data.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value
    })
    // root との親子関係を追加
    if (!edge[d.parent.value]) {
      edge[d.parent.value] = true;
      tree.push({     
        id: d.parent.value,
        label: d.parent_label.value,
        leaf: false,
        parent: "root"
      })
    }
  });
  
  return tree;
}
```