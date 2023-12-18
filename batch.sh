mkdir model
mkdir submission
# беремо дані і фільтруємо нулі + сортуємо і тд
python3 step_1_itemstore.py
# робимо предікт початковий
R --vanilla < step_2_baseline.r

python3 step_3_preprocess.py
python3 step_4_1_rollingmean.py
python3 step_4_2_zeros.py
python3 step_4_3_features.py
python3 step_5_vwtxt_creator.py
source  step_6_vwrun.sh
python3 step_7_submission.py