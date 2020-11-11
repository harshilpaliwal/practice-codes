#!/usr/bin/env python3
from graph_sequence import *
import pandas as pd

def get_neo4j_data(args):

    seq_train = GraphSequence(args)
    graphData = seq_train.data
    return graphData

if __name__ == '__main__':

    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--database', type=str, default="hosted")
    args = parser.parse_args()
    graphData = get_neo4j_data(args)
    door_count = 0

    for path in graphData:
        door_id = path.get('p').nodes[0].get('door_id')
        start_node_id = path.get('p').nodes[0].id
        end_node_id = path.get('p').nodes[1].id      
        f=open("input/d"+str(door_id)+".txt", "a+")
        f.write(str(start_node_id) + "\t" + str(end_node_id) + "\n")
        
          
