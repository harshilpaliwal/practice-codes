import py2neo
import networkx as nx
from node2vec import Node2Vec

uri = "bolt://localhost:7687"
graph = py2neo.Graph(uri, auth = ("neo4j", "1719"))
graph = graph = nx.fast_gnp_random_graph(n=100, p=0.5)

#for movie in graph.run("match (n:Movie) return n"):
#    print(movie)

embedding_file = "./embeddings.emb"
embedding_model = "./embeddings.model"

node2vec = Node2Vec(graph, dimensions=64, walk_length=30, num_walks=200, workers=4)

model = node2vec.fit()
model.wv.most_similar('2')

model.wv.save_word2vec_format(embedding_file)

# Save model for later use
model.save(embedding_model)





