# ChEMBLを薬の開発フェーズで分類する（信定） 
development_phase=0を除いたもの

## Description

- Data sources
    - (More data sources description goes here..)
    - ChEMBL-RDF 28.0: http://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBL-RDF/
- Query
    - (More query details go here..)
    -  Input
        - ChEMBL ID
    - Output
        - Highest development phase
        
 ## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `main`

```sparql
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?chembl_id ?chembl_label ?development_phase
FROM <http://rdf.integbio.jp/dataset/togosite/chembl>
WHERE 
{
  ?chembl cco:chemblId ?chembl_id ;
            rdfs:label ?chembl_label ;
            cco:highestDevelopmentPhase ?development_phase .
  filter not exists { ?chembl a cco:DrugIndication }
  filter  (?development_phase != 0 )
}
```

## `return`

```javascript
({main}) => {
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];

  let edge = {};
  main.results.bindings.map(d => {
  // development_phase にラベルをつける
    let parent_label = d.development_phase.value;
    if (parent_label  == 1) parent_label = "1: PK tolerability";
    else if (parent_label  == 2) parent_label = "2: Efficacy";
    else if (parent_label  == 3) parent_label = "3: Safety & Efficacy";
    else if  (parent_label  == 4) parent_label = "4: Indication Discovery & expansion";
  
    tree.push({
      id: d.chembl_id.value,
      label: d.chembl_label.value,
      leaf: true,
      parent: d.development_phase.value
    })
    
     // root との親子関係を追加
    if (!edge[d.development_phase.value]) {
      edge[d.development_phase.value] = true;
      tree.push({   
        id: d.development_phase.value,
        label: parent_label,
        leaf: false,
        parent: "root"
      })
    }
  });
  
  return tree;
};
    

```