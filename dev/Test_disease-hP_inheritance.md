# Human phenotype ontorogy inheritance 分類(高月）

## Description
- HPのinheritanceのツリーに対して、OMIMのデータをMONDOへ変換をしてリーフにする
- Data sources
    -  [Human Phenotype Ontology (HPO)](https://hpo.jax.org/app/) 
- Query
    - Input
        - HPO id
    - Output
        -  [Mode of inheritance (HP:0000005)](http://purl.obolibrary.org/obo/HP_0000005)  and its subcategories of HPO

## Endpoint

https://togodx-dev.dbcls.jp/human/sparql

## `leaf`
```sparql

## endpoint https://togodx-dev.dbcls.jp/human/sparql

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
 
SELECT DISTINCT ?mondo ?omim ?mondo_id ?mondo_label ?omim_id ?omim_iri ?hp
 WHERE{
  GRAPH<http://rdf.integbio.jp/dataset/togosite/mondo>{
   ?mondo 
   rdfs:label ?mondo_label;
   oboInOwl:hasDbXref ?omim;
   oboInOwl:id ?mondo_id.
   FILTER (regex(?omim, 'OMIM'))
   BIND (REPLACE(str(?omim),"OMIM:","http://purl.obolibrary.org/obo/OMIM_") AS ?omim_id)
   BIND (IRI(?omim_id) AS ?omim_iri) }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/monarch-kg-dev>{
   ?omim_iri
   biolink:has_mode_of_inheritance ?hp.
  }
}

```

## `graph`
```sparql
## endpoint https://togodx-dev.dbcls.jp/human/sparql

PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX biolink: <https://w3id.org/biolink/vocab/>
PREFIX oboInOwl: <http://www.geneontology.org/formats/oboInOwl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
 
SELECT DISTINCT  ?hp ?hp_label ?parent
 WHERE{ 
  GRAPH<http://rdf.integbio.jp/dataset/togosite/mondo>{
   ?mondo 
   rdfs:label ?mondo_label;
   oboInOwl:hasDbXref ?omim;
   oboInOwl:id ?mondo_id.
   FILTER (regex(?omim, 'OMIM'))
   BIND (REPLACE(str(?omim),"OMIM:","http://purl.obolibrary.org/obo/OMIM_") AS ?omim_id)
   BIND (IRI(?omim_id) AS ?omim_iri)
      }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/monarch-kg-dev>{
   ?omim_iri
   biolink:has_mode_of_inheritance ?hp.
      }
 GRAPH <http://rdf.integbio.jp/dataset/togosite/hpo>{
  ?hp rdfs:label ?hp_label;
      rdfs:subClassOf ?parent.
      }
 }
  ORDER BY ?hp

```
## `return`

```javascript
({graph,leaf}) => {
  const idPrefix = "http://purl.obolibrary.org/obo/HP_";
  const leafPrefix= "http://purl.obolibrary.org/obo/MONDO_";
  let tree = [
    {
      id: "0000005",
      label: "Mode of inheritance",
      root: true
    }
  ];
  graph.results.bindings.forEach(d => {
    tree.push({
      id: d.hp.value.replace(idPrefix, ""),
      label: d.hp_label.value,
      parent: d.parent.value.replace(idPrefix, "")
    })
  })
  leaf.results.bindings.forEach(d => {
    tree.push({
      id: d.mondo.value.replace(leafPrefix, ""),
      label: d.mondo_label.value,
      parent: d.hp.value.replace(idPrefix, ""),
      leaf: true
    });
  });
  return tree;
};
```

## MEMO
-Author
 - Takatsuki