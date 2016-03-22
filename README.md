# eegfist
This is an attempt to create a classifier for the data provided at https://www.physionet.org/pn4/eegmmidb/. This data yields 64 channels of EEG data while performing various tasks. The following tasks have been adressed (description taken from the projects website):

#### Task 1

> A target appears on either the left or the right side of the screen. The subject opens and closes the corresponding fist until the target disappears. Then the subject relaxes.

#### Task 3

> A target appears on either the top or the bottom of the screen. The subject opens and closes either both fists (if the target is on top) or both feet (if the target is on the bottom) until the target disappears. Then the subject relaxes.

## Short summary
- use the data provided for Task 1 and Task 3
- attempt to find a classifier that can differentiate between 
   - T0 (both fists relaxed) -> class 0 in our code
   - T1_left (left fist closed or both fists closed) -> class 1 in our code
   - T1_right (right fist closed) -> class 2 in our code
- current feature vectors yield a classification rate of 69% when T1_left and T1_right are combined in one single class and compared to the feature fector T3 (relaxed)
- current fv yield non-usable results when run on class T1_left vs T1_right (roughly 51%)
- next step would be to try to improve the fv

## Long summary
 - reading the edfs proved to be kind of troublesome. some scripts have been created to glue the working parts of various edflibs together (see docedf file for details)
 - matlab has been chosen for signal processing because it provides easy access to a lot of usefull signal processing libraries
 - __first (naive) approach__
   - calculate the FFT for each channel.
   - put all the FFTs in one line, have the class as an integer and put that at the end of this line
   - combine all theese lines in one big csv
     - needless to say: this is a very very bad idea. we now have a ~32.000 (!) dimensional feature vector. As a result, most of the classifiers tried at this point would not even fit into the RAM of a "standard" workstation (we had 24 GB).
   - creating the arff files (file format preferred by weka, our classification toolbox of choice) turned out to be a problem, as the tried arffwriter libraries yielded arffs weka would fail to import
   - weka proved unable to handle such big csvs for import. this could have been obvious by hindsight as
     1. weka is not meant to be used with csvs (see <https://weka.wikispaces.com/Can+I+use+CSV+files%3F>)
     2. our feature vector is way too big
   - matlab has its own classification toolbox, so we tried to use the classifiers provided there
     - results: ~35% classification rate for tree, SVM and KNN
     - both very cpu- and mem-intensive due to the huge feature vector
 - __second approach__
  - goal: reduce the feature space to a somewhat more reasonable number
    - simple statistical features like standard derivation and variance got integrated into the feature vector
    - fft has been reduced to a total of 12 values per channel, being the result of calculating the median over 5 values each
    - just uses the channels 9,10,11,12 and 13, as [TODO: insert paper here] suggests that it should be sufficient
  - results: roughly 40%, so still no "real" improvement.
 - __third approach__
  - reduced the problem to a two-class-problem by combining both T1_left and T1_right into a single class
  - yields 69% when using the AdaBoost ensemble classifier [TODO: specify the parameters used]
  - No better classification rate than 50-51% could be achieved when classifying T1_left vs T1_right by completely removing T0 from the data
    - the feature vectors obv arent suitable for classification between theese two classes, explaining the very bad results during the first approaches
    - further investigation using _plotmymat.m_ supports this

## Conclusion
  - a lot of time has been wasted on playing around with classifiers that should have been spent on the feature vectors
  - preparing the data for import into $framework took quite some time, as both the EDF and the ARFF libraries caused some problems
  - "okayish" result
  - the deep learning approach looks promising (esp for finding better feature vectors), but unfortunately we ran out of time while setting up and configuring the caffe framework. :-(
