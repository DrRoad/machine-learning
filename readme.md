MachineLearning
================
Upton, Lance T.

A pattern recognition algorithm to classify questions asked at a library service desk, based on a term document matrix (TDM).

Raw Data
--------

### Predictors

    ##        location         format           date           
    ##  info desk :   79   walk-up:48738   Min.   :2015-05-01  
    ##  media     :   56   phone  : 6989   1st Qu.:2016-01-16  
    ##  tech desk : 5301                   Median :2016-08-22  
    ##  staff desk:    5                   Mean   :2016-07-12  
    ##  west desk :24596                   3rd Qu.:2017-01-12  
    ##  east desk :25654                   Max.   :2017-08-01  
    ##  off-desk  :   36                                       
    ##     datetime                     question            answer         
    ##  Min.   :2015-05-01 11:18:00   Length:55727       Length:55727      
    ##  1st Qu.:2016-01-16 15:50:00   Class :character   Class :character  
    ##  Median :2016-08-22 10:51:00   Mode  :character   Mode  :character  
    ##  Mean   :2016-07-12 19:31:22                                        
    ##  3rd Qu.:2017-01-12 14:48:30                                        
    ##  Max.   :2017-07-31 20:56:00                                        
    ## 

### Categories

    ##             tag1                        tag2                    tag3      
    ##  Reference    :27830   internal_directions:21505   other/na       :11692  
    ##  Directional  :25362   policy             :10895   classroom/space: 7704  
    ##  Miscellaneous: 2535   technology         : 6849   equipment      : 7408  
    ##                        known_item_lookup  : 3500   desk           : 3255  
    ##                        supplies           : 3265   hours          : 2987  
    ##                        external_directions: 3017   account        : 1994  
    ##                        (Other)            : 6696   (Other)        :20687

**NOTE:** Categories are hierarchical (`tag1` &gt; `tag2` &gt; `tag3`).

Method
------

### Step 1: Base Model

1.  `Question` is cleaned.
2.  A TDM is generated and features are extracted.
3.  Data is split into training and testing sets.
4.  Models are created to predict `tag1`.
5.  Models are run and tested.
6.  A model with satisfactory accuracy is used to split data by `tag1`.
7.  `tag2` is predicted (and so on...).

### Step 2: Add predictors

1.  Different combinations of other predictors are added to the model.
2.  ???
3.  Profit.

References
----------

-   [Applied Predictive Modeling &gt; Nested Resampling with rsample](http://appliedpredictivemodeling.com/blog/2017/9/2/njdc83d01pzysvvlgik02t5qnaljnd)
-   [Revolutions &gt; Text categorization with deep learning, in R](http://blog.revolutionanalytics.com/2017/08/text-categorization-deep-learning.html)
-   [Text Mining with R](http://tidytextmining.com/index.html)
-   [Introduction to tidytext](https://cran.r-project.org/web/packages/tidytext/vignettes/tidytext.html)
-   [Classifying Documents in the Reuters-21578 R8 Dataset](https://rpubs.com/bmcole/reuters-text-categorization)
