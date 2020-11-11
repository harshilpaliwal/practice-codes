from nltk import word_tokenize, pos_tag, ne_chunk
from nltk import RegexpParser
from nltk import Tree
import pandas as pd
import re

import csv

# Defining a grammar & Parser to get non-prepositional noun phrases
NP = "NP: {<DT|JJ|NN\$>?<JJ|VB|NN>*<NN>}"
#NP = "NP: {<JJ|VB|NN>*<NN>}"
#NP = "NP: {<DT|JJ>*<NN>*<JJ|VB>*<NN>}"
chunker = RegexpParser(NP)

def get_continuous_chunks(text, chunk_func=ne_chunk):
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

with open("Datasets/noun_phrases.csv", 'w') as myfile:
    for item in input_data:
        noun_phrase = get_continuous_chunks(str(item), chunker.parse)
        noun_phrase.pop(0)
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        wr.writerow([noun_phrase])
        