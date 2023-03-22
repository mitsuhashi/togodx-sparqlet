# UniProt catalytic_activity（井手）* 第二階層までテキスト挿入

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

SELECT DISTINCT ?leaf ?label ?parent #?ecclass ?ecclass1 ?ecclass2 ?ec_sub  #?eccode ?annotation
       #SELECT DISTINCT COUNT(?ec_sub) AS ?count ?ec_sub
 FROM <http://rdf.integbio.jp/dataset/togosite/uniprot>
 WHERE {
   ?leaf a up:Protein ;
            up:mnemonic ?label;
            up:proteome ?proteome;
            up:annotation ?annotation .
   ?annotation a up:Catalytic_Activity_Annotation;
            up:catalyticActivity/up:enzymeClass ?eccode .
   BIND(SUBSTR(STR(?eccode),32,99) AS ?ecclass) 
   BIND(SUBSTR(?ecclass, 1, STRLEN(?ecclass)-STRLEN(STRAFTER(STRAFTER(?ecclass ,"."),"."))-1) AS ?ec_sub)
   BIND(xsd:INTEGER(SUBSTR(?ecclass,1,1))*100 AS ?ecclass1)
   BIND(xsd:INTEGER(STRAFTER(?ec_sub,".")) AS ?ecclass2)
   BIND((?ecclass1+?ecclass2) AS ?parent)
   FILTER(REGEX(STR(?proteome), "UP000005640"))
}
#limit 10
```

## `results`

```javascript
({withAnnotation})=>{
  const idPrefix = "http://purl.uniprot.org/uniprot/";
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },  
    {
     id: "01",
     label: "Oxidoreductases",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "02",
     label: "Transferases",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "03",
     label: "Hydrolases",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "04",
     label: "Lyases",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "05",
     label: "Isomerases",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "06",
     label: "Ligase",
     leaf: false,
     parent: "root"                    
    },
    {  
     id: "07",
     label: "Translocase",
     leaf: false,
     parent: "root"                    
    },
    {  id: "101", label: "Acting on the CH-OH group of donors", leaf: false, parent: "01" },
    {  id: "102", label: "Acting on the aldehyde or oxo group of donors", leaf: false, parent: "01" },
    {  id: "103", label: "Acting on the CH-CH group of donors", leaf: false, parent: "01" },
    {  id: "104", label: "Acting on the CH-NH(2) group of donors", leaf: false, parent: "01" },
    {  id: "105", label: "Acting on the CH-NH group of donors", leaf: false, parent: "01" },
    {  id: "106", label: "Acting on NADH or NADPH", leaf: false, parent: "01" },
    {  id: "107", label: "Acting on other nitrogenous compounds as donors", leaf: false, parent: "01" },
    {  id: "108", label: "Acting on a sulfur group of donors", leaf: false, parent: "01" },
    {  id: "110", label: "Acting on diphenols and related substances as donors", leaf: false, parent: "01" },
    {  id: "111", label: "Acting on a peroxide as acceptor", leaf: false, parent: "01" },
    {  id: "113", label: "Acting on single donors with incorporation of molecular oxygen (oxygenases). The oxygen incorporated need not be derived from O(2)", leaf: false, parent: "01" },
    {  id: "114", label: "Acting on paired donors, with incorporation or reduction of molecular oxygen. The oxygen incorporated need not be derived from O(2)", leaf: false, parent: "01" },
    {  id: "115", label: "Acting on superoxide as acceptor", leaf: false, parent: "01" },
    {  id: "116", label: "Oxidizing metal ions", leaf: false, parent: "01" },
    {  id: "117", label: "Acting on CH or CH(2) groups", leaf: false, parent: "01" },
    {  id: "118", label: "Acting on iron-sulfur proteins as donors", leaf: false, parent: "01" },
    {  id: "120", label: "Acting on phosphorus or arsenic in donors", leaf: false, parent: "01" },
    {  id: "121", label: "Catalyzing the reaction X-H + Y-H = 'X-Y'", leaf: false, parent: "01" },
    {  id: "201", label: "Transferring one-carbon groups", leaf: false, parent: "02" },
    {  id: "202", label: "Transferring aldehyde or ketonic groups", leaf: false, parent: "02" },
    {  id: "203", label: "Acyltransferases", leaf: false, parent: "02" },
    {  id: "204", label: "Glycosyltransferases", leaf: false, parent: "02" },
    {  id: "205", label: "Transferring alkyl or aryl groups, other than methyl groups", leaf: false, parent: "02" },
    {  id: "206", label: "Transferring nitrogenous groups", leaf: false, parent: "02" },
    {  id: "207", label: "Transferring phosphorus-containing groups", leaf: false, parent: "02" },
    {  id: "208", label: "Transferring sulfur-containing groups", leaf: false, parent: "02" },
    {  id: "209", label: "Transferring selenium-containing groups", leaf: false, parent: "02" },
    {  id: "210", label: "Transferring molybdenum- or tungsten-containing groups", leaf: false, parent: "02" },
    { id: "301", label: "Acting on ester bonds", leaf: false, parent: "03" },
    { id: "302", label: "Glycosylases", leaf: false, parent: "03" },
    { id: "303", label: "Acting on ether bonds", leaf: false, parent: "03" },
    { id: "304", label: "Acting on peptide bonds (peptidases)", leaf: false, parent: "03" },
    { id: "305", label: "Acting on carbon-nitrogen bonds, other than peptide bonds", leaf: false, parent: "03" },
    { id: "306", label: "Acting on acid anhydrides", leaf: false, parent: "03" },
    { id: "307", label: "Acting on carbon-carbon bonds", leaf: false, parent: "03" },
    { id: "309", label: "Acting on phosphorus-nitrogen bonds", leaf: false, parent: "03" },
    { id: "310", label: "Acting on sulfur-nitrogen bonds", leaf: false, parent: "03" },
    { id: "401", label: "Carbon-carbon lyases", leaf: false, parent: "04" },
    { id: "402", label: "Carbon-oxygen lyases", leaf: false, parent: "04" },
    { id: "403", label: "Carbon-nitrogen lyases", leaf: false, parent: "04" },
    { id: "404", label: "Carbon-sulfur lyases", leaf: false, parent: "04" },
    { id: "406", label: "Phosphorus-oxygen lyases", leaf: false, parent: "04" },
    { id: "499", label: "Other lyases", leaf: false, parent: "04" },
    { id: "501", label: "Racemases and epimerases", leaf: false, parent: "05" },
    { id: "502", label: "Cis-trans-isomerases", leaf: false, parent: "05" },
    { id: "503", label: "Intramolecular oxidoreductases", leaf: false, parent: "05" },
    { id: "504", label: "Intramolecular transferases", leaf: false, parent: "05" },
    { id: "505", label: "Intramolecular lyases", leaf: false, parent: "05" },
    { id: "506", label: "Isomerases altering macromolecular conformation", leaf: false, parent: "05" },
    { id: "601", label: "Forming carbon-oxygen bonds", leaf: false, parent: "06" },
    { id: "602", label: "Forming carbon-sulfur bonds", leaf: false, parent: "06" },
    { id: "603", label: "Forming carbon-nitrogen bonds", leaf: false, parent: "06" },
    { id: "604", label: "Forming carbon-carbon bonds", leaf: false, parent: "06" },
    { id: "605", label: "Forming phosphoric ester bonds", leaf: false, parent: "06" },
    { id: "701", label: "Catalysing the translocation of hydrons", leaf: false, parent: "07" },
    { id: "702", label: "Catalysing the translocation of inorganic cations", leaf: false, parent: "07" },
    { id: "704", label: "Catalysing the translocation amino acids and peptides", leaf: false, parent: "07" },
    { id: "706", label: "Catalysing the translocation of other compounds", leaf: false, parent: "07" } 
  ];
  
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