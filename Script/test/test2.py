import random
import math

def biased_random():
    # Plus vous ajoutez de nombres dans le min(), plus le biais est fort
    return min(
        random.randint(1, 100),
        random.randint(1, 100),
    )

liste_p_50 = []
liste_m_50 = []

for i in range(100):
    numb = biased_random()
    if numb > 50:
        liste_p_50.append(numb)
    elif numb < 50:
        liste_m_50.append(numb)

print(len(liste_m_50))
print(len(liste_p_50))
print(liste_m_50)
print(liste_p_50)