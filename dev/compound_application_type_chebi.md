# ChEBI Application での分類 （川島、建石） 
- アノテーションがないケースを数えていない（もとのまま）
## Description

- Data sources
    -  [Chemical Entities of Biological Interest (ChEBI) ](https://www.ebi.ac.uk/chebi/) 
- Query
    - Input
        - ChEBI id (number) for chemical compound(s)
    - Output
        -  ChEBI id (number) for application type(s) (subcategories of [Application (CHEBI:33232)](https://www.ebi.ac.uk/chebi/searchId.do?chebiId=CHEBI:33232) ) corresponding to the compound(s)
- Supplementary Information
	-  The classification of compounds according to their application, defined in ChEBI ontology.
	- ChEBI Ontologyに定義された用途による、化合物の分類です。
    
## Parameters



## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `graph`
- Application の親子関係

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
    owl:someValuesFrom ?appl .
  ?parent rdfs:subClassOf* obo:CHEBI_33232.
  ?child rdfs:subClassOf ?parent.
  ?child rdfs:label ?child_label .
  ?parent rdfs:label ?parent_label .
  ?appl rdfs:subClassOf* ?child .
  
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
                          ?application                                      
                          GROUP_CONCAT(DISTINCT ?application_label; SEPARATOR = ", ") AS ?application_label bound(?x) as ?haschild
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
    owl:someValuesFrom ?application .
  ?application rdfs:subClassOf*  obo:CHEBI_33232.

  ?application rdfs:label ?application_label .
  optional{?x rdfs:subClassOf ?application}
}
```

## `return`

```javascript
({leaf, graph}) => {
  const idPrefix = "http://purl.obolibrary.org/obo/CHEBI_";
  const categoryPrefix = "http://purl.obolibrary.org/obo/CHEBI_";
  
  let tree = [
    {
      id: "33232",
      label: "application",
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
      parent: d.application.value.replace(categoryPrefix, "")
    })
  })
  
  return tree;	
}
```