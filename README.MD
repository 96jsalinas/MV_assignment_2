# Heart Disease Dataset - Multivariate Analysis

## Data Source

**Dataset**: Heart Disease Database  
**Repository**: UCI Machine Learning Repository  
**URL**: https://archive.ics.uci.edu/dataset/45/heart+disease  
**Database Used**: Cleveland Clinic Foundation (processed.cleveland.data)

### Citation

This dataset was created by:
- **Hungarian Institute of Cardiology, Budapest**: Andras Janosi, M.D.
- **University Hospital, Zurich, Switzerland**: William Steinbrunn, M.D.
- **University Hospital, Basel, Switzerland**: Matthias Pfisterer, M.D.
- **V.A. Medical Center, Long Beach and Cleveland Clinic Foundation**: Robert Detrano, M.D., Ph.D.

**Key Publication**:  
Detrano, R., Janosi, A., Steinbrunn, W., Pfisterer, M., Schmid, J., Sandhu, S., Guppy, K., Lee, S., & Froelicher, V. (1989). International application of a new probability algorithm for the diagnosis of coronary artery disease. *American Journal of Cardiology*, 64, 304-310.

## Dataset Description

### Overview
The Cleveland heart disease database contains 303 instances with 14 attributes used for diagnosing coronary artery disease. The original database contains 76 attributes, but published experiments reference only these 14.

### Target Variable
- **num**: Diagnosis of heart disease (angiographic disease status)
  - Value 0: < 50% diameter narrowing (no disease)
  - Values 1-4: > 50% diameter narrowing (disease present)

### Attributes (14 total)

#### Quantitative Variables
1. **age**: Age in years
2. **trestbps**: Resting blood pressure (mm Hg on admission)
3. **chol**: Serum cholesterol (mg/dl)
4. **thalach**: Maximum heart rate achieved
5. **oldpeak**: ST depression induced by exercise relative to rest
6. **ca**: Number of major vessels colored by fluoroscopy

#### Categorical Variables
7. **sex**: Sex (0 = female; 1 = male)
8. **cp**: Chest pain type
   - 1: Typical angina
   - 2: Atypical angina
   - 3: Non-anginal pain
   - 4: Asymptomatic
9. **fbs**: Fasting blood sugar > 120 mg/dl (0 = false; 1 = true)
10. **restecg**: Resting electrocardiographic results
   - 0: Normal
   - 1: ST-T wave abnormality
   - 2: Probable or definite left ventricular hypertrophy
11. **exang**: Exercise induced angina (0 = no; 1 = yes)
12. **slope**: Slope of the peak exercise ST segment
    - 1: Upsloping
    - 2: Flat
    - 3: Downsloping
13. **thal**: Thalassemia
    - 3: Normal
    - 6: Fixed defect
    - 7: Reversible defect
14. **num**: Heart disease diagnosis (0-4)

### Missing Values
Missing attribute values are represented as "?" in the original dataset. In our cleaned version, rows with missing values in `ca` or `thal` variables have been removed.

**Original instances**: 303  
**Cleaned instances**: ~297 (after removing missing values)

## Project Structure

```
MV_assignment_2/
├── data/
│   ├── processed.cleveland.data     # Raw data file
│   └── heart-disease.names          # Data documentation
├── visualizations/                   # Generated plots
├── main.R                           # Main entry point
├── preprocessing.R                  # Data loading and cleaning
├── data_exploration.R               # Exploratory data analysis
└── README.MD                        # This file
```

## Usage

Run the analysis by executing:

```r
source("main.R")
```

This will:
1. Load and clean the data (`preprocessing.R`)
2. Generate exploratory visualizations (`data_exploration.R`)
3. Save plots to `visualizations/` directory

## Data Processing

### Preprocessing Steps
1. Load raw data from `processed.cleveland.data`
2. Assign proper column names
3. Handle missing values (remove rows with missing `ca` or `thal`)
4. Convert categorical variables to factors with descriptive labels
5. Create binary disease variable (Disease vs No Disease)

### Output
Two data frames are created:
- **heart_data**: Original raw data
- **heart_data_clean**: Processed data ready for analysis
