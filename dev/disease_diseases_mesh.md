# Diseases in MeSH （三橋）

## Description

- Data sources
    -  [Medical Subject Headings (MeSH)](https://www.nlm.nih.gov/mesh/meshhome.html) 
- Query
    - Input
        - MeSH Descriptor
    - Output
        -  [Diseases ([C])](https://meshb.nlm.nih.gov/treeView) and its subcategories of MeSH

## Parameters

* `root` (type: MeSH) (Req.)
  * default: C
  * example: C (Diseases) 、C04  (Neoplasms) https://meshb.nlm.nih.gov/record/ui?ui=D009369

* `categoryIds` (type: mesh tree number)
  * default: C
  * example: C04  (Neoplasms) https://meshb.nlm.nih.gov/record/ui?ui=D009369
* `queryIds` (type: mesh descriptor number)
  * default: 
  * example: D017091,D004067,D042882,D053706,D007516



## Endpoint
https://integbio.jp/togosite/sparql

## `data`
- mesh D番号 と目的 tree 階層の対応表
  - Top レベルだけ例外処理
```sparql
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX mesh: <http://id.nlm.nih.gov/mesh/>
PREFIX meshv: <http://id.nlm.nih.gov/mesh/vocab#>
PREFIX tree: <http://id.nlm.nih.gov/mesh/>
{{#if mode}}
SELECT DISTINCT ?mesh ?tree AS ?category ?label
{{else}}
SELECT DISTINCT ?tree AS ?category ?label (COUNT(DISTINCT ?mesh) AS ?count)
{{/if}}
FROM <http://rdf.integbio.jp/dataset/togosite/mesh>
WHERE {
{{#if top}}
  ?tree a meshv:TreeNumber .
  MINUS { 
    ?tree meshv:parentTreeNumber ?parent . 
  }
  FILTER (CONTAINS(STR(?tree),"mesh/{{categoryIds}}"))
{{else}}
  {{#if mode}}
  VALUES ?tree { {{#each categoryArray}} tree:{{this}} {{/each}} }
  {{else}}
  VALUES ?parent { {{#each categoryArray}} tree:{{this}} {{/each}} }
  ?tree meshv:parentTreeNumber ?parent .
  {{/if}}
{{/if}}
{{#if queryArray}}
  VALUES ?mesh { {{#each queryArray}} mesh:{{this}} {{/each}} }
{{/if}}
   ?tree ^meshv:treeNumber/rdfs:label ?label .
   ?mesh meshv:treeNumber/meshv:parentTreeNumber* ?tree .
   FILTER(lang(?label) = "en")
}
{{#unless mode}}  
  ORDER BY DESC(?count)
{{/unless}}                  
```

## `return`
- 整形
```javascript
({mode, data})=>{
  const idVarName = "mesh";
  const idPrfix = "http://id.nlm.nih.gov/mesh/";
  const categoryPrefix = "http://id.nlm.nih.gov/mesh/";
  if (mode == "objectList") return data.results.bindings.map(d=>{
    return {
      id: d[idVarName].value.replace(idPrfix, ""), 
      attribute: {
        categoryId: d.category.value.replace(categoryPrefix, ""), 
        uri: d.category.value,
        label : d.label.value
      }
    }
  });
  if (mode == "idList") return Array.from(new Set(data.results.bindings.map(d=>d[idVarName].value.replace(idPrfix, "")))); // unique

  return data.results.bindings.map(d=>{ 
    return {
      categoryId: d.category.value.replace(categoryPrefix, ""), 
      label: d.label.value,
      count: Number(d.count.value),
 //     hasChild: Boolean(d.child)
      hasChild: (Number(d.count.value) > 1 ? true : false)
    };
  });	
}
```