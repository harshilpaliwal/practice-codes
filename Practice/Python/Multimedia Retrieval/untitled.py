import trimesh
import pyrender

fuze_trimesh = trimesh.load('/Users/harshilpaliwal/Documents/Utrecht University/Period 5/Multimedia Retrieval/Princeton benchmark/db/ply/dolphins.ply')
mesh = pyrender.Mesh.from_trimesh(fuze_trimesh)
scene = pyrender.Scene()
scene.add(mesh)
pyrender.Viewer(scene, use_raymond_lighting=True)
