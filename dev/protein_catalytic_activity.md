# UniProt catalytic_activity（井手）* 220125 EC番号をラベルに変更

## Description

- Data sources
    - [UniProt](https://www.uniprot.org/)

- Query
    - Input
        - UniProt ID
    - Output
        - The Catalytic activity based on EC number

## Endpoint
{{SPARQLIST_TOGODX_SPARQL}}

## `withAnnotation`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT DISTINCT ?leaf ?label ?parent 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
            up:mnemonic ?label;
            up:proteome ?proteome;
            up:annotation ?annotation .
   FILTER(REGEX(STR(?proteome), "UP000005640"))
   {
   ?annotation a up:Catalytic_Activity_Annotation;
            up:catalyticActivity/up:enzymeClass ?eccode .
   BIND(SUBSTR(STR(?eccode),32,99) AS ?value) 
   BIND(SUBSTR(?value, 1, STRLEN(?value)-STRLEN(STRAFTER(STRAFTER(?value ,"."),"."))-1) AS ?ec_sub)
   BIND(SUBSTR(?value, STRLEN(?ec_sub)+2,99) AS ?ec_sub2)
   BIND(xsd:INTEGER(SUBSTR(?value,1,1))*10000000 AS ?ecclass1)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub,"."))*100000 AS ?ecclass2)
   BIND(xsd:INTEGER(STRBEFORE(?ec_sub2,"."))*1000 AS ?ecclass3)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub2,".")) AS ?ecclass4)
   Filter(isNumeric(?ecclass4))
   BIND((?ecclass1+?ecclass2+?ecclass3+?ecclass4) AS ?parent1)
   }UNION{
   ?annotation a up:Catalytic_Activity_Annotation;
            up:catalyticActivity/up:enzymeClass ?eccoden .
   BIND(SUBSTR(STR(?eccoden),32,99) AS ?valuen) 
   BIND(SUBSTR(?valuen, 1, STRLEN(?valuen)-STRLEN(STRAFTER(STRAFTER(?valuen ,"."),"."))-1) AS ?ec_subn)
   BIND(SUBSTR(?valuen, STRLEN(?ec_subn)+2,99) AS ?ec_sub2n)
   BIND(xsd:INTEGER(SUBSTR(?valuen,1,1))*10000000 AS ?ecclass1n)
   BIND(xsd:INTEGER(STRAFTER(?ec_subn,"."))*100000 AS ?ecclass2n)
   BIND(xsd:INTEGER(STRBEFORE(?ec_sub2n,"."))*1000 AS ?ecclass3n)
   BIND((STRAFTER(?ec_sub2n,".")) AS ?ecclass4n)
   Filter(CONTAINS(?ecclass4n,"n"))
   BIND((CONCAT(?ecclass1n+?ecclass2n+?ecclass3n,STR(?ecclass4n))) AS ?parent2)
   }
   BIND(CONCAT(?parent1,?parent2) AS ?parent)
}
#limit 10
```

## `SecondClass`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT DISTINCT ?child ?label ?ecclass1
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
           up:proteome ?proteome;
           up:annotation ?annotation .
   ?annotation a up:Catalytic_Activity_Annotation;
               up:catalyticActivity/up:enzymeClass ?eccode .
   BIND(SUBSTR(STR(?eccode),32,99) AS ?value) 
   BIND(SUBSTR(?value, 1, STRLEN(?value)-STRLEN(STRAFTER(STRAFTER(?value ,"."),"."))-1) AS ?ec_sub)
   #BIND(SUBSTR(?value, STRLEN(?ec_sub)+2,99) AS ?ec_sub2)
   BIND(xsd:INTEGER(SUBSTR(?value,1,1))*10000000 AS ?ecclass1)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub,"."))*100000 AS ?ecclass2)
   BIND(xsd:INTEGER(STRBEFORE(?ec_sub2,"."))*1000 AS ?ecclass3)
   #BIND(xsd:INTEGER(STRAFTER(?ec_sub2,".")) AS ?ecclass4)
   #BIND((?ecclass1+?ecclass2+?ecclass3+?ecclass4) AS ?parent)
   BIND(CONCAT( STR(?ec_sub),".-.-") AS ?label)
   BIND((?ecclass1+?ecclass2) AS ?child)
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
Order by ?child
```

