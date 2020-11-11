import keras
import numpy as np
import json
from neo4j.v1 import GraphDatabase, Driver

class GraphSequence(keras.utils.Sequence):

    def __init__(self, args, batch_size=32, test=False):
        self.batch_size = batch_size
        
        self.query = """
            match (a:project_20180004_B_BOUWKUNDIGsvg:Door:Arc),(l:project_20180004_B_BOUWKUNDIGsvg:Door:Line), p = shortestPath((a)-[:intersects*..3]-(l)) return p
        """

        self.query_params = {
            "dataset_name": "Graph_FA",
            "test": test
        }

        with open('./settings.json') as f:
            self.settings = json.load(f)[args.database]

        driver = GraphDatabase.driver(
            self.settings["neo4j_url"], 
            auth=(self.settings["neo4j_user"], self.settings["neo4j_password"]))

        with driver.session() as session:
            data = session.run(self.query, **self.query_params).data()
            self.data = data


    def __len__(self):
        return len(self.data)

    def __getitem__(self, idx):
        return self.data[idx]
