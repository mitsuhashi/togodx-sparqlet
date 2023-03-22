# UniProt beta strand regions（井手・千葉）* beta strandの合計長をタンパク質全長における割合で示す

## Description
- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - Regions of Beta_Strand_Annotation in UniProt

## Parameters
* `categoryIds` -(type:Annotation)
  * default: Beta_Strand_Annotation
  * example: Helix_Annotation

## `annotation_types`
- annotation 選択
```javascript
({ categoryIds }) => {
  categoryIds = categoryIds.replace(/,/g," ")
  if (categoryIds.match(/[^\s]/)) {
    return categoryIds.split(/\s+/);
  }
}
```

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `main`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX faldo: <http://biohackathon.org/resource/faldo#>

SELECT DISTINCT ?uniprot ?mnemonic ?seq_length ?region_length ?begin_position ?end_position
FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
WHERE {
  VALUES ?annotation_type { {{#each annotation_types}} up:{{this}} {{/each}} } 
  ?uniprot up:proteome ?proteome_subset ;
      up:mnemonic ?mnemonic;
      up:annotation ?annotation .
  ?annotation a ?annotation_type ;
      up:range ?range .
  ?range faldo:begin/faldo:position ?begin_position ;
         faldo:end/faldo:position ?end_position .
  ?range faldo:begin/faldo:reference/rdf:value ?seq .
  BIND(STRLEN(?seq) AS ?seq_length)
  BIND((?end_position - ?begin_position + 1) AS ?region_length)
  FILTER(REGEX(STR(?proteome_subset), "UP000005640"))
}
ORDER BY ?uniprot ?begin_position
```

## `results`
```javascript
({ main }) => {
  let tree = [];
  let mnemonic = new Map();
  let seqLen = new Map();
  let regionLen = new Map();
  main.results.bindings.map(d => {
    const id = d.uniprot.value.replace('http://purl.uniprot.org/uniprot/', '');
    mnemonic.set(id, d.mnemonic.value);
    seqLen.set(id, Number(d.seq_length.value));
    if (regionLen.has(id)) {
      regionLen.set(id, Number(d.region_length.value) + regionLen.get(id));
    } else {
      regionLen.set(id, Number(d.region_length.value));
    }
  });
  regionLen.forEach((len, id) => {
    const pct = Math.round(len / seqLen.get(id) * 100);
    tree.push({
      id: id,
      label: mnemonic.get(id),
      value: pct,
      binId: pct + 1,
      binLabel: pct + "%"
    })
  });
  return tree;
}
```
