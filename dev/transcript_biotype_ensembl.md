# Ensembl transcript biotype （池田）

## Description

- Data sources
    - Ensembl human release 107: [http://nov2020.archive.ensembl.org/Homo_sapiens/Info/Index](http://nov2020.archive.ensembl.org/Homo_sapiens/Info/Index)
- Supplementary information
 	- A transcript classification such as "protein coding" and "lincRNA". Definition of biotypes is described [here](http://useast.ensembl.org/info/genome/genebuild/biotypes.html).
	- protein coding, lncRNA といった、転写産物の分類です。分類の定義については [こちらをご覧ください](http://useast.ensembl.org/info/genome/genebuild/biotypes.html)。

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `data`

```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX taxon: <http://identifiers.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX faldo: <http://biohackathon.org/resource/faldo#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX so: <http://purl.obolibrary.org/obo/so#>

SELECT DISTINCT ?parent ?child ?child_label
FROM <http://rdf.integbio.jp/dataset/togosite/ensembl>
WHERE {
  ?enst so:transcribed_from ?ensg .
  ?ensg obo:RO_0002162 taxon:9606 ;
        so:part_of ?chr .
  ?enst a ?parent ;
        dcterms:identifier ?child ;
        rdfs:label ?child_label .
  FILTER(CONTAINS(STR(?parent), "terms/ensembl/"))
  BIND(STRBEFORE(STRAFTER(STR(?chr), "http://identifiers.org/hco/"), "#") as ?chromosome)
  VALUES ?chromosome {
      "1" "2" "3" "4" "5" "6" "7" "8" "9" "10"
      "11" "12" "13" "14" "15" "16" "17" "18" "19" "20" "21" "22"
      "X" "Y" "MT"
  }
}
```

## `return`

```javascript
({data}) => {
  const idPrefix = "http://rdf.ebi.ac.uk/terms/ensembl/";

  let tree = [{
    id: "root",
    label: "root node",
    root: true
  }];
  let chk = {};

  data.results.bindings.map(d => {
    if (!chk[d.parent.value]) {
      chk[d.parent.value] = true;
      tree.push({
        id: d.parent.value.replace(idPrefix, ""),
        label: d.parent.value.replace(idPrefix, "").replace(/_/g, " "),
        leaf: false,
        parent: "root"
      })
    }
    tree.push({
      id: d.child.value,
      label: d.child_label.value,
      leaf: true,
      parent: d.parent.value.replace(idPrefix, "")
    })
  });

  return tree;
};
```
