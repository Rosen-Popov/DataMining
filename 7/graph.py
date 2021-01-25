import matplotlib.pyplot as plt
import csv

points_file     = "interm.csv"
clusters_file   = "clusters.csv"
colors = ['#3cb44b', '#ffe119', '#4363d8', '#f58231', '#911eb4', '#46f0f0', '#f032e6', '#bcf60c', '#fabebe', '#008080', '#e6beff', '#9a6324', '#fffac8', '#800000', '#aaffc3', '#808000', '#ffd8b1', '#000075', '#808080', '#ffffff', '#000000']
cntr = '#e6194b'

def read_points(file):
    res = []
    with open(file) as csv_file:
        csv_reader = csv.reader(csv_file, delimiter=',')
        for row in csv_reader:
            res.append([float(row[0]),float(row[1]),int(row[2])])
    return res

def ploot_set(x,y,color):
    plt.scatter(x=x,y=y,c=[color])

clusters = read_points(clusters_file)
points = read_points(points_file)

for cluster in range(len(clusters)):
    x_c = []
    y_c = []
    for point in points:
        if point[2] == cluster:
            x_c.append(point[0])
            y_c.append(point[1])
    print (cluster)
    ploot_set(x_c,y_c,colors[cluster])
for i in clusters:
    x_c = []
    y_c = []
    x_c.append(i[0])
    y_c.append(i[1])
    ploot_set(x_c,y_c,colors[len(clusters) + 2])
plt.show()
