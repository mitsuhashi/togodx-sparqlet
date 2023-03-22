# PDBエントリを結晶化時のpHで分類（井手）(10/27-pdb更新版)

## Description
 
- Data sources
    - The pH of crystal formation in the PDB entry
    - This item based on the data of January 20, 2021 of PDBj. 
        - The latest data can be obtained from the URL below. https://data.pdbj.org/pdbjplus/data/pdb/rdf/
- Query
    - Input
        - PDB ID
    - Output
        - The pH of crystal formation in each PDB entry.

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`

```sparql
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

  SELECT ?value ?leaf ?label
    WHERE {
     ?leaf     rdf:type	     pdbo:datablock .
     ?leaf     dc:title      ?label .
     ?leaf     pdbo:has_exptl_crystal_growCategory	?crystal_growCategory .
     ?crystal_growCategory pdbo:has_exptl_crystal_grow	        ?crystal_grow .
     ?crystal_grow         pdbo:exptl_crystal_grow.pH	        ?pH_str .
     BIND(((Round(10*(xsd:decimal(?pH_str))))/10) AS ?value)         
     }
```

# `binIDgen`

```sparql
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT DISTINCT ?labelseq #value ?leaf ?label
    WHERE {
     ?leaf     rdf:type	     pdbo:datablock .
     ?leaf     dc:title      ?label .
     ?leaf     pdbo:has_exptl_crystal_growCategory	?crystal_growCategory .
     ?crystal_growCategory pdbo:has_exptl_crystal_grow	        ?crystal_grow .
     ?crystal_grow         pdbo:exptl_crystal_grow.pH	        ?pH_str .
     BIND(((Round(10*(xsd:decimal(?pH_str))))/10) AS ?labelseq )        
     }
ORDER BY ?labelseq

```


## `results`

```javascript
({withAnnotation, binIDgen})=>{
  const idPrefix = "https://rdf.wwpdb.org/pdb/";
  
  let valarray=[];
  let valrank = [];
  let length = Object.keys(binIDgen.results.bindings).length;    //解像度の数値を持つ配列の長さをlengthに代入
  //console.log(length);
  //console.log(binIDgen.results.bindings);
  //console.log(Object.keys(binIDgen.results.bindings).length);
  let i =1;
  binIDgen.results.bindings.map(b => {							//binId,解像度の数値を持つ２次元配列を作成
    valrank=[ i, Number(b.labelseq.value)];
    valarray.push(valrank);
    i++;
  });
  //console.log(valarray);     
  
  return withAnnotation.results.bindings.map(d => {
    return {
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      value: Number(d.value.value),
      binId: binidgen(Number(d.value.value)),
      binLabel: "pH " + d.value.value
    }
  });
    function binidgen(s) {                                   //解像度からbinIdを導き出す関数を作成する関数
    let target = valarray.filter( e => e[1] === s );
    return target[0][0];
    }
}
```
