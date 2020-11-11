import pandas as pd
import re
import csv

anaphors = []
anaphor_ids = []

input_data = pd.read_csv("Datasets/training_set.tsv", header=None, quotechar='"', quoting=3, sep='\t')
input_data = input_data.iloc[1:]
print(len(input_data))

input_statements = input_data[1].tolist()
statement_ids = input_data[0].tolist()
print(len(input_statements))

for statement in input_statements:
    anaphor = re.findall(r'\>(.*?)\<\/referential\>', statement)
    index = input_statements.index(statement)
    for item in anaphor:
        anaphors.append(item)
        anaphor_ids.append(statement_ids[index])

with open("anaphors.csv", 'w') as myfile:
    for item in list(zip(anaphor_ids, anaphors)):
        wr = csv.writer(myfile, quoting=csv.QUOTE_ALL)
        wr.writerow(item)

with open('anaphors.csv', newline='') as f:
    reader = csv.reader(f)
    anaphors = list(reader)
    
with open('Datasets/training_set.csv', newline='') as f:
    reader = csv.reader(f)
    input_data = list(reader)    
input_data.pop(0)

edited_input = []
#replacing <referential> tags

final_input = []
id_count = 0

for item in input_data:
    for anaphor in anaphors:
        if(item[0] == anaphor[0]):
            id_count = id_count+1
    if(id_count>1):
        for count in range(id_count):
         edited_input.append(re.sub('\<referential\>|\<\/referential\>|\<referential id\="*[a-z]*"\>', '', str(item[1])))  
    else:
        edited_input.append(re.sub('\<referential\>|\<\/referential\>|\<referential id\="*[a-z]*"\>', '', str(item[1])))
    id_count = 0

with open("input_statements.csv", 'w') as myfile:
    for item in edited_input:
        wr = csv.writer(myfile)
        wr.writerow([item])












