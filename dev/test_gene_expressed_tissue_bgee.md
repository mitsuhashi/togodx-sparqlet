# Genes expressed in tissues (Bgee) (池田, 守屋)

- <font style="color:red">データが大きくなりすぎて SPARQList サーバが落ちるので動かさない</font>
- uberon　毎に取得

## Description

- Data sources
    - Bgee latest version: [https://bgee.org/?page=sparql](https://bgee.org/?page=sparql)

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `graph`
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX obo: <http://purl.obolibrary.org/obo/>
SELECT DISTINCT ?child ?child_label ?parent ?parent_label
FROM <http://rdf.integbio.jp/dataset/togosite/uberon>
WHERE {
  ?parent rdfs:label ?parent_label ;
     ^rdfs:subClassOf ?child .
   ?child rdfs:label ?child_label .
  ?parent rdfs:subClassOf* obo:BFO_0000004 .
}
```

## `return`
```javascript
async ({graph})=>{
  let fetchReq = async (obo)=>{
    console.log(obo);
    const options = {
      method: 'POST',
      bodt: 'obo=' + obo,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }
    return await fetch("test_gene_expressed_tissue_bgee_backend", options).then(res=>res.json());
  }
  
  let tree = [
    {
      id: "BFO_0000004",
      label: "independent continuant"
    }
  ]
  
  let onto = {};
  for (const d of graph.results.bindings) {
    let anat = d.child.value.replace("http://purl.obolibrary.org/obo/", "");
    if (! onto[anat]) {
      onto[anat] = true;
      tree.push({
        id: anat,
        label: d.child_label.value,
        parent: d.parent.value.replace("http://purl.obolibrary.org/obo/", "")
      });
      let json = await fetchReq(anat);
      if (json[0]) tree = tree.concat(json);
    }
  }
  return tree;
};
```
