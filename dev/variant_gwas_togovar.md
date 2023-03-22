# variant GWAS (Genome-wide association study) (三橋, 守屋)

## Description

- Data sources
    -  [TogoVar](https://togovar.biosciencedbc.jp/?) (limited to variants with frequency data in Japanese populations)
- Query
    - Input
        - TogoVar id
    - Output
        -  [Mapped trait used in GWAS Catalog](https://www.ebi.ac.uk/gwas/docs/ontology)

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `leaf`
```sparql
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX efo: <http://www.ebi.ac.uk/efo/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX terms: <http://med2rdf.org/gwascatalog/terms/>

SELECT DISTINCT ?parent ?child ?parent_label ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/variation>
FROM <http://rdf.integbio.jp/dataset/togosite/gwas-catalog>
FROM <http://rdf.integbio.jp/dataset/togosite/efo>
WHERE {
  VALUES ?root {  efo:EFO_0000001  } 
  GRAPH <http://rdf.integbio.jp/dataset/togosite/efo>{
    ?parent rdfs:label ?parent_label ;
            rdfs:subClassOf* ?root;  # The parent must be reachable from the root.
            a owl:Class .
  }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/gwas-catalog>{
    ?parent ^terms:mapped_trait_uri/rdfs:seeAlso ?child_label .
  }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/variation>{
    ?child_label ^rdfs:seeAlso/dct:identifier ?child .
  }
}
```

## `graph`
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX terms: <http://med2rdf.org/gwascatalog/terms/>
PREFIX efo: <http://www.ebi.ac.uk/efo/>
SELECT DISTINCT ?parent ?child ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/variation>
FROM <http://rdf.integbio.jp/dataset/togosite/gwas-catalog>
FROM <http://rdf.integbio.jp/dataset/togosite/efo>
WHERE {
  VALUES ?root {  efo:EFO_0000001  } 
  GRAPH <http://rdf.integbio.jp/dataset/togosite/efo> {
    ?child a owl:Class ;
           rdfs:subClassOf ?parent ;
           rdfs:label ?child_label .
    ?parent a owl:Class ;
           rdfs:subClassOf* ?root .
    ?trait rdfs:subClassOf* ?child .
  }
  ?trait ^terms:mapped_trait_uri/rdfs:seeAlso/^rdfs:seeAlso ?togovar.
}
```

## `return`
```javascript
({leaf, graph}) => {
  const childLabelPrefix = "http://identifiers.org/dbsnp/";
  
  let tree = [
    {
      id: "EFO_0000001",
      label: "experimental factor",
      root: true
    }
  ];

  let is_dumped = {}  // 既に出力されたid,parent関係
 
  // 親子関係
  graph.results.bindings.map(d => {
    id = d.child.value.split(/\//).slice(-1)[0]
    parent = d.parent.value.split(/\//).slice(-1)[0]
    if(is_dumped[id] == parent){ return }   // 一度出力されたid,parentは出力しない
    is_dumped[id] = parent
    tree.push({
      id: id,
      label: d.child_label.value,
      parent: d.parent.value.split(/\//).slice(-1)[0]
    })
  })
  // アノテーション関係
  leaf.results.bindings.map(d => {
    parent = d.parent.value.split(/\//).slice(-1)[0]
    tree.push({
      id: d.child.value,
      label: d.child_label.value.replace(childLabelPrefix, ""),
      leaf: true,
      parent: d.parent.value.split(/\//).slice(-1)[0]
    })
  })
  
  return tree;	
}
```