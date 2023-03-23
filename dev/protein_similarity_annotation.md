# UniProt similarity_annotation（井手）* 220114作業中

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The similarity (family) annotation in Uniprot

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `familygen`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

SELECT ?family
WHERE{ 
  #FILTER(?count>1) 
  			#count>1 のみにしたいが、Result部分で配列内に無い、count=1の値を入れるとエラーを吐く。
  {
  SELECT DISTINCT COUNT(?family) AS ?count ?family ?length#?uniprot  
  #SELECT DISTINCT ?leaf ?label ?family #?uniprot  
  FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
  WHERE {
     ?leaf a up:Protein;
            up:mnemonic ?label;
            up:reviewed true;        #reviewのみに絞った。
            up:proteome ?proteome;
            up:annotation ?annotation .
     ?annotation a up:Similarity_Annotation;
                 rdfs:comment ?comment .
     BIND(SUBSTR(?comment,16,150)AS ?family )
     FILTER(REGEX(STR(?proteome), "UP000005640"))
  }
}}
ORDER BY DESC(?count)
#limit 10
```

## `main`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

#SELECT ?family
#WHERE{ 
#  FILTER(?count>1) 
#  {
#  SELECT DISTINCT COUNT(?family) AS ?count ?family ?length#?uniprot  
SELECT DISTINCT ?leaf ?label ?family #?uniprot  
  FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
  WHERE {
     ?leaf a up:Protein;
            up:mnemonic ?label;
            up:reviewed true;        #reviewのみに絞った。
            up:proteome ?proteome;
            up:annotation ?annotation .
     ?annotation a up:Similarity_Annotation;
                 rdfs:comment ?comment .
     BIND(SUBSTR(?comment,16,150)AS ?family )
     FILTER(REGEX(STR(?proteome), "UP000005640"))
  }
#limit 10 # offset 8
#}}
#ORDER BY DESC(?count)
```


## `results`

```javascript
({familygen,main})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let other_num = 100;  //フロントに表示される数を指定。
  let length = Object.keys(familygen.results.bindings).length;
  let i =1;
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];
  familygen.results.bindings.map(d => {
    if (i < other_num ){ 
    	tree.push({
      		id: String(i),
      		label: d.family.value,
      		leaf: "false",
      		parent: "root"
    	})
    }else if (i == other_num){
    	tree.push({
      		id: String(other_num),
      		label: "Other",
      		leaf: "false",
      		parent: "root"
    	})
        tree.push({
      		id: String(i+1),
      		label: d.family.value,
      		leaf: "false",
      		parent: String(other_num)
    	})
     }else {
    	tree.push({
      		id: String(i+1),
      		label: d.family.value,
      		leaf: "false",
      		parent: String(other_num)
    	})
     }
     i++;
  });
//  console.log(tree[1].label);
//  console.log(parentgen("G-protein coupled receptor 1 family."));
//  return tree;
  
  main.results.bindings.map(e => {
    tree.push({
        id: e.leaf.value.replace(idPrefix, ""),
        label: e.label.value,
        leaf: "true",
        //parent: e.family.value
        parent: parentgen(e.family.value)
      })
  });
  return tree;
   function parentgen(s){
     let target = tree.filter( f => f["label"] === s)
     return target[0].id ;
   }
}
```