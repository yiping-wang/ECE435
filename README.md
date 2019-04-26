# ECE435


_Medical Image Processing_ | Spring 2019 | [Course outline](https://drive.google.com/file/d/1pttB_XiK4yHNMvswD0w7B3aPpovR2UpF/view?usp=sharing) | University of Victoria 

### Course summary:

Image processing and understanding techniques applied in medical imaging technologies such as CT, MRI, ultrasound, X-ray. Design of computer aided diagnosis systems. Topics include algorithms for filtering, edge detection, segmentation, registration and 3D visualization of medical data. 

### Project Abstract

In this project, we implement and reproduce an algorithm for the segmentation of nuclei and cytoplasm from clumps of overlapping cervical cells of the MICCAI 2013 paper _Automated Nucleus and Cytoplasm Segmentation of Overlapping Cervical Cells_. This problem is difficult due to the varying degree of overlap among cells, the poor contrast of cell cytoplasm and the presence of blood, inflammatory cells and other debris. Our proposed approach address this challenge by employing level set functions, where both unary and binary terms are factored into the energy function. Each function represents a cell within a clump, and multiple level set functions are evolved concurrently. The unary constraints are based on the cell area and cell shape, while the binary constraints are computed based on the overlapping area and the overlapping intensity between co-evolving level set functions. In this way, the proposed methodology enables the analysis of nuclei and cytoplasm from both free-lying and overlapping cells. We also provide quantitative and qualitative evaluations using the comprehensive ISBI 2014 dataset, which contains 16 real cervical cell images and 945 synthetic images.

### Grade:

A+ 95%
