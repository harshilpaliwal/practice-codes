import trimesh
import pyrender
fuze_trimesh = trimesh.load('/Users/harshilpaliwal/Documents/Utrecht University/Period 5/Multimedia Retrieval/Princeton benchmark/db/2/m203/m203.off')
mesh = pyrender.Mesh.from_trimesh(fuze_trimesh)
scene = pyrender.Scene()
scene.add(mesh)
pyrender.Viewer(scene, use_raymond_lighting=True)


mesh = trimesh.Trimesh(vertices=[[0, 0, 0], [0, 0, 1], [0, 1, 0]],
                       faces=[[0, 1, 2]])