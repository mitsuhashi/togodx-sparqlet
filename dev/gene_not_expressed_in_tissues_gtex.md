# Tissues where a gene is not expressed （池田）

## Description

- Data sources
    - [GTEx version 8](https://gtexportal.org/home/datasets)

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX enso: <http://rdf.ebi.ac.uk/terms/ensembl/>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX refexo:  <http://purl.jp/bio/01/refexo#>
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX schema: <http://schema.org/>
PREFIX ensg: <http://rdf.ebi.ac.uk/resource/ensembl/>

SELECT DISTINCT ?parent_label ?parent ?child
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/refex_gtex_v8_summary> {
    ?refex a refexo:RefExEntry ;
           sio:SIO_000216 [
             a refexo:logTPMMax ;
             sio:SIO_000300 0
             #sio:SIO_000300 ?logtpmmax
           ] ;
           refexo:isMeasurementOf ?child ;
           refexo:refexSample ?refexs .
    #FILTER(?logtpmmax >= 0 && ?logtpmmax < 1)
  }
  
  GRAPH <http://rdf.integbio.jp/dataset/togosite/refexsample_gtex_v8_summary> {
    ?refexs dcterms:description ?parent_label ;
            dcterms:identifier ?parent .
  }
}
```

## `all`
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>
PREFIX enso: <http://rdf.ebi.ac.uk/terms/ensembl/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX refexo:  <http://purl.jp/bio/01/refexo#>

SELECT DISTINCT ?child ?child_label ?type
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/refex_gtex_v8_summary> {
    ?refex a refexo:RefExEntry ;
           refexo:isMeasurementOf ?child .
  }
  GRAPH <http://rdf.integbio.jp/dataset/togosite/ensembl> {
    ?child a ?type ;
           rdfs:label ?child_label .
    [] so:transcribed_from ?child .
  }
}
```

## `return`

```javascript
({data, all}) => {
  const idPrefix = "http://rdf.ebi.ac.uk/resource/ensembl/";

  let tree = [{
    id: "root",
    label: "root node",
    root: true
  }];
  let chk = {};
  let allEnsg = {};
  let unclassified = {};
  // GTEx のプロトコルの原理上、small RNA は取れていないはずだが、GTEx のデータ上には存在してしまっている。
  // そのような RNA を GTEx のデータを用いて「無発現」と判断するべきでないので、除く。
  const biotypes = new Set([
    "protein_coding", "lncRNA", "pseudogene",
    "polymorphic_pseudogene", "processed_pseudogene", "unitary_pseudogene", "unprocessed_pseudogene",
    "transcribed_processed_pseudogene", "transcribed_unitary_pseudogene", "transcribed_unprocessed_pseudogene",
    "translated_processed_pseudogene", "translated_unprocessed_pseudogene",
    "IG_C_gene", "IG_D_gene", "IG_J_gene", "IG_V_gene",
    "IG_pseudogene", "IG_C_pseudogene", "IG_J_pseudogene", "IG_V_pseudogene",
    "TR_C_gene", "TR_D_gene", "TR_J_gene", "TR_V_gene",
    "TR_J_pseudogene", "TR_V_pseudogene",
    "TEC"
  ])
  const ensoPrefix = "http://rdf.ebi.ac.uk/terms/ensembl/"
  all.results.bindings.forEach(d => {
    let label = d.child_label.value;
    if (label == "") {
      label = d.child.value.replace(idPrefix, "");
    }
    if (biotypes.has(d.type.value.replace(ensoPrefix, ""))) {
      allEnsg[d.child.value] = label;
      unclassified[d.child.value] = true;
    }
  });
  data.results.bindings.forEach(d => {
    if (!chk[d.parent.value]) {
      chk[d.parent.value] = true;
      tree.push({     
        id: d.parent_label.value,
        label: d.parent_label.value,
        leaf: false,
        parent: "root"
      });
    }
    if (allEnsg[d.child.value]) {
      tree.push({
        id: d.child.value.replace(idPrefix, ""),
        label: allEnsg[d.child.value],
        leaf: true,
        parent: d.parent_label.value
      });
    }
    delete unclassified[d.child.value];
  });

  tree.push({     
    id: "unclassified",
    label: "Expressed in all tissues",
    leaf: false,
    parent: "root"
  });

  Object.keys(unclassified).forEach(d => {
    tree.push({
      id: d.replace(idPrefix, ""),
      label: allEnsg[d],
      leaf: true,
      parent: "unclassified"
    });
  });
  return tree;
};

```
