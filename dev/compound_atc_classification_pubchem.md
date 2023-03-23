# PubChem で薬を薬効で分類（FDA Approved Drugs → WHO ATC Code）(Annotationのない化合物を数えていない＝もとのまま)（建石, 守屋, 山本）
- 分母をどう取ればよいか
	- 全化合物：SPARQLがタイムアウトした
	- FDA Approved Drugsを数えればよいかと思ったが、ATCコードがあってFDA Approved Drugsでないものが存在した

## Description

- Data sources
	- PubChem-RDF: ftp://ftp.ncbi.nlm.nih.gov/pubchem/RDF/ 
        - Data for nodes linked to ChEMBL or ChEBI retrieved from https://integbio.jp/rdf/dataset/pubchem

- Query
	- Input
  		- PubChem Compound ID 
	- Output
    	- WHO ATC code (https://www.whocc.no/atc_ddd_index/)

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## Parameters

## `data`

```sparql
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX compound: <http://rdf.ncbi.nlm.nih.gov/pubchem/compound/CID>
PREFIX concept: <http://rdf.ncbi.nlm.nih.gov/pubchem/concept/ATC_>
PREFIX pubchemv: <http://rdf.ncbi.nlm.nih.gov/pubchem/vocabulary#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT ?cid ?pubchem_label ?atc ?atc_label 
    WHERE {
      #test
      #VALUES ?cid {  compound:3561  compound:6957673  compound:3226  compound:452548  compound:19861  
      #               compound:41781  compound:4909  compound:15814656  compound:13342  compound:11597698  
      #            }                  
                   
 	
      ?attr a sio:CHEMINF_000562 ;
            sio:is-attribute-of ?cid ; 
            sio:has-value  ?inn ;
            dcterms:subject ?atc .
      ?atc  a skos:concept .  
      ?cid sio:has-attribute  [a sio:CHEMINF_000382; sio:has-value ?pubchem_label_temp  ] .


      BIND(IF(bound(?pubchem_label_temp), ?pubchem_label_temp,"null") AS ?pubchem_label)      
} 
```


## `atcGraph`

```sparql
PREFIX sio: <http://semanticscience.org/resource/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX compound: <http://rdf.ncbi.nlm.nih.gov/pubchem/compound/CID>
PREFIX concept: <http://rdf.ncbi.nlm.nih.gov/pubchem/concept/ATC_>
PREFIX pubchemv: <http://rdf.ncbi.nlm.nih.gov/pubchem/vocabulary#>
PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
SELECT DISTINCT  ?atc ?atc_label ?parent ?parent_label
    WHERE {
      #VALUES ?atctop {  concept:A    
      #            }                  

      ?atc  skos:broader* ?atctop ;
            skos:prefLabel  ?atc_label;
  		    a skos:concept .  # ATC分類である
      OPTIONAL {
      	?atc skos:broader ?parent .      
      	?parent skos:prefLabel  ?parent_label .
        FILTER (?atc != ?parent)
        }
} ORDER BY ?atc
```

## `return`
- 整形

```javascript
({data,atcGraph})=>{
  const idVarName = "cid";
  const idPrefix = "http://rdf.ncbi.nlm.nih.gov/pubchem/compound/CID";
  const idLabelName="pubchem_label";
  const categoryVarName = "atc";
  const categoryLabelVarName = "atc_label";
  const categoryPrefix = "http://rdf.ncbi.nlm.nih.gov/pubchem/concept/ATC_";
  const withoutId = "unclassified";
  
  function capitalize(str) {
    return str.charAt(0).toUpperCase() + str.substring(1);
  }
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },
    {
      id: withoutId,
      label: "without annotation",
      parent: "root"
    }
  ];
  
  let atcLabel={}
  atcGraph.results.bindings.map(d=>{
    atcLabel[d.atc.value]=d.atc_label.value
  });
   
  // Annotation
  data.results.bindings.map(d=>{
    tree.push({
      id: d[idVarName].value.replace(idPrefix, ""), 
      label: d[idLabelName].value,
      leaf: true,
      parent: d[categoryVarName].value.replace(categoryPrefix, ""), 
    })
  })
  
  //Category tree
  atcGraph.results.bindings.map(d=>{
    let child=d[categoryVarName].value.replace(categoryPrefix, "")
    if (child.length==1){
      tree.push({     
        id: child,
        label: d.atc_label.value,
        leaf: false,
        parent: "root",
      })
    } else {    
      tree.push({     
        id: child,
        label: d.atc_label.value,
        leaf: false,
        parent: d.parent.value.replace(categoryPrefix, "")
      })
    }  
  })
  
  
  
  return tree ;
}
```




