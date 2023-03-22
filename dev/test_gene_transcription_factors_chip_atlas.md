# Target genes of TFs in ChIP-Atlas （大田・池田・小野・千葉）

## Description

- Data sources
    - ChIP-Atlas: [http://dbarchive.biosciencedbc.jp/kyushu-u/hg38/target/](http://dbarchive.biosciencedbc.jp/kyushu-u/hg38/target/)
    - The genes in `<Transcription Factor>.10.tsv` were defined to be target genes of the `<Transcription Factor>`.

- Query
    - Input
        - Ensembl gene ID of target genes
    - Output
        - Ensembl gene ID of TFs

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `tfGenes`
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ensembl: <http://identifiers.org/ensembl/>

SELECT DISTINCT ?tf
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/chip_atlas> {
    ?tf obo:RO_0002428 [] .
  }
}
```

## `geneLabels`
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ensembl: <http://identifiers.org/ensembl/>
PREFIX taxid: <http://identifiers.org/taxonomy/>
PREFIX faldo: <http://biohackathon.org/resource/faldo#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT DISTINCT ?ensg_id ?ensg_label
WHERE {
  GRAPH <http://rdf.integbio.jp/dataset/togosite/ensembl> {
    ?enst obo:SO_transcribed_from ?ensg .
    ?ensg obo:RO_0002162 taxid:9606 ; # in taxon
          faldo:location ?ensg_location ;
          rdfs:label ?ensg_label ;
          dc:identifier ?ensg_id .
    BIND (strbefore(strafter(str(?ensg_location), "GRCh38/"), ":") AS ?chr)
    FILTER (?chr IN ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                     "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                     "21", "22", "X", "Y", "MT" ))
  }
}
```

## `return`
```javascript
async ({ tfGenes, geneLabels }) => {
  let tf = tfGenes.results.bindings.map((d) => d.tf.value.replace('http://identifiers.org/ensembl/', ''));

  let labels = new Map();
  geneLabels.results.bindings.forEach((x) => labels.set(x.ensg_id.value, x.ensg_label.value));
  let unclassifiedGenes = new Set(labels.keys());

  let tree = [
    {
      id: 'root',
      label: 'root node',
    }
  ];
  let errors = [];

  for (let i = 0; i < tf.length; i++) {
    tree.push({
      parent: 'root',
      id: labels.get(tf[i]), // use TF labels as ids of TFs to sort by label
      label: labels.get(tf[i])
    });

    const targetGenes = await fetch('test_backend_gene_transcription_factors_chip_atlas',　{
      method: 'POST',
      body: `tfId=${tf[i]}`,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).then((res) => {
      if (res.ok) {
        return res.json();
      } else {
        errors.push(tf[i]);
      }
    });

    if (targetGenes) {
      targetGenes.forEach((gene) => {
        unclassifiedGenes.delete(gene);
        tree.push({
          parent: labels.get(tf[i]),
          id: gene,
          label: labels.get(gene),
          leaf: true
        });
      });
    }
  }

  tree.push({
    parent: 'root',
    id: 'unclassified',
    label: 'no known upstream TF'
  });
  unclassifiedGenes.forEach((gene) => {
    tree.push({
      parent: 'unclassified',
      id: gene,
      label: labels.get(gene),
      leaf: true
    });
  });

  if (errors.length) {
    tree.push({ errors: errors });
  }
  return tree;
}
```
