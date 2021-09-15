# ChEBI reactome-pathway classification（守屋）

- アノテーション無しは取得していない
  - "パスウェイに乗っていない化合物" を考慮することは難しいため
  
## Description

- Data sources
    - Reactome-classified pathways for each chemical compound
    - This item based on the data of  Reactome Version 71 (02, December 2019).
        - The latest data can be obtained from the URL below. https://reactome.org/download-data
- Query
    - Input
        - Reactome ID , ChEBI ID
    - Output
        - The number of ChEBI entries included in each pathways in Reactome
        - If a ChEBI id is entered, it returns the pathway to which the chemical compound belongs

## Endpoint
https://integbio.jp/togosite/sparql

## `leaf`
- pathway と UniProt のアノテーション関係
- 産物と制御
  - 制御: reaction ^biopax:controlled/biopax:controller control-component
  - 産物: reaction biopax:left|biopax:right|biopax:product product-component
```sparql
PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
SELECT DISTINCT ?parent ?child ?parent_label ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/reactome>
FROM <http://rdf.integbio.jp/dataset/togosite/chebi>
WHERE {
  ?top_path a biopax:Pathway ;
            biopax:organism ?org .
  ?org biopax:name "Homo sapiens"^^xsd:string .
  MINUS { [] biopax:pathwayComponent ?top_path . }
  ?top_path biopax:pathwayComponent* ?path .
  ?path a biopax:Pathway ;
        biopax:displayName ?parent_label ;
        biopax:xref [
          biopax:db "Reactome"^^xsd:string ;
          biopax:id ?parent ;
        ] ;
        biopax:pathwayComponent ?reaction .
  ?reaction a biopax:BiochemicalReaction .
  ?reaction biopax:left|biopax:right|biopax:product|^biopax:controlled/biopax:controller ?component .
  ?component (biopax:memberPhysicalEntity|biopax:component)*/biopax:entityReference/biopax:xref [
    biopax:db "ChEBI"^^xsd:string ;
    biopax:id ?child
  ] .
  BIND (IRI(CONCAT (obo:, REPLACE(STR(?child), ":", "_"))) AS ?uri)
  ?uri rdfs:label ?child_label .
}
```

## `graph`
- pathway の親子関係
```sparql
PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?parent ?child ?parent_label ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/reactome>
WHERE {
  ?top_path a biopax:Pathway ;
            biopax:organism ?org .
  ?org biopax:name "Homo sapiens"^^xsd:string .
  MINUS { [] biopax:pathwayComponent ?top_path . }
  ?top_path biopax:pathwayComponent* ?parent_path .
  ?parent_path a biopax:Pathway ;
               biopax:displayName ?parent_label ;
               biopax:xref [
                 biopax:db "Reactome"^^xsd:string ;
                 biopax:id ?parent 
               ] ;
               biopax:pathwayComponent ?child_path .
  ?child_path a biopax:Pathway ;
              biopax:displayName ?child_label ;
              biopax:xref [
                biopax:db "Reactome"^^xsd:string ;
                biopax:id ?child 
              ] .
}
```

## `top`
- ヒト pathway の top 階層
```sparql
PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?top ?top_label
FROM <http://rdf.integbio.jp/dataset/togosite/reactome>
WHERE {
  ?top_path a biopax:Pathway ;
            biopax:pathwayComponent ?child_path .
  MINUS { [] biopax:pathwayComponent ?top_path . }
  ?top_path biopax:organism ?org ;
            biopax:displayName ?top_label ;
            biopax:xref [
              biopax:db "Reactome"^^xsd:string ;
              biopax:id ?top ;
            ] .
  ?org biopax:name "Homo sapiens"^^xsd:string .
}
```

## `return`
- 整形
```javascript
({top, leaf, graph}) => {
  const idPrefix = "CHEBI:";
  const withoutId = "unclassified";

  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  /*  ,{
      id: withoutId,
      label: "without annotation",
      parent: "root"
    } */
  ];

  //let withAnnotation = {};
  // トップとルートの関係
  top.results.bindings.map(d => {
    tree.push({
      id: d.top.value,
      label: d.top_label.value,
      parent: "root"
    })
  })
  // 親子関係
  graph.results.bindings.map(d => {
    tree.push({
      id: d.child.value,
      label: d.child_label.value,
      parent: d.parent.value
    })
  })
  // アノテーション関係
  leaf.results.bindings.map(d => {
   // withAnnotation[d.child.value] = true;
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value
    })
  })
/*  // アノテーション無し要素
  allLeaf.results.bindings.map(d => {
    if (!withAnnotation[d.leaf.value]) {
      tree.push({
        id: d.leaf.value.replace(idPrefix, ""),
        label: d.leaf_label.value,
        leaf: true,
        parent: withoutId
      });
    }
  }) */
  
  return tree;
}
```