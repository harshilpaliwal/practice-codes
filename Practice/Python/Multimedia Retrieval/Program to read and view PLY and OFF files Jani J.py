import trimesh
import pyrender
import os, sys
import pandas
import numpy
import matplotlib.pyplot as plt
import open3d as o3d


def histogram(dataframe):
    plot1 = dataframe.hist(column='vertices', bins=25, grid=False)
    plot1


#/Users/harshilpaliwal/Documents/Utrecht University/Period 5/Multimedia Retrieval/Princeton benchmark/db/2/m206/

#create empty lists for meshes and object info
my_meshlist = []
my_infolist = []

#Create list to fill with dictionaries to store data
dictionary_list = []
loop_dictionary = {}

#read classification data

classification_dict = {}

file1 = open(os.path.join(sys.path[0], "coarse1Train.cla"), 'r')
lines = file1.readlines()

object_name = " "

for line in lines:
    if line == '\n':
        pass
        
    elif line.strip().isdigit() == False:
        if object_name == " ":
            object_name = line.strip()
        else:
            object_name = line.strip()
            
    else:
        classification_dict[int(line.strip())] = object_name

file1 = open(os.path.join(sys.path[0], "coarse1Test.cla"), 'r')
lines = file1.readlines()

for line in lines:
    if line == '\n':
        pass
        
    elif line.strip().isdigit() == False:
        if object_name == " ":
            object_name = line.strip()
        else:
            object_name = line.strip()
            
    else:
        classification_dict[int(line.strip())] = object_name
        
#check that the dictionary is okay
print(classification_dict)



#Loading all mesh objects into a list from one directory and saving the number of vertices and faces each has
#input1 + "/" + filename
#Contains expection for wrong user input
while True:
    try:
        print("Please type the path where your '.PLY' and/or '.OFF' files are located, for example: '/Users/name/Documents/Ply_files'. (Do not use quotation marks!)")
        print("NOTE: In order to prevent any errors, you should probably have your files in the same directory as this Python file!")
        input1 = input()
        for filename in os.listdir(input1):  
            if filename.endswith (".ply") or filename.endswith(".off"):
                #read object mesh
                #print(filename)
                mesh = trimesh.load(input1 + "/" + filename)
                #my_meshlist.append(mesh)

                #create a list of dictionaries of attributes
                loop_dictionary = {
                    "object": int(filename[1:-4]),
                    "mesh object": mesh,
                    "class": classification_dict.get(int(filename[1:-4])),
                    "vertices": mesh.vertices.shape[0],
                    "faces": mesh.faces.shape[0],
                    "face type": mesh.faces.shape[1],
                    "bounding box": mesh.bounding_box_oriented
                    }
                
                dictionary_list.append(loop_dictionary)


    
                
                #print("Loaded " + str(len(my_meshlist)) + " objects into list.")
            
                #read number of faces and vertices of .OFF files (NOT .PLY FILES! _YET.)
                file = open(input1 + "/" + filename, 'r')
                for i, line in enumerate(file):
                    if i == 1:
                        split = str.split(line)
                        my_infolist.append("Vertices: " + split[0] + " Faces: " + split[1])
                        break
        break
    
    except FileNotFoundError:
        print("File not found, try typing a new path.")


#create pandas dataframe from dictionary_lis, create meshlist from 'mesh object' column
#after ordering in descending order by object name and delete " mesh object" column from dataframe.
df = pandas.DataFrame(dictionary_list)
df.set_index("object", inplace=True)
df.sort_index(inplace=True)

my_meshlist = df["mesh object"].tolist()
del df["mesh object"]
df = df.fillna(value="Not available")

#print the whole dataframe
pandas.set_option("display.max_rows", None, "display.max_columns", None)
print(df)

#calculate average faces and verticies for whole table
average_faces = df["faces"].mean()
average_vertices = df["vertices"].mean()
min_faces = df["faces"].min()
min_vertices = df["vertices"].min()
max_faces = df["faces"].max()
max_vertices = df["vertices"].max()

#Check to see if specified path actually had any objects
#THIS MIGHT NOT WORK ANYMORE!
if len(my_meshlist) == 0:
    print("The path you have specified does not have any objects, restart the program and try a new path.")
    raise SystemExit


#print average information
print("This table contains:")
print("Average faces in dataset: " + str(average_faces))
print("Minimum faces in dataset: " + str(min_faces))
print("Maximum faces in dataset: " + str(max_faces))

