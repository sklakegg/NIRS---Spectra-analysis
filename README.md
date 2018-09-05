# Near-infrared spectroscopy - Spectra analysis
This script is used to load, preprocess and analyse NIRS spectra.

## Directory structure
The script expects the following directory structure (set **dir_csvdata** and **conf_name** in script based on these):
- *dir_csvdata*
  - sample_type_1
    - name**conf_name**<not imporat>.csv (Ex: omega_3**Default**_294267_20180130_184638.csv)
    - name**conf_name**<not imporat>.csv (Ex: omega_3**Default**_294268_20180130_184704.csv)
  - sample_type_2
  - ...
  - sample_type_n

## Data format
The script expects the .csv files to use the format shown in the figure.

**int_configrows_remove** variable in the script is set to 22 as seen from orange box.

**int_nwavelengths** is set based on the scan resolution (number of wavelengths).

The wavelength column should always be the first, followed by absorbance (seen in red box).

![nirs_readme_pic](https://user-images.githubusercontent.com/14874913/45097241-088d7b00-b12b-11e8-87c8-fae7737df502.png)
