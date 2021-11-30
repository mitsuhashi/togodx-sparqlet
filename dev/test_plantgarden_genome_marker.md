# PlantGarden taxonomy-genome-chr-marker (信定)

## Endpoint
https://mb2.ddbj.nig.ac.jp/sparql

## `leaf`
- chr と marker のアノテーション関係
```sparql
prefix pg_ns: <https://plantgardden.jp/ns/>
prefix dcterms: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select distinct ?leaf_marker_id ?leaf_marker_label  ?parent_chr 
where {
?s a  pg_ns:Marker ;
dcterms:identifier ?leaf_marker_id ;
rdfs:label ?leaf_marker_label ;
pg_ns:chr ?parent_chr .
} 
limit 10000
```

## `chr_genome`
- 親子関係
```sparql
prefix pg_ns: <https://plantgardden.jp/ns/>
prefix dcterms: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select distinct ?s ?parent_chr   ?parent_genome_identifier ?parent_genome_label
where {
?s a  pg_ns:Marker ;
pg_ns:genome ?parent_genome ;
pg_ns:chr ?parent_chr .
?parent_genome a  pg_ns:Genome ;
dcterms:identifier ?parent_genome_identifier ;
rdfs:label ?parent_genome_label .
}
limit 10000
```

## `genome_subspecies`
- 親子関係
```sparql
prefix pg_ns: <https://plantgardden.jp/ns/>
prefix dcterms: <http://purl.org/dc/terms/>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
select distinct ?s ?parent_genome_identifier ?parent_genome_label  ?top_subspecies_identifier  ?top_subspecies_label 
where {
?s a  pg_ns:Marker ;
pg_ns:genome ?parent_genome  .
?parent_genome a  pg_ns:Genome ;
dcterms:identifier ?parent_genome_identifier ;
rdfs:label ?parent_genome_label ;
pg_ns:subspecies ?top_genome_subspecies .
 ?top_genome_subspecies  a   pg_ns:Subspecies  ;
dcterms:identifier ?top_subspecies_identifier ;
rdfs:label ?top_subspecies_label .
FILTER (lang(?top_subspecies_label) = "en" )
}
limit 10000
```

## `return`
```javascript
({ leaf, chr_genome, genome_subspecies}) => {
  
 let tree = [
    {
      id: "root",
      label: "root node",
      root: true
    }
  ];
  
  let edge = {};
  leaf.results.bindings.map(d => {
    tree.push({
      id: d.leaf_marker_id.value,
      label: d.leaf_marker_label.value,
      leaf: true,
      parent: d.parent_chr.value
    })
   // genome_subspeciesの親子関係を追加
    if (!edge[d.parent_chr.value]) {
      edge[d.parent_chr.value] = true;
      tree.push({   
        id: d.parent_chr.value,
        label: d.parent_chr.value,
        leaf: false,
        parent: d.top_subspecies_identifier.value
      })
    }
  });
  return tree;
};
```