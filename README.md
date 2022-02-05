# MosaicPhoto
 Mosaic photo. The mosaic photo is a method to make an original image consist of small images. These small parts are combined to make an image similar to the original one. I have written the code to produce a mosaic photo out of my own Dataset. The range of colors is crucial in choosing a proper Dataset. As a result, I have created a Dataset from the screenshots of ‘Zootopia’ movie which is pretty colorful.

# Going through the code:

1. First of all, in the MATLAB code the original image is uploaded:

```Matlab
Orig = imread('check8k.jpg'); %upload original photo from the same folder as the Matlab File
[r, c, rgb] = size(Orig);
```

2. Then the user chooses the form of the patches:
   
   Type 1. Circular + Squares (rows and columns of patches are equal);
   
   Type 2. Rectangular (rows and columns of patches vary).

3. Depending on the choice, the user is offered to choose the size for patches:

For type 1. An array consists of common divisors of the original image’s row and column numbers.

For type 2. Two different arrays of divisors of the original image’s row and, separately, column numbers.

4. When the patches’ size is chosen, the Dataset of photos is uploaded and read in the format of the cells:

```Matlab
Data = imageDatastore('zootopia');
Data = readall(Data);
```
5. The uploaded photos are each resized by the size defined by the user. Also, the original image is divided into cells of the same size as patches:

```Matlab
divided_orig = mat2cell(Orig, r_patch*ones(1, r/r_patch), c_patch*ones(1, c/c_patch), rgb);
```

6. In case the user chose circular patches the mask of the circular is initialized from the center of the patch:

```Matlab
%mask
circle = [r_patch/2, c_patch/2, r_patch/2];
[xx, yy] = meshgrid((1:r_patch)-circle(1),(1:c_patch)-circle(2));
mask = (xx.^2 +yy.^2) <= circle(3)^2;
```

7. Since everything is prepared, the mosaic begins to construct. The method used in the image selection is by measuring Euclidean distance. The technique takes every cell in the divided image and compares it with every element in the dataset. The image with the minimal Euclidean distance is inserted into the cell. 

In the code I converted an image from the dataset and a cell of the original image to double matrix with 3 channels concatenated by axis 2. As a result the D and O matrices are with dimensions (patch’s rows) x (3*patch’s columns). 

```Matlab
while i < (size (Data, 1)+1)
            D = im2double(Data{i}(:,:));
            O = im2double(divided_orig{r, c}(:,:));
            Dist = sqrt(sum((D-O)*(D-O)', 'all'));
            if dist_min > Dist
                dist_min = Dist;
                k = i;
            end
            i = i+1;
end
```

8. If the circular patches are chosen, the circular mask is applied to every color channel of the original cell and the image with minimal distance. The circle inside the square patch is replaced with a proper image from dataset. (The channels could be also defined by imsplit() command.)

```Matlab
Red1 = Data{k, 1}(:,:, 1);
Green1 = Data{k, 1}(:, :, 2);
Blue1 = Data{k, 1} (:,:, 3);

Red2 = divided_orig{r, c}(:,:, 1);
Green2 = divided_orig{r, c}(:, :, 2);
Blue2 = divided_orig{r, c}(:,:, 3);

Red2(mask) = Red1(mask);
Green2(mask) = Green1(mask);
Blue2(mask) = Blue1(mask);

Circle_divided{r,c} = cat(3, Red2, Green2, Blue2);
```

9. The resulted cells with a replaced images inside are converted to matrix. The obtained photo is presented using imshow():

```Matlab
result_im = cell2mat(divided_orig);
figure
imshow(result_im);
```

Examples of images made of the Datatset (own+provided):

![alt text](https://github.com/KarinaBurunchina/MosaicPhoto/blob/main/input%20examples/check5.jpg)

Figure 1. The original image of Tanjiro.

![alt text](https://github.com/KarinaBurunchina/MosaicPhoto/blob/main/output%20examples/output5_p10_sq.png)

Figure 2. The image with square 10 pixels patches of Tanjiro.

![alt text](https://github.com/KarinaBurunchina/MosaicPhoto/blob/main/output%20examples/output5_p10_circ.png)

Figure 3. The image with circular 10 pixels patches of Tanjiro.

![alt text](https://github.com/KarinaBurunchina/MosaicPhoto/blob/main/output%20examples/output5_10x15_rec.png)

Figure 4. The image with rectangular 10x15 patches of Tanjiro.


