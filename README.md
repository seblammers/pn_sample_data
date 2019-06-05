# Some words about the data-structure

Citing the Manual of the Software used to create the files:

"For Calculation Data, the data of each bone has a total of 16 float data points
consisting of position (X Y Z with global coordinate), velocity (X Y Z with
global coordinate), sensor quaternion (W X Y Z with global coordinate), sensor
accelerated velocity (X Y Z with module’s coordinate) and gyro (X Y Z with
module’s coordinate)."

We excluded quaternions for the time being, thus our data has:

+ 22 "bones" with 12 data points each

  = 252 columns

  + 1 column for the frame-number.

  = 253 columns in total.


In the raw data, the bones are just denoted with numbers 1-21.

When importing with my little helper-function, the numbers get translated to
the respective bones.

Four categories of data are available and denoted with a letter in the variable-name:

+ position (x_x, x_y, x_z)
+ velocity (v_x, v_y, v_z)
+ sensor accelerated velocity (a_x, a_y, a_z)
+ gyro (w_x, w_y, w_z)

After importing via the read_calc-function the variable are named like this:

"bone_category_dimension".

e.g.: "hips_x_x", where the first "x" denotes "position-category" and the second
"x" denotes the x-dimension of the position-category.
