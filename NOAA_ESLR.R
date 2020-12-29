rm(list=ls()) # Clears workspace

#system("sudo apt install librsvg2-dev libv8-dev -y") # Install linux dependency for rsvg 


PKG <- c("DiagrammeR","renv","rsvg", "DiagrammeRsvg")

for (p in PKG) {
  if(!require(p,character.only = TRUE)) {  
    install.packages(p)
    require(p,character.only = TRUE)}
}
rm(PKG,p)
renv::snapshot()

## Graph

# a_graph <-
#   create_graph() %>%
#   add_node(label = "as", 
#            node_aes = node_aes(shape = "rectangle",
#                                color = "steelblue",
#                                fillcolor = "lightblue",
#                                fontcolor = "gray35")) %>%
#   add_node() %>%
#   add_node() %>%
#   add_node() %>%
#   add_edge(from = 1, to = 2, 
#            edge_aes = edge_aes(color = "red",
#                                arrowhead = "vee",
#                                tooltip = "Red Arrow")) %>%
#   add_edge(from = 2, to = 3) %>%
#   add_edge(from = 3, to = 4)
# 
# render_graph(a_graph, layout = "fr")


## Grouped channel deepening figure

cd<-grViz("digraph {
  
graph[layout = dot, rankdir = LR, splines = line]

# define the global styles of the nodes and edges. We can override these if we wish https://graphviz.org/doc/info/attrs.html
node [shape = plaintext]
edge [arrowhead = vee] // edge [arrowtail = none, style = tapered, penwidth = 5, dir = back]

subgraph cluster_0 {
  graph[shape = rectangle]
  
subgraph cluster_1 {
  graph[shape = rectangle]
  pencolor=transparent

  label = <<B>Scenarios</B>>
  a[label='NNBF \n Sea Level Rise']
}

subgraph cluster_2 {
  graph[shape = rectangle]
  pencolor=transparent // https://stackoverflow.com/questions/7357225/remove-rectangle-from-graphviz-dot-cluster-subgraph
  
  label = <<B>Environmental Change   </B>>
  //x[label='',height = .05, fixedsize = TRUE]
  b[label='Change in flood \n depth, extent, duration']
  c[label='Change in landscape']
  //xx[label='',height = .05, fixedsize = TRUE]
  //xxx[label='',height = .05, fixedsize = TRUE]
}

subgraph cluster_3 {
  graph[shape = rectangle]
  pencolor=transparent
  
  label = <<B>Service Change   </B>> // https://stackoverflow.com/questions/56364683/how-can-i-size-table-nodes-in-graphviz-that-contain-bold-text
  //y[label='',height = .05, fixedsize = TRUE]
  i[label='Pavement \n deterioration']
  j[label='Change in traffic patterns']
  k[label='Change in landscape \n aesthetics']
  //yy[label='',height = .05, fixedsize = TRUE]
}
 
subgraph cluster_4 {
  graph[shape = rectangle]
  pencolor=transparent

  label = <<B>Value Change</B>>
  n[label='Change in pavement \n repair cost']
  o[label='Opportunity cost']
  p[label='Change in recreation \n value']
  zz[label='',height = .05, fixedsize = TRUE]
}}

a:e -> b:w // ports and edges https://stackoverflow.com/questions/30260377/dot-language-with-concentrate-true-confusing-the-graph
a:e -> c:w
b:e -> i:w
b:e -> j:w
c:e -> k:w
i:e -> n:w
j:e -> o:w
k:e -> p:w
}")
cd

writeLines(export_svg(cd),"NOAA-ESLR.svg")

