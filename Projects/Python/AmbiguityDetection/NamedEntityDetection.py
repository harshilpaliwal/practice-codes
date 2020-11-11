from nltk import word_tokenize, pos_tag, ne_chunk
from nltk import RegexpParser
from nltk import Tree
import csv

# Defining a grammar & Parser
NP = "NP: {<RB.?>*<VB.?>*<NNP><NN>?}"
chunker = RegexpParser(NP)

def get_continuous_chunks(text, chunk_func):
    chunked = chunk_func(pos_tag(word_tokenize(text)))
    continuous_chunk = []
    current_chunk = []

    for subtree in chunked:
        if type(subtree) == Tree:
            current_chunk.append(" ".join([token for token, pos in subtree.leaves()]))
        elif current_chunk:
            named_entity = " ".join(current_chunk)
            if named_entity not in continuous_chunk:
                continuous_chunk.append(named_entity)
                current_chunk = []
        else:
            continue

    return continuous_chunk

with open('input_statements.csv', newline='') as f:
    reader = csv.reader(f)
    input_data = list(reader)  

with open("Datasets/named_entities.csv", 'w') as myfile:
    for item in input_data:
        named_entity = get_continuous_chunks(str(item), chunker.parse)
        print(named_entity)
        print(type(named_entity))
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        wr.writerow([named_entity])