mkdir model
mkdir submission
# беремо дані і фільтруємо нулі + сортуємо і тд
ipython r0_itemstore.py
# робимо предікт початковий
R --vanilla < r1_baseline.r

ipython r2_preprocess.py
ipython r3a_rollingmean.py
ipython r3b_zeros.py
ipython r3c_features.py
ipython r4_vwtxt_creator.py
source  r5_vwrun.sh 
ipython r6_submission.py
#sort submission/p.csv > submission/sortp.csv
#diff submission/sortp.csv answer/sortp.csv > temp.txt