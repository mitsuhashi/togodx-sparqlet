# UniProt ChEMBL-assay-confidence-score classification 2（守屋, 信定）

- confidence score
  - https://chembl.gitbook.io/chembl-interface-documentation/frequently-asked-questions/chembl-data-questions

## Description
 
- Data sources
    - Proteins with or without ChEMBL assay from UniProt
    - ChEMBL-RDF 28.0: http://ftp.ebi.ac.uk/pub/databases/chembl/ChEMBL-RDF/
- Query
    - Input
        - Existence (1: exists, 0: not exists), UniProt ID
    - Output
        - The number of UniProt entries link to ChEMBL entries.
        - If a UniProt ID is entered, it returns whether ChEMBL entry exists or not.

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX cco: <http://rdf.ebi.ac.uk/terms/chembl#>
PREFIX uniprot: <http://purl.uniprot.org/uniprot/>

SELECT DISTINCT ?uniprot ?conf_score ?conf_score_label ?assay_type
FROM <http://rdf.integbio.jp/dataset/togosite/chembl>
WHERE {
  ?chembl a cco:SmallMolecule ;
          cco:hasActivity/cco:hasAssay ?assay.
  ?assay a cco:Assay ;
            cco:targetConfScore ?conf_score ;
            cco:targetConfDesc ?conf_score_label ;
            cco:assayType ?assay_type ;
            cco:hasTarget/skos:exactMatch [
            cco:taxonomy taxon:9606 ;
            skos:exactMatch ?uniprot
          ] . 
  ?uniprot a cco:UniprotRef .
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
({data, allLeaf})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  const withoutId = "unclassified";

  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },{
      id: withoutId,
      label: "No ChEMBL assay",
      parent: "root"
    },{
      id: "Binding",
      label: "Binding",
      parent: "root"
    },{
      id: "ADME",
      label: "ADME",
      parent: "root"
    },{
      id: "Functional",
      label: "Functional",
      parent: "root"
    },{
      id: "Toxicity",
      label: "Toxicity",
      parent: "root"
    },{
      id: "Unassigned",
      label: "Unassigned",
      parent: "root"
    }
  ];

  let uri2label = {};
  allLeaf.results.bindings.map(d => {
    uri2label[d.leaf.value] = d.leaf_label.value;
  })

  let withAnnotation = {};
  let edge = {};

  // アノテーション関係
  data.results.bindings.map(d => {
    withAnnotation[d.uniprot.value] = true;
    let parent_id;
    // id を conf-score [9-0] から sortable に
    if (d.conf_score.value.match(/^\d$/)) {
      parent_id = 10 - Number(d.conf_score.value);
      parent_id = parent_id.toString();
      parent_id2 = d.assay_type.value + parent_id;
      d.conf_score_label.value = "Conf-score " + d.conf_score.value + ": " + d.conf_score_label.value;
    }
    if (uri2label[d.uniprot.value]) { // uniprot referece proteome human にあるもの "UP000005640"
      tree.push({
        id: d.uniprot.value.replace(idPrefix, ""),
        label: uri2label[d.uniprot.value],
        leaf: true,
        parent: parent_id2
      })
      tree.push({
         id: parent_id2,
	     label: d.conf_score_label.value,
	     parent: d.assay_type.value
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
}
```