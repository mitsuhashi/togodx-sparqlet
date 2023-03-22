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

## `tf`
```sparql
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ensembl: <http://identifiers.org/ensembl/>
PREFIX cao: <http://chip-atlas.org/ontology/>

SELECT DISTINCT ?tf
WHERE {
  #VALUES ?tf { ensembl:ENSG00000275700 ensembl:ENSG00000101544 ensembl:ENSG00000048052 } # for test
  GRAPH <http://rdf.integbio.jp/dataset/togosite/chip_atlas> {
    #?tf obo:RO_0002428 [] .
    [] cao:hasTF ?tf .
  }
}#LIMIT 500
```

## `tfclassSp`

molecular species とその所属先の genus

```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tfclass: <http://sybig.de/tfclass#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT DISTINCT ?ensg_id ?genus_id
FROM <http://rdf.integbio.jp/dataset/togosite/tfclass>
WHERE { 
  ?s tfclass:xref ?ensg .
  FILTER(STRSTARTS(?ensg, "ENSEMBL_GeneID:"))
  BIND(STRAFTER(?ensg, "ENSEMBL_GeneID:") as ?ensg_id)
  ?s rdfs:subClassOf tfclass:tf_9606 ;
     # rdfs:label ?label ;
     rdfs:subClassOf / owl:someValuesFrom ?genus .
  BIND(STRAFTER(STR(?genus), "http://sybig.de/tfclass#") AS ?genus_id)
}
```

## `tfclass`
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tfclass: <http://sybig.de/tfclass#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>

SELECT DISTINCT ?child_id ?parent_id ?child_label ?parent_label
FROM <http://rdf.integbio.jp/dataset/togosite/tfclass>
WHERE { 
  ?s tfclass:xref ?ensg .
  FILTER(STRSTARTS(?ensg, "ENSEMBL_GeneID:"))
  BIND(STRAFTER(?ensg, "ENSEMBL_GeneID:") as ?ensg_id)
  ?s rdfs:subClassOf tfclass:tf_9606 ;
     rdfs:subClassOf / owl:someValuesFrom ?genus .
  ?genus rdfs:subClassOf* ?child .
  ?child rdfs:subClassOf ?parent ;
         rdfs:label ?child_label .
  OPTIONAL {
    ?parent rdfs:label ?parent_label . # "TF_class" does not have a label
  }
  FILTER(!isBlank(?parent))
  BIND(STRAFTER(STR(?child), "http://sybig.de/tfclass#") AS ?child_id)
  BIND(STRAFTER(STR(?parent), "http://sybig.de/tfclass#") AS ?parent_id)
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
    BIND(STRBEFORE(STRAFTER(STR(?ensg_location), "GRCh38/"), ":") AS ?chr)
    FILTER (?chr IN ("1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
                     "11", "12", "13", "14", "15", "16", "17", "18", "19", "20",
                     "21", "22", "X", "Y", "MT" ))
  }
}
```

## `return`
```javascript
async ({tf, tfclassSp, tfclass, geneLabels}) => {
  let tfArray = tf.results.bindings.map(d => d.tf.value.replace("http://identifiers.org/ensembl/", ""));
  let geneLabelMap = new Map();
  geneLabels.results.bindings.forEach((x) => geneLabelMap.set(x.ensg_id.value, x.ensg_label.value));
  //function getGeneLabel(id, map) {
  //  let label = map.get(id);
  //  if(label)
  //    return label;
  //  else
  //    return id;
  //};
  let woTfGenes = new Set(geneLabelMap.keys());
  let tfclassSpGenusMap = new Map();
  tfclassSp.results.bindings.forEach((d) => tfclassSpGenusMap.set(d.ensg_id.value, d.genus_id.value));

  let tree = [{id: "root", label: "root node", root: true},
              {id: "_not_in_tfclass", label: "Not in TFClass", parent: "root"}];
  tfclass.results.bindings.forEach((d) => {
    if(d.parent_id.value === "TF_class") {
      tree.push(
        {
          parent: "root",
          id: d.child_id.value,
          label: d.child_label.value
        });
    } else if(d.parent_id.value != "") { // exclude an erroneous entry with blank string
      tree.push(
        {
          parent: d.parent_id.value,
          id: d.child_id.value,
          label: d.child_label.value
        });
    }
  });

  let errors = [];

  const from = 0;
  const to = tfArray.length;
  //const from = 0;
  //const to = parseInt(tfArray.length/2);
  //const from = parseInt(tfArray.length/2);
  //const to = tfArray.length;
  for (let i = from; i < to; i++) {
    let tf = tfArray[i];
    let genus = tfclassSpGenusMap.get(tf);
    let tf_label = geneLabelMap.get(tf);
    if(!tf_label)
      tf_label = tf;
    if(genus) {
      tree.push(
        {
          parent: genus,
          id: tf_label, // use TF labels as ids of TFs to sort by label
          label: tf_label
        });
    } else {
      tree.push(
        {
          parent: "_not_in_tfclass",
          id: tf_label, // use TF labels as ids of TFs to sort by label
          label: tf_label
        });
    }
    const targetGenes = await fetch('backend_gene_transcription_factors_chip_atlas', {
      method: 'POST',
      body: `tfId=${tf}`,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }).then((res) => {
      if (res.ok) {
        return res.json();
      } else {
        errors.push(tf);
      }
    });
    targetGenes.forEach((target) => {
      woTfGenes.delete(target);
      let target_label = geneLabelMap.get(target);
      if(!target_label)
        target_label = target;
      tree.push(
        {
          parent: tf_label,
          id: target,
          label: target_label,
          leaf: true
        });
    });
  }
  tree.push({parent: "root", id: "unclassified", label: "no known upstream TF"});
  woTfGenes.forEach((gene) => {
    let label = geneLabelMap.get(gene);
    if(!label)
      label = gene;
    tree.push(
      {
        parent: "unclassified",
        id: gene,
        label: label,
        leaf: true
      });
  });

  return tree;
}
```
