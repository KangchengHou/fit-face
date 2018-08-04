# Face Fitting
This is a face fitting tool and two applications of this. This project partially implemented several papers(see references). The provided code should be a good start if you want to implement these papers yourself.
## Quick Start
1. git clone https://github.com/KangchengHou/fit-face.git
2. create face database according to [this](./src/metadata)
3. run model fitting [demo](./src/demo/fit_model_demo.m)


## Dependencies
1. Matlab 2017b or later


## Coordinate Descent
We use coordinate descent to fit a face.
![](./images/cd1.png)
![](./images/cd2.png)

## Application 1: Expression flow
![](./images/expression-flow-pipeline.png)

## Application 2: Easy Face Editing
![](./images/face-editing.png)

## References
This project partially implemented the following papers:  
[1] As-rigid-as-possible shape manipulation  
[2] Poisson image editing  
[3] Laplacian surface editing  
[4] Expression flow for 3d-aware face component transfer