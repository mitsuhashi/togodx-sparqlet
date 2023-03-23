# variant clinical significance (三橋）

## Description

- Data sources
    -  [TogoVar](https://togovar.biosciencedbc.jp/?) (limited to variants with frequency data in Japanese populations)
- Query
    - Input
        - TogoVar id
    - Output
        -   [Clinical significance of ClinVar](https://www.ncbi.nlm.nih.gov/clinvar/docs/clinsig/)

## Endpoint

{{SPARQLIST_TOGODX_SPARQL}}

## `leaf`

```sparql
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX tgvo: <http://togovar.biosciencedbc.jp/vocabulary/>
PREFIX cvo: <http://purl.jp/bio/10/clinvar/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX dct: <http://purl.org/dc/terms/>
PREFIX gvo: <http://genome-variation.org/resource#>

SELECT DISTINCT ?tgv_id ?rs_id ?category
FROM <http://rdf.integbio.jp/dataset/togosite/variation>
FROM <http://rdf.integbio.jp/dataset/togosite/variation/annotation/clinvar>
WHERE {
   GRAPH <http://rdf.integbio.jp/dataset/togosite/variation>{
     ?togovar dct:identifier ?tgv_id.
   }
   GRAPH <http://rdf.integbio.jp/dataset/togosite/variation/annotation/clinvar>{
     ?togovar gvo:info ?info_rs.
     ?info_rs rdfs:label ?rs_label.
     ?info_rs rdf:value ?rs_id.
     FILTER(?rs_label IN ("RS")).
     ?togovar gvo:info ?info_clinvar.
     ?info_clinvar rdfs:label ?clinvar_label.
     ?info_clinvar rdf:value ?category.
     FILTER(?clinvar_label IN ("CLNSIG")).
   }
}
```

## `return`

```javascript
({leaf}) => {  
  const childLabelPrefix = "http://identifiers.org/dbsnp/";
  let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];
 var id2label = {};
  id2label["affects"] = "Affects"
  id2label["association_not_found"] = "association not found"
  id2label["association"] = "association"
  id2label["benign_or_likely_benign_other"] = "Benign/Likely benign, other"
  id2label["benign_or_likely_benign_risk_factor"] = "Benign/Likely benign, risk factor"
  id2label["benign_or_likely_benign"] = "Benign/Likely benign"
  id2label["benign_other"] = "Benign, other"
  id2label["benign_risk_factor"] = "Benign, risk factor"
  id2label["benign"] = "Benign"
  id2label["confers_sensitivity"] = "confers sensitivity"
  id2label["conflicting_interpretations_of_pathogenicity_association_risk_factor"] = "Conflicting interpretations of pathogenicity, association, risk factor"
  id2label["conflicting_interpretations_of_pathogenicity_association"] = "Conflicting interpretations of pathogenicity, association"
  id2label["conflicting_interpretations_of_pathogenicity_other"] = "Conflicting interpretations of pathogenicity, other"
  id2label["conflicting_interpretations_of_pathogenicity_risk_factor"] = "Conflicting interpretations of pathogenicity, risk factor"
  id2label["conflicting_interpretations_of_pathogenicity"] = "Conflicting interpretations of pathogenicity"
  id2label["drug_response"] = "drug response"
  id2label["likely_benign_other"] = "Likely benign, other"
  id2label["likely_benign_risk_factor"] = "Likely benign, risk factor"
  id2label["likely_benign"] = "Likely benign"
  id2label["likely_pathogenic_affects"] = "Likely pathogenic, Affects"
  id2label["likely_pathogenic_other"] = "Likely pathogenic, other"
  id2label["likely_pathogenic_risk_factor"] = "Likely pathogenic, risk factor"
  id2label["likely_pathogenic"] = "Likely pathogenic"
  id2label["not_provided"] = "not provided"
  id2label["other_risk_factor"] = "other, risk factor"
  id2label["other"] = "other"
  id2label["pathogenic_affects"] = "Pathogenic, Affects"
  id2label["pathogenic_association"] = "Pathogenic, association"
  id2label["pathogenic_drug_response"] = "Pathogenic, drug response"
  id2label["pathogenic_or_likely_pathogenic_association"] = "Pathogenic/Likely pathogenic, association"
  id2label["pathogenic_or_likely_pathogenic_other"] = "Pathogenic/Likely pathogenic, other"
  id2label["pathogenic_or_likely_pathogenic_risk_factor"] = "Pathogenic/Likely pathogenic, risk factor"
  id2label["pathogenic_or_likely_pathogenic"] = "Pathogenic/Likely pathogenic"
  id2label["pathogenic_other"] = "Pathogenic, other"
  id2label["pathogenic_risk_factor"] = "Pathogenic, risk factor"
  id2label["pathogenic"] = "Pathogenic"
  id2label["protective"] = "protective"
  id2label["risk_factor"] = "risk factor"
  id2label["uncertain_significance_affects"] = "Uncertain significance, Affects"
  id2label["uncertain_significance_other"] = "Uncertain significance, other"
  id2label["uncertain_significance_other_risk_factor"] = "Uncertain significance, other, risk factor"
  id2label["uncertain_significance_risk_factor"] = "Uncertain significance, risk factor"
  id2label["uncertain_significance"] = "Uncertain significance"
  
  // 親子関係
  for(let id in id2label){
    tree.push({
      id: id,
      label: id2label[id],
      parent: "root"
    })
  }
  // アノテーション関係
  leaf.results.bindings.map(d => {
    const parent = d.category.value.toLowerCase().replace(";",",").replace("/", "_or_").replace(/,?\s+/g, "_")
    if(!id2label[parent]){ return; }   // 親(id2label)にエントリがない子供は無視する。
    tree.push({
      id: d.tgv_id.value,
      label: "rs" + d.rs_id.value,
      leaf: true,
      parent: parent
    });
  })
  return tree;	
}
```