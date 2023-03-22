# Number of human genes in each ortholog group（千葉）

## Description
- Data sources
  - HomoloGene Release 68: [https://www.ncbi.nlm.nih.gov/homologene/statistics/](https://www.ncbi.nlm.nih.gov/homologene/statistics/)
- Input/Output
  - Input
    - NCBI Gene ID
  - Output
    - Number of paralogs
- Supplementary information
  - The number of duplicated genes (paralogs) in each human gene.
  - ヒトの各遺伝子における重複遺伝子（パラログ）の数です。

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `main`

```sparql
PREFIX orth: <http://purl.org/net/orth#>
PREFIX homologene: <https://ncbi.nlm.nih.gov/homologene/>
PREFIX taxid: <http://identifiers.org/taxonomy/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>

SELECT DISTINCT ?paralog_count ?gene ?gene_label
FROM <http://rdf.integbio.jp/dataset/togosite/homologene/data>
WHERE {
  ?grp orth:inDataset homologene: ;
      orth:hasHomologousMember ?gene .
  ?gene orth:taxon taxid:9606 ;
      rdfs:label ?gene_label .
  {
    SELECT ?grp (COUNT(DISTINCT ?human_gene) AS ?paralog_count)
    WHERE {
      ?grp orth:inDataset homologene: ;
          orth:hasHomologousMember ?human_gene .
      ?human_gene orth:taxon taxid:9606 .
    }
  }
}
```

## `return`

```javascript
({ main }) => {

  let tree = [
    {
      id: "root",
      label: "root node",
      root: true,
    }
  ];

  let checked = {};

  main.results.bindings.forEach((elem) => {
    if (!checked[elem.paralog_count.value]) {
      checked[elem.paralog_count.value] = true;
      tree.push({
        id: 'paralog_count_' + ('00' + elem.paralog_count.value).slice(-2),
        label: makeLabel(elem.paralog_count.value),
        parent: "root",
      });
    }
    tree.push({
      id: elem.gene.value.replace("http://identifiers.org/ncbigene/", ""),
      label: elem.gene_label.value,
      leaf: true,
      parent: 'paralog_count_' + ('00' + elem.paralog_count.value).slice(-2),
    });
  });

  return tree;

  function makeLabel(paralog_count) {
    if (paralog_count == 1) {
      return "singleton";
    } else if (paralog_count == 2) {
      return "doublet";
    } else if (paralog_count == 3) {
      return "triplet";
    } else {
      return `${paralog_count} genes`;
    }
  }
};
```
