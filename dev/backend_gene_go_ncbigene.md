# NCBI Gene GO classification (池田)

- backend SPARQLet

## Parameters

* `root` (type: GO) (Req.)
  * default: GO_0005575
  * example: GO_0008150 (biological process), GO_0005575 (cellular component), GO_0003674 (molecular function)

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `leaf`
- GO と NCBI Gene のアノテーション関係
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX hop: <http://purl.org/net/orthordf/hOP/ontology#>

SELECT DISTINCT ?parent ?child ?child_label # ?parent_label
FROM <http://rdf.integbio.jp/dataset/togosite/homo_sapiens_gene_info>
FROM <http://rdf.integbio.jp/dataset/togosite/go>
WHERE {
  ?child a <http://ddbj.nig.ac.jp/ontologies/nucleotide/Gene> ;
         rdfs:label ?child_label ;
         hop:hasGO ?parent .
  ?parent rdfs:subClassOf* obo:{{root}} .
}
```

## `graph`
- GO の親子関係
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?parent ?child ?child_label ?parent_label
FROM <http://rdf.integbio.jp/dataset/togosite/go>
WHERE {
  ?child rdfs:subClassOf* obo:{{root}} ;
  #?child rdfs:subClassOf* obo:GO_0008150 ;
         rdfs:subClassOf ?parent .
  FILTER(REGEX(STR(?child), "GO_"))
  FILTER(REGEX(STR(?parent), "GO_"))
  ?child rdfs:label ?child_label .
  ?parent rdfs:label ?parent_label .
}
```

## `allLeaf`
- 全 NCBI Gene (without annotation 用)
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?leaf ?leaf_label
FROM <http://rdf.integbio.jp/dataset/togosite/homo_sapiens_gene_info>
WHERE {
  ?leaf a <http://ddbj.nig.ac.jp/ontologies/nucleotide/Gene> ;
        rdfs:label ?leaf_label .
}
```

## `return`
```javascript
({root, leaf, graph, allLeaf}) => {
  const idPrefix = "http://identifiers.org/ncbigene/";
  const categoryPrefix = "http://purl.obolibrary.org/obo/";
  const withoutId = "unclassified";
  
  let tree = [
    {
      id: root,
      root: true
    },{
      id: withoutId,
      label: "Unclassified",
      parent: root
    }
  ];

  let withAnnotation = {};
  // 親子関係
  graph.results.bindings.forEach(d => {
    tree.push({
      id: d.child.value.replace(categoryPrefix, ""),
      label: d.child_label.value,
      parent: d.parent.value.replace(categoryPrefix, "")
    })
    if (d.parent.value.replace(categoryPrefix, "") == root && !tree[0].label)
      tree[0].label = d.parent_label.value; // root の label 挿入
  })
  // アノテーション関係
  leaf.results.bindings.forEach(d => {
    //leaf が root を直接指している場合、evidence code が ND (No biological Data available)
    //unclassfied と区別したほうがよいかもしれないが、とりあえず同じ扱いにしておく
    if (d.parent.value.replace(categoryPrefix, "") == root)
      return;
    withAnnotation[d.child.value] = true;
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value.replace(categoryPrefix, "")
    })
  })
  // アノテーション無し要素
  allLeaf.results.bindings.forEach(d => {
    if (!withAnnotation[d.leaf.value]) {
      tree.push({
        id: d.leaf.value.replace(idPrefix, ""),
        label: d.leaf_label.value,
        leaf: true,
        parent: withoutId
      });
    }
  })
  
  return tree;	
}
```