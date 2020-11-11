import py2neo
from neo4j import GraphDatabase, basic_auth
import neo4j
import networkx as nx
from node2vec import Node2Vec

uri = "bolt://localhost:7687"
#uri = "http://localhost:7474/"
password = "1719"
driver = GraphDatabase.driver(uri=uri, auth = basic_auth("neo4j", password))

