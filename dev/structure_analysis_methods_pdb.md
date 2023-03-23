# PDBエントリを実験手法で分類 (井手)

## Description
 
- Data sources
    - Experimental methods used for 3D structure acquisition in the PDB entry.
    - This item based on the data of January 20, 2021 of PDBj. 
        - The latest data can be obtained from the URL below. https://data.pdbj.org/pdbjplus/data/pdb/rdf/
- Query
    - Input
        - PDB ID
    - Output
        - The experimental method in each entry.

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `data`
```sparql
PREFIX pdbr: <http://rdf.wwpdb.org/pdb/>
PREFIX pdbo: <http://rdf.wwpdb.org/schema/pdbx-v50.owl#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>

SELECT DISTINCT ?leaf ?label ?parent                
   WHERE {
          ?leaf       rdf:type	               pdbo:datablock .
          ?leaf       dc:title  	           ?label .
          ?leaf       pdbo:has_exptlCategory   ?exptlCategory .
          ?exptlCategory  rdf:type                 pdbo:exptlCategory .
          ?exptlCategory  pdbo:has_exptl	       ?exptl .
          ?exptl          pdbo:exptl.method	       ?methods .
          BIND(REPLACE(?methods, " ", "_") AS ?parent)
         }
```

## `return`

```javascript
({data})=>{
  const idPrefix = "http://rdf.wwpdb.org/pdb/";
  
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    },  
    {
    "id": "01",
    "label": "X-ray diffraction",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "02",
    "label": "Solution NMR",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "03",
    "label": "Electron microscopy",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "04",
    "label": "Neutron diffraction",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "05",
    "label": "Electron crystallography",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "06",
    "label": "Solid-state NMR",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "07",
    "label": "Solution scattering",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "08",
    "label": "Fiber diffraction",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "09",
    "label": "Powder diffraction",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "10",
    "label": "EPR",
    "leaf": false,
    "parent": "root"                    
     },
     {  
    "id": "11",
    "label": "Theoretical model",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "12",
    "label": "Infrared spectroscopy",
    "leaf": false,
    "parent": "root"                    
    },
    {  
    "id": "13",
    "label": "Fluorescence transfer",
    "leaf": false,
    "parent": "root"                    
    }
  ];
  
  data.results.bindings.map(d => {
	let parent_id = d.parent.value;
 	if (parent_id  == "X-RAY_DIFFRACTION") {parent_id = "01";}
	else if (parent_id == "SOLUTION_NMR") {parent_id = "02";}
	else if (parent_id == "ELECTRON_MICROSCOPY") {parent_id = "03";}
	else if (parent_id == "NEUTRON_DIFFRACTION") {parent_id = "04";}
	else if (parent_id == "ELECTRON_CRYSTALLOGRAPHY") {parent_id = "05";}
	else if (parent_id == "SOLID-STATE_NMR") {parent_id = "06";}
	else if (parent_id == "SOLUTION_SCATTERING") {parent_id = "07";}
	else if (parent_id == "FIBER_DIFFRACTION") {parent_id = "08";}
	else if (parent_id == "POWDER_DIFFRACTION") {parent_id = "09";}
	else if (parent_id == "EPR") {parent_id = "10";}
	else if (parent_id == "THEORETICAL_MODEL") {parent_id = "11";}
	else if (parent_id == "INFRARED_SPECTROSCOPY") {parent_id = "12";}
	else {
       parent_id = "13"; 
    }
         
    tree.push({
      id: d.leaf.value.replace(idPrefix, ""),
      label: d.label.value,
      leaf: true,
      parent: parent_id
    })
  });
  
  return tree;
  
}
```