## `ThirdClass`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT DISTINCT ?child ?label ?parent
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
           up:proteome ?proteome;
           up:annotation ?annotation .
   ?annotation a up:Catalytic_Activity_Annotation;
               up:catalyticActivity/up:enzymeClass ?eccode .
   BIND(SUBSTR(STR(?eccode),32,99) AS ?value) 
   BIND(SUBSTR(?value, 1, STRLEN(?value)-STRLEN(STRAFTER(STRAFTER(?value ,"."),"."))-1) AS ?ec_sub)
   BIND(SUBSTR(?value, STRLEN(?ec_sub)+2,99) AS ?ec_sub2)
   BIND(xsd:INTEGER(SUBSTR(?value,1,1))*10000000 AS ?ecclass1)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub,"."))*100000 AS ?ecclass2)
   BIND(xsd:INTEGER(STRBEFORE(?ec_sub2,"."))*1000 AS ?ecclass3)
   #BIND(xsd:INTEGER(STRAFTER(?ec_sub2,".")) AS ?ecclass4)
   #BIND((?ecclass1+?ecclass2+?ecclass3+?ecclass4) AS ?parent)
   BIND(CONCAT( STR(?ec_sub),".",STRBEFORE(?ec_sub2,"."),".-") AS ?label)
   BIND((?ecclass1+?ecclass2+?ecclass3) AS ?child)
   BIND((?ecclass1+?ecclass2) AS ?parent)
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
Order by ?child
```

## `FourthClass`
```sparql
PREFIX up: <http://purl.uniprot.org/core/>
PREFIX upid: <http://purl.uniprot.org/uniprot/>
PREFIX taxon: <http://purl.uniprot.org/taxonomy/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#> 

SELECT DISTINCT ?child ?value ?parent 
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
           up:proteome ?proteome;
           up:annotation ?annotation .
   ?annotation a up:Catalytic_Activity_Annotation;
               up:catalyticActivity/up:enzymeClass ?eccode .
   BIND(SUBSTR(STR(?eccode),32,99) AS ?value) 
   BIND(SUBSTR(?value, 1, STRLEN(?value)-STRLEN(STRAFTER(STRAFTER(?value ,"."),"."))-1) AS ?ec_sub)
   BIND(SUBSTR(?value, STRLEN(?ec_sub)+2,99) AS ?ec_sub2)
   BIND(xsd:INTEGER(SUBSTR(?value,1,1))*10000000 AS ?ecclass1)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub,"."))*100000 AS ?ecclass2)
   BIND(xsd:INTEGER(STRBEFORE(?ec_sub2,"."))*1000 AS ?ecclass3)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub2,".")) AS ?ecclass4)
   FILTER(isNumeric(?ecclass4))
   BIND((?ecclass1+?ecclass2+?ecclass3+?ecclass4) AS ?child)
   BIND((?ecclass1+?ecclass2+?ecclass3) AS ?parent)
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
Order by ?child
```

## `results`

```javascript
({withAnnotation,SecondClass,ThirdClass,FourthClass})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let tree = [
    {id: "root", label: "root node", root: true},  
    {id: "10000000", label: "Oxidoreductases", leaf: false, parent: "root"},
    {id: "20000000", label: "Transferases",    leaf: false, parent: "root"},
    {id: "30000000", label: "Hydrolases",      leaf: false, parent: "root"},
    {id: "40000000", label: "Lyases",          leaf: false, parent: "root"},
    {id: "50000000", label: "Isomerases",      leaf: false, parent: "root"},
    {id: "60000000", label: "Ligase",          leaf: false, parent: "root"},
    {id: "70000000", label: "Translocase",     leaf: false, parent: "root"},
    {id: "11411000n4", label: "1.14.11.n4",    leaf: false, parent: "11411000"},
    {id: "10101000n12", label: "1.1.1.n12",    leaf: false, parent: "10101000"},
    {id: "30126000n2", label: "3.1.26.n2",     leaf: false, parent: "30126000"},
    {id: "20301000n6", label: "2.3.1.n6",      leaf: false, parent: "20301000"},
    {id: "20301000n7", label: "2.3.1.n7",      leaf: false, parent: "20301000"},
    {id: "20802000n2", label: "2.8.2.n2",      leaf: false, parent: "20802000"},
    {id: "20707000n1", label: "2.7.7.n1",      leaf: false, parent: "20707000"},
    {id: "20101000n8", label: "2.1.1.n8",      leaf: false, parent: "20101000"},
    {id: "11411000n2", label: "1.14.11.n2",    leaf: false, parent: "11411000"},
    {id: "60201000n3", label: "6.2.1.n3",      leaf: false, parent: "60201000"},
    {id: "11413000n7", label: "1.14.13.n7",    leaf: false, parent: "11413000"},
    {id: "10101000n11", label: "1.1.1.n11",    leaf: false, parent: "10101000"},
    {id: "60302000n3", label: "6.3.2.n3",      leaf: false, parent: "60302000"},
    {id: "40102000n2", label: "4.1.2.n2",      leaf: false, parent: "40102000"}   
  ];
  
  SecondClass.results.bindings.map(e => {
    tree.push({
      id: e.child.value,
      label: e.label.value,
      leaf: false,
      parent: e.ecclass1.value
    })
  });
  
  ThirdClass.results.bindings.map(f => {
    tree.push({
      id: f.child.value,
      label: f.label.value,
      leaf: false,
      parent: f.parent.value
    })
  });
  
  FourthClass.results.bindings.map(g => {
    tree.push({
      id: g.child.value,
      label: g.value.value,
      leaf: false,
      parent: g.parent.value
    })
  });
  
  withAnnotation.results.bindings.map(d => {
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      leaf: true,
      parent: d.parent.value
    })
  });
  return tree;
}
```