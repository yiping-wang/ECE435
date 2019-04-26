# ECE435-Project

### Code Compatibility
Our codebase is able to run on the lastest version of MATLAB, which is 2019a.

We didn't check its compatibility with previous versions of MATLAB due to license reasons and time constraint. The biggest difference would the `sum` function, the MATLAB 2019a supports `sum(A, 'all')`, whereas the previous versions do not support this feature, so `sum(A, 'all')` must be changed to `sum(sum(A))` in order to run on previous versions. 


### Timeline


| Task       | Due Date           | 
| ------------- |:-------------:|
| ~~Submission of Project Proposal~~|~~Feb 24~~|
| ~~Submission of Progress Report~~|~~March 10~~|
| ~~Short Oral Presentations of the Progress Report~~ | ~~March 11~~ |
|~~Submission of Oral Presentation~~|~~March 31~~ |
|~~Final Oral Presentations~~|~~April 1~~|
|~~Submission of Project Code and Video Demo~~|~~April 8~~|
| Submission of Final Project Report|April 11|

### Read Dataset
In `Train45Test90` folder, take `isbi_train.mat` as example (the rest are similar)
1. `K = load('isbi_train.mat');`
2. `F = K.ISBI_Train`
3. Now F has 810 cells
4. `I = F{1, 1}` to `I = F{810, 1}`
5. `imshow(I)`
