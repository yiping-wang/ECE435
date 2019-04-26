import numpy as np
import scipy.ndimage
import scipy.signal
import matplotlib.pyplot as plt
from skimage import color, io

def grad(x):
    return np.array(np.gradient(x))

def norm(x, axis=0):
    return np.sqrt(np.sum(np.square(x), axis=axis))


def stopping_fun(x):
    return 1. / (1. + norm(grad(x))**2)

def default_phi(x):
    # Initialize surface phi at the border (5px from the border) of the image
    # i.e. 1 outside the curve, and -1 inside the curve
    phi = np.ones(x.shape[:2])
    phi[5:-5, 5:-5] = -1.
    return phi

img = io.imread('toy.bmp')
img = color.rgb2gray(img)
img = img - np.mean(img)

phi = default_phi(img) # initial value for phi

dt = 1
it = 100
sigma = 1

img_smooth = scipy.ndimage.filters.gaussian_filter(img, sigma)

F = stopping_fun(img_smooth)

for i in range(it):
    dphi = grad(phi)
    dphi_norm = norm(dphi)
    phi = phi + dt * F * dphi_norm
    # plot the zero level curve of phi
plt.contour(phi, 0)
plt.axis('off')
plt.savefig('seg.png', bbox_inches='tight', pad_inches=0)
plt.show()