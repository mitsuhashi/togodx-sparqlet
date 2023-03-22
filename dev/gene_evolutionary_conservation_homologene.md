# ヒト遺伝子が保存されている最も遠縁の生物（千葉・池田）

## Description
- Data sources
  - HomoloGene Release 68: [https://www.ncbi.nlm.nih.gov/homologene/statistics/](https://www.ncbi.nlm.nih.gov/homologene/statistics/)
- Input/Output 
  - Input
    - NCBI Gene ID
  - Output
    - Organisms
- Supplementary information
  - On the basis of HomoloGene database including 21 eukaryotic species and divergence times between human and each species, the most distant organisms where each human gene is conserved are shown.
  - 真核生物21種を含むHomoloGeneデータベースおよびヒトと各生物種との分岐年代に基づいて、ヒト遺伝子が保存されている生物のうち最も遠縁の生物を表示しています。

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}


## `main`

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX orth: <http://purl.org/net/orth#>
PREFIX homologene: <https://ncbi.nlm.nih.gov/homologene/>
PREFIX taxid: <http://identifiers.org/taxonomy/>
PREFIX ncbigene: <http://identifiers.org/ncbigene/>
PREFIX hop: <http://purl.org/net/orthordf/hOP/ontology#>

SELECT DISTINCT ?human_gene ?gene_label ?branch_id ?branch_label
FROM <http://rdf.integbio.jp/dataset/togosite/homologene/ontology>
FROM <http://rdf.integbio.jp/dataset/togosite/homologene/data>
WHERE {
  ?branch a hop:HomoloGeneBranch ;
      dct:identifier ?branch_id ;
      rdfs:label ?branch_label ;
      hop:timeMya ?branch_time_mya .
  {
    SELECT ?human_gene ?gene_label (max(?time) as ?branch_time_mya)
    WHERE {
      ?grp orth:inDataset homologene: ;
          orth:hasHomologousMember ?human_gene, ?gene .
      ?human_gene orth:taxon taxid:9606 ;
          rdfs:label ?gene_label .
      ?gene orth:taxon/hop:branch/hop:timeMya ?time .
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
      root: true
    }
  ];

  let checked = {};

  main.results.bindings.forEach((elem) => {
    if (!checked[elem.branch_id.value]) {
      checked[elem.branch_id.value] = true;
      tree.push({
        id: 'branch_' + ('00' + elem.branch_id.value).slice(-2),
        label: capitalizeCsv(elem.branch_label.value),
        parent: "root",
      });
    }
    tree.push({
      id: elem.human_gene.value.replace("http://identifiers.org/ncbigene/", ""),
      label: elem.gene_label.value,
      leaf: true,
      parent: 'branch_' + ('00' + elem.branch_id.value).slice(-2),
    });
  });

  return tree;

  function capitalizeCsv(str) {
    return str.split(', ').map((s) => capitalize(s)).join(', ')
  }
  function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.substring(1);
  }
};
```
