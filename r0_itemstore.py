import pandas as pd
import numpy as np


def create_vaild_item_store_combinations(_df):
    df = _df.copy()
    # +1 тому що df['units'] може бути нуль а натуральний логарифм нуля undefined, а так ми просто отримаємо нулі які далі фільтруємо
    # чому саме логарифм? Бо таким чином хендлимо спайки в даних (занадто великі значення, або занадто малі, які можуть перекосити результати)
    # + це дає змогу працювати саме з відсотковою зміною значень відносто числа ейлера, а не з абсолютними значеннями
    df['log1p'] = np.log(df['units'] + 1)

    # просто середнє значення продажів кожного продукті в кожному магазині
    g = df.groupby(["store_nbr", "item_nbr"])['log1p'].mean()
    # фільтруємо все що більше нуля
    g = g[g > 0.0]

    store_nbrs = g.index.get_level_values(0)
    item_nbrs = g.index.get_level_values(1)

    # сортування в 2 фази, номер айтему має набагато більший пріоритет. Тобто результатом буде сотрування по айтемам
    # всередені яких групи будуть відсортовані по магазину
    store_item_nbrs = sorted(zip(store_nbrs, item_nbrs), key=lambda t: t[1] * 10000 + t[0])

    # пишемо результат в файлик
    with open(store_item_nbrs_path, 'w') as f:
        f.write("store_nbr,item_nbr\n")
        for sno, ino in store_item_nbrs:
            f.write("{},{}\n".format(sno, ino))

# if __name__ == '__main__':
store_item_nbrs_path = 'model/store_item_nbrs.csv'
df_train = pd.read_csv("data/train.csv")
create_vaild_item_store_combinations(df_train)