print("Average vertices in dataset: " + str(average_vertices))
print("Minimum vertices in dataset: " + str(min_vertices))
print("Maximum vertices in dataset: " + str(max_vertices))

#show histogram to visualise vertices
vertices = df['vertices'].tolist()
print("Type 'yes' if you want to view a histogram of vertices. Type anything else to continue.")
input1 = input()
if input1 == 'yes':
    num_bins = 25
    n, bins, patches = plt.hist(vertices, num_bins, facecolor='blue', alpha=0.5)
    plt.xlabel('Number of Vertices')
    plt.ylabel('Frequency')
    plt.title('Number of Vertices in Dataset')
    plt.show()

#show histogram to visualise faces
faces = df['faces'].tolist()
print("Type 'yes' if you want to view a histogram of faces. Type anything else to continue.")
input1 = input()
if input1 == 'yes':
    num_bins = 25
    n, bins, patches = plt.hist(faces, num_bins, facecolor='blue', alpha=0.5)
    plt.xlabel('Number of Faces')
    plt.ylabel('Frequency')
    plt.title('Number of Faces in Dataset')
    plt.show()


#open3d subdivision
#you need to change the folders to your paths!!!
print("Type 'yes' if you want to subdivide every object with less than 100 faces and refine every object with more than 50000 faces. Type anything else to continue.")
input1 = input()
if input1 == 'yes':
    count = 0
    for face in faces:
        print(face)
        if face < 100:
            mesh = o3d.io.read_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/Princeton db 0 to 200/m" + str(count) + ".off")
            mesh_smp = mesh.subdivide_midpoint(number_of_iterations=3)
            o3d.io.write_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/testfolder/m" + str(count) + ".off", mesh_smp)
            print("Got here1")
        elif face > 50000:
            mesh = o3d.io.read_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/Princeton db 0 to 200/m" + str(count) + ".off")
            mesh_smp = mesh.simplify_quadric_decimation(
                target_number_of_triangles=50000)
            o3d.io.write_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/testfolder/m" + str(count) + ".off", mesh_smp)
            print("Got here2")
        
        else:
            mesh = o3d.io.read_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/Princeton db 0 to 200/m" + str(count) + ".off")
            o3d.io.write_triangle_mesh("/Users/janijarnfors/Documents/Utrecht University/Multimedia retrieval/testfolder/m" + str(count) + ".off", mesh)
        count = count + 1
        print(count)


#ask if  user wants to write the pandas dataframe to an excel file
print("Type 'yes' if you want to write the dataframe to an excel file.")
input1 = input()
if input1 == 'yes':
    df.to_excel("3d_object_database.xls", index=False)
    print("Succesful.")
    
    

#Ask user which object in the list to view, and whether they want to exit the program
#Contains expection for wrong input
while True:
    try:
        print("To view an object in the list, please pick a number between 0 and " + str(len(my_meshlist)-1) + ". To exit the program type 'exit'.")
        input2 = input()
        if input2 == 'exit':
            raise SystemExit
        elif int(input2) in range(0, len(my_meshlist)):
            break
        else:
            print("That is not a valid number, try again.")
    except ValueError:
        print("That is not a number, try again.")

#Renders the chosen object. After closing the viewer window, the user is asked to input a new number or exit the program
#Contains exception for wrong input
while True:

    list_number = int(input2)


    print("This object contains the following:")
    print("vertices: " + str(my_meshlist[list_number].vertices.shape[0]))
    print("faces: " + str(my_meshlist[list_number].faces.shape[0]))

    print("The class is: " + df.at[list_number,"class"])
        
    print("A SCENE VIEWER window should open now.")
    print("Close the SCENE VIEWER window to pick a new object to view.")


    mesh_to_render = pyrender.Mesh.from_trimesh(my_meshlist[list_number])
    scene = pyrender.Scene()
    scene.add(mesh_to_render)
    pyrender.Viewer(scene, use_raymond_lighting=True)


    while True:
        try:
            print("To view an object in the list, please pick a number between 0 and " + str(len(my_meshlist)-1) + ". To exit the program type 'exit'.")
            input2 = input()
            if input2 == 'exit':
                raise SystemExit
            elif int(input2) in range(0, len(my_meshlist)):
                break
            else:
                print("That is not a valid number, try again.")
        except ValueError:
            print("That is not a number, try again.")


            
