# reactome-pathway（申）
- 
  
## Description
- Data sources
- Query
    - Input
    - Output
- https://integbio.jp/togosite/sparql

## Endpoint
https://togodx-dev.dbcls.jp/human/sparql

## `leaf`
- pathway の leaf
```sparql
PREFIX biopax: <http://www.biopax.org/release/biopax-level3.owl#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
SELECT DISTINCT ?path ?leaf_label ?leaf_id
FROM <http://rdf.integbio.jp/dataset/togosite/reactome>
WHERE {
  ?path a biopax:Pathway ;
        biopax:organism ?org .
  ?org biopax:name "Homo sapiens"^^xsd:string .

  ?path biopax:displayName ?leaf_label ;
        biopax:xref [
          biopax:db "Reactome"^^xsd:string ;
          biopax:id ?leaf_id ;
        ] .
         
  MINUS {?path biopax:pathwayComponent+ ?graph_path .
         ?graph_path a biopax:Pathway ;
                     biopax:displayName ?parent_label ;
                     biopax:xref [
                       biopax:db "Reactome"^^xsd:string ;
                       biopax:id ?parent ;
                     ] .
        }
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
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];
  
  let check = {};
  leaf.results.bindings.map(d => {
    check[d.leaf_id.value] = true;
  })
  
  // トップとルートの関係
  top.results.bindings.map(d => {
    tree.push({
      id: d.top.value.replace("R-HSA-", "R_HSA_"),
      label: d.top_label.value,
      parent: "root"
    })
  })
  
  // 親子関係
  graph.results.bindings.map(d => {
    if (check[d.child.value]) {  // proteome check
      tree.push({
        id: d.child.value.replace("R-HSA-", "R_HSA_"),
        label: d.child_label.value,
        leaf: true,
        parent: d.parent.value.replace("R-HSA-", "R_HSA_")
      })
    } else {
      tree.push({
        id: d.child.value.replace("R-HSA-", "R_HSA_"),
        label: d.child_label.value,
        parent: d.parent.value.replace("R-HSA-", "R_HSA_")
      })
    }
  })
  
  return tree;
}
```