# Practical Coursework for BMI 569/669: Data Analytics

This repo includes the practical coursework in R/SQL for our hybrid Data Analytics Course taught with Kaiser Permanente. This course has been taught from 2013 to the present during summer quarter for students in the Biomedical Informatics program at OHSU.

Please note that this is only half of the course, which also includes discussions on organizational behavior, implementing analytics projects within an organization, and discussions of the LACE score. For the full course syllabus, please refer to [the syllabus](pdf/bmi_569_syllabus) and [the on-campus scheduel of topics](pdf/on_campus_course_outline.pdf).

## Learning Objectives:

- Understand the basics of using R/Rstudio
- Learn and apply basic SQL queries to a synthetic patient cohort
- Implement a metric for predicting 30 day hospital readmissions (LACE score) for this patient cohort.
- Learn, understand, and apply simple visualizations to communicate findings
- Understand how to build and interpret logistic regression models

## Schedule (online)

The goal of the online portion of the course is to familiarize students with R and how to query the synthetic patient data in R. 

All work is conducted within a RStudio workspace.

- Week 1: [Introduction to R/RStudio](https://github.com/laderast/AnalyticsCourse/tree/master/week1)
- Week 2: [Loading datasets/simple descriptive statistics in R](http://github.com/laderast/AnalyticsCourse/tree/master/week2)
- Week 3: [Introduction to SQLite in R](http://github.com/laderast/AnalyticsCourse/tree/master/week3)
- Week 4: [SQL queries: Joins](http://github.com/laderast/AnalyticsCourse/tree/master/week4)
- Week 5/6: [Working with Dates in SQLite/Self Joins](http://github.com/laderast/AnalyticsCourse/tree/master/weeks5-6)
- Week 7: [Visualizing the data with `ggplot2` and `patchwork`](http://github.com/laderast/AnalyticsCourse/tree/master/week7)
- Week 8: [Logistic Regression and machine learning](http://github.com/laderast/AnalyticsCourse/tree/master/week8)

## Schedule (in-class)

The goal of the online portion is to build a predictive model using the synthetic patient dataset to predict 30 day readmissions. 

- Day 1: [Calculating L (length of stay), A (Acuity), and E (Emergency room admissions)](http://github.com/laderast/AnalyticsCourse/tree/master/in-class/Assignment1.Rmd) from synthetic patient cohort in SQLite database.  
- Day 2: [Calculating C (co-morbidities) from ICD-9 codes in SQLite database.](http://github.com/laderast/AnalyticsCourse/tree/master/in-class/Assignment2.Rmd)
- Day 3: [Initial predictive modeling for prediction using logistic regression](http://github.com/laderast/AnalyticsCourse/tree/master/in-class/LogisticRegression.Rmd)
      - [adding in genotypic component](http://github.com/laderast/AnalyticsCourse/tree/master/in-class/BonusAssignment.Rmd) (Bonus) 
- Day 4: Build Final predictive model and presentation for Day 5  

## Acknowledgements

The synthetic dataset and original task of calculating the LACE score was developed by David Dorr. All other materials and tutorials were developed by Ted Laderas, Mark Klick, and Shannon McWeeney. 

## License

This course material is available under an Apache 2.0 License.
