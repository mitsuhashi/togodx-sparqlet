# ChEBI Chemical Role での分類 （川島、建石、信定） 
- アノテーションがないケースを数えていない（もとのまま）
## Description

- Data sources
    -  [Chemical Entities of Biological Interest (ChEBI) ](https://www.ebi.ac.uk/chebi/) 
- Query
    - Input
        - ChEBI id (number)
    - Output
        -  [Chemical Role (CHEBI:51086)](https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:51086) and its subcategories

## Parameters




## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `graph`
- Chemical Role の親子関係

```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX CHEBI: <http://purl.obolibrary.org/obo/CHEBI_>

SELECT DISTINCT ?parent ?child ?parent_label ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/chebi>
WHERE 
{
      
  ?r a owl:Restriction ;
    owl:onProperty obo:RO_0000087 ;
    owl:someValuesFrom ?role .
  ?parent rdfs:subClassOf* obo:CHEBI_51086.
  ?child rdfs:subClassOf ?parent.
  ?child rdfs:label ?child_label .
  ?parent rdfs:label ?parent_label .
  ?role rdfs:subClassOf* ?child .
  
}
```

## `leaf`
- ChEBI Compound  のアノテーション

```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX CHEBI: <http://purl.obolibrary.org/obo/CHEBI_>

SELECT distinct ?compound GROUP_CONCAT(DISTINCT ?label; SEPARATOR = ", ") as ?compound_label 
                          ?role                                      
                          GROUP_CONCAT(DISTINCT ?role_label; SEPARATOR = ", ") AS ?role_label 
FROM <http://rdf.integbio.jp/dataset/togosite/chebi>
WHERE 
{
  #test
  #VALUES ?compound { CHEBI:18012  CHEBI:27732 CHEBI:17594 CHEBI:16866 CHEBI:46195 CHEBI:62867}
      
  ?compound a owl:Class ;
    rdfs:label ?label ;
    rdfs:subClassOf ?r .
  ?r a owl:Restriction ;
    owl:onProperty obo:RO_0000087 ;
    owl:someValuesFrom ?role .
  ?role  rdfs:subClassOf* obo:CHEBI_51086.  
  ?role rdfs:label ?role_label .
  
}
```

## `return`

```javascript

({leaf, graph}) => {
  const idPrefix = "http://purl.obolibrary.org/obo/CHEBI_";
  const categoryPrefix = "http://purl.obolibrary.org/obo/CHEBI_";
  
  let tree = [
    {
      id: "51086",
      label: "chemical role",
      root: true
    }
  ];

  // 親子関係
  graph.results.bindings.map(d => {
    tree.push({
      id: d.child.value.replace(categoryPrefix, ""),
      label: d.child_label.value,
      parent: d.parent.value.replace(categoryPrefix, "")
    })
  })
  // アノテーション関係
  leaf.results.bindings.map(d => {
    tree.push({
      id: d.compound.value.replace(idPrefix, ""),
      label: d.compound_label.value,
      leaf: true,
      parent: d.role.value.replace(categoryPrefix, "")
    })
  })
  
  return tree;	
}

```