import random
import math

def biased_random():
    r = random.random()  # Nombre uniforme entre 0 et 1
    power = 2  # Contrôle le biais (plus élevé = plus biaisé vers les grands nombres)
    return math.ceil((1 - r ** power) * 100)

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