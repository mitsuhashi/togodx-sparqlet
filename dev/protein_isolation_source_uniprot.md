# UniProt isolated tissue classification（守屋）

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Obtain tissues to which input UniProt entries link with <https://www.uniprot.org/core/isolatedFrom>.
    - Input UniProt entries contain a reference describing the protein sequence obtained from a clone isolated from output tissues.
    - Input
        - UniProt ID
    - Output
        - Tissue
            - [UniProt Controlled vocabulary of tissues](https://www.uniprot.org/docs/tisslist)

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?parent ?child ?parent_label ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot/tissues>
WHERE {
  ?child a up:Protein ;
         up:mnemonic ?child_label ;
         up:organism taxon:9606 ;
         up:proteome ?proteome ;
         up:isolatedFrom ?parent .
  ?parent skos:prefLabel ?parent_label .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}
```

## `allLeaf`
- 全 UniProt (without annotation 用)
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
SELECT DISTINCT ?leaf ?leaf_label
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  ?leaf a up:Protein ;
        up:organism taxon:9606 ;
        up:mnemonic ?leaf_label ;
        up:proteome ?proteome .
  FILTER(REGEX(STR(?proteome), "UP000005640"))
}
```

## `return`
```javascript
({data, allLeaf}) => {
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  const categoryPrefix = "http://purl.uniprot.org/tissues/";
  const withoutId = "unclassified"; 
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },{
      id: withoutId,
      label: "Unclassified",
      parent: "root"
    }
  ];

  let withAnnotation = {};
  let edge = {};
  // アノテーション関係
  data.results.bindings.map(d => {
    withAnnotation[d.child.value] = true;
    tree.push({
      id: d.child.value.replace(idPrefix, ""),
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value.replace(categoryPrefix, "")
    })
    // root との親子関係を追加
    if (!edge[d.parent.value]) {
      edge[d.parent.value] = true;
      tree.push({     
        id: d.parent.value.replace(categoryPrefix, ""),
        label: d.parent_label.value,
        parent: "root"
      })
    }
  });
  // アノテーション無し要素
  allLeaf.results.bindings.map(d => {
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
};
```