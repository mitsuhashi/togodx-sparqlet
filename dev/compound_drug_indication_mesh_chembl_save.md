# chembl mesh（山本、守屋、信定）
Server対応済み

## Description

- Data sources
    - (More data sources description goes here..)
    - ChEMBL-RDF 28.0: http://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBL-RDF/
    - Mesh 2021: ftp://ftp.nlm.nih.gov/online/mesh/rdf/
- Query
    - (More query details go here..)
    -  Input
        - ChEMBL ID
        - Mesh Tree Number
    - Output
        - Mesh term for ChEMBL drug indication

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `chemblHasMesh`
```sparql
PREFIX chembl: <http://rdf.ebi.ac.uk/terms/chembl#> 
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?chembl_id ?chembl_label ?mesh
FROM <http://rdf.integbio.jp/dataset/togosite/chembl>
WHERE {
  ?molecule chembl:chemblId ?chembl_id ;
      rdfs:label ?chembl_label ;
      chembl:hasDrugIndication/chembl:hasMesh ?mesh .
}
```

## `meshTree`
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mesh: <http://id.nlm.nih.gov/mesh/>
PREFIX meshv: <http://id.nlm.nih.gov/mesh/vocab#>

SELECT DISTINCT ?mesh_id ?mesh_label ?parent_mesh_id
FROM <http://rdf.integbio.jp/dataset/togosite/mesh>
WHERE {
  # MeSH Treeの Diseases[C] 以下を取得
  # See https://meshb.nlm.nih.gov/treeView
  FILTER (regex(str(?tree), "C"))
  ?node meshv:parentTreeNumber* ?tree .
  OPTIONAL {
    ?node meshv:parentTreeNumber ?parent  .
    ?parent_mesh_id meshv:treeNumber ?parent .
  }

  ?mesh_id meshv:treeNumber ?node ;
      rdfs:label ?mesh_label .
  FILTER(lang(?mesh_label) = "en")
}
```

# `return`
```javascript
({ chemblHasMesh, meshTree }) => {
  const idPrefix = "http://id.nlm.nih.gov/mesh/";

  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];

  meshTree.results.bindings.forEach((d) => {
    tree.push({
      id: d.mesh_id.value.replace(idPrefix, ""),
      label: d.mesh_label.value,
      parent: d.parent_mesh_id ? d.parent_mesh_id.value.replace(idPrefix, "") : "root"
    });
  });

  chemblHasMesh.results.bindings.map((d) => {
    tree.push({
      id: d.chembl_id.value,
      label: d.chembl_label.value,
      leaf: true,
      parent: d.mesh.value.replace('http://identifiers.org/mesh/', '')
    });
  });

  return tree;
}
```
