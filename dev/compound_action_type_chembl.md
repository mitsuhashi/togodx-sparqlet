# ChEMBLを作用機作で分類する（信定・八塚・鈴木） 
server対応済み

## Description

- Data sources
    - (More data sources description goes here..)
    - ChEMBL-RDF 28.0: http://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBL-RDF/
- Query
    - (More query details go here..)
    -  Input
        - ChEMBL ID
    - Output
        - Mechanism action type

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `data`

```sparql
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT?parent ?child ?child_label  
WHERE 
{
  ?chembl_drug_mechanism a cco:Mechanism ;
                        cco:hasMolecule ?molecule ;
                        cco:mechanismActionType ?parent .
 ?molecule cco:chemblId ?child ;
           rdfs:label ?child_label .
}

```

## `return`

```javascript
({data}) => {
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];

  let edge = {};
  data.results.bindings.map(d => {
    tree.push({
      id: d.child.value,
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value
    })
  // root との親子関係を追加
    if (!edge[d.parent.value]) {
      edge[d.parent.value] = true;
      tree.push({   
        id: d.parent.value,
        label: d.parent.value,
        leaf: false,
        parent: "root"
      })
    }
  });
  
  return tree;
};
```

