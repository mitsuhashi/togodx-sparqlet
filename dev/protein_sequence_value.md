# UniProt sequence （井手）* Uniprotの配列取得(テスト用) 

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The protein sequence of Uniprot

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `sequence`
```sparql
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX core: <http://purl.uniprot.org/core/>
SELECT DISTINCT ?leaf ?label ?value
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   #VALUES ?leaf {upid:Q8NET8}
   ?leaf a core:Protein;
         core:mnemonic ?label;
         core:sequence ?sequence;
         core:proteome ?proteome.
   FILTER(REGEX(STR(?proteome), "UP000005640"))   
   
   ?sequence rdf:type core:Simple_Sequence;
             rdf:value ?value .
   #?leaf core:reviewed 1 .
}
#ORDER BY ?leaf  #Order入れると、Sortの上限を超えるらしい。
limit 10
```

## `results`

```javascript
({sequence})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let tree = [];
  let id_match;
  let total_length = 0 ;
  sequence.results.bindings.map(d => {
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: d.value.value,
      binId: 1,
      binLabel: "N/A"
    })
   });
    return tree;
}
```