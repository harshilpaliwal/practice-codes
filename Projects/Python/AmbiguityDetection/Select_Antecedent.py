import pandas as pd
from nltk import word_tokenize, pos_tag
import re
import spacy

input_statements = pd.read_csv("input_statements.csv", header=None, quotechar='"', sep='\t')
input_np = pd.read_csv("Datasets/noun_phrases.csv", header=None, quotechar='"', sep='\t')
input_ne = pd.read_csv("Datasets/named_entities.csv", header=None, quotechar='"', sep='\t')
nlp = spacy.load('en')

antecedents = [None]*len(input_np)
antecedents_subject = [None]*len(input_np)
antecedents_object = [None]*len(input_np)

for index, row_np in input_np[0].iteritems():
    row_ne = input_ne[0][index].replace('[','').replace(']','')
    row_np = row_np.replace('[','').replace(']','')
    if(len(row_np) == 0):
        temp_ne = row_ne.split(',')
        #if np is zero and ne is 1 then that one element is the antecedent
        if(len(temp_ne) == 1):
            antecedents[index] = temp_ne
        else:
            continue
    elif(len(row_ne) == 0):
        temp_np = row_np.split(',')
        # if ne is zero and np is 1 then that one element is the antecedent
        if (len(temp_np) == 1):
            antecedents[index] = temp_np
        else:
            antecedents[index] = temp_np[0]
    else:
        row_stmt = re.sub('\<referential\>|\<\/referential\>|\<referential id\="*[a-z]*"\>', '', str(input_statements[0][index]))
        parsed_text = nlp(row_stmt)
        subject = []
        direct_object = []
        for text in parsed_text:
            # subject would be
            if text.dep_ == "nsubj":
                subject.append(text.orth_)
            # dobj for direct object
            if text.dep_ == "dobj":
                direct_object.append(text.orth_)
                
        for item in row_np.split(','):
            if len(subject)>0:
                if bool(re.search(subject[0], item)) == True:
                    antecedents_subject[index] = item
            if len(direct_object)>0:
                if bool(re.search(direct_object[0], item)) == True:
                    antecedents_object[index] = item
            