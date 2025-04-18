import random
import math

def evaluate_numbers(numbers):
    liste_p_50 = []
    liste_m_50 = []

    liste_np_50 = []
    liste_nm_50 = []

    for numb in numbers:
        if numb > 50:
            liste_p_50.append(numb)
        elif numb < 50 and numb > 0:
            liste_m_50.append(numb)
        elif numb < 0 and numb > -50:
            liste_nm_50.append(numb)
        elif numb < -50:
            liste_np_50.append(numb)

    print("Number < 50 and > 0:", len(liste_m_50))
    print("Numbers > 50: ", len(liste_p_50))
    print("Numbers > -50 and < 0: ", len(liste_nm_50))
    print("Numbers < -50: ", len(liste_np_50))
    # print(liste_m_50)
    # print(liste_p_50)
    # print(liste_nm_50)
    # print(liste_np_50)

def biased_random_around_zero(bias=0.0, max_value=100):
    """
    Génère un nombre aléatoire entre -100 et 100.
    
    Paramètres:
    - bias: contrôle la direction du biais
        * bias = 0.0: distribution symétrique autour de 0
        * bias > 0: tendance vers les nombres positifs (plus bias est grand, plus ça tend vers 100)
        * bias < 0: tendance vers les nombres négatifs (plus bias est petit, plus ça tend vers -100)
    
    La distribution favorise les nombres proches de 0 dans tous les cas.
    """
    # Générer un nombre entre 0 et 1
    r = random.random()
    
    # Appliquer une transformation pour favoriser les valeurs proches de 0
    # Utiliser une distribution en forme de cloche
    # value = (2 * r - 1) ** 3  # Cube pour garder le signe mais resserrer vers 0
    
    value = (2 * r - 1) ** 3 # La puissance reserre vers 0 (impair)
    
    # value = (2 * r - 1) ** 3 * (1 - 0.3 * abs((2 * r - 1)))  # Resserre avec un facteur correctif
    
    # value = math.copysign((2 * r - 1)**2 * (2 * r - 1), (2 * r - 1))  # Plus concentré vers 0
    
    # # Transformation qui concentre très fortement vers les extrémités
    # base = 2 * r - 1  # Valeur entre -1 et 1
    # sign = 1 if base >= 0 else -1
    # value = sign * (1 - math.exp(-3 * abs(base)))  # Resserre fortement vers 0
    
    # # Distribution en forme de S très aplatie au centre
    # base = 2 * r - 1
    # value = 2 * (1 / (1 + math.exp(-10 * base)) - 0.5) * (abs(base) ** 2)
    
    # Appliquer le biais (entre -1 et 1)
    biased_value = value + bias * (1 - abs(value)) * 0.1
    
    # Limiter entre -1 et 1
    biased_value = max(-1, min(1, biased_value))
    
    # Transformer en valeur entre -100 et 100
    return int(biased_value * max_value)

# Test avec différents biais
print("Biais négatif (-0.8):")
neg_values = [biased_random_around_zero(-0.5) for _ in range(1000)]
print(f"Moyenne: {sum(neg_values)/len(neg_values):.2f}")
print(f"Négatifs: {len([x for x in neg_values if x < 0])}, Positifs: {len([x for x in neg_values if x > 0])}")
evaluate_numbers(neg_values)

print("\nNeutre (0.0):")
neutral_values = [biased_random_around_zero(0.0) for _ in range(1000)]
print(f"Moyenne: {sum(neutral_values)/len(neutral_values):.2f}")
print(f"Négatifs: {len([x for x in neutral_values if x < 0])}, Positifs: {len([x for x in neutral_values if x > 0])}")
evaluate_numbers(neutral_values)


print("\nBiais positif (0.8):")
pos_values = [biased_random_around_zero(0.8) for _ in range(1000)]
print(f"Moyenne: {sum(pos_values)/len(pos_values):.2f}")
print(f"Négatifs: {len([x for x in pos_values if x < 0])}, Positifs: {len([x for x in pos_values if x > 0])}")
evaluate_numbers(pos_values)

print("\n--- Test de progression graduelle ---")
for bias_level in [-0.8, -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6, 0.8, 1.0, 2, 5, 6, 7, 10, 15, 20, 25, 30, 40, 50]:
    test_values = [biased_random_around_zero(bias_level) for _ in range(1000)]
    pos_gt_50 = len([x for x in test_values if x > 50])
    neg_lt_minus_50 = len([x for x in test_values if x < -50])
    print(f"Biais {bias_level:.1f}: Moyenne: {sum(test_values)/len(test_values):.2f}, >50: {pos_gt_50}, <-50: {neg_lt_minus_50}")

# Test pour visualiser la distribution
print("\nDistribution des valeurs sans biais:")
test_values = [biased_random_around_zero(0.0) for _ in range(10000)]
bins = [-100, -90, -80, -70, -60, -50, -40, -30, -20, -10, 
        0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
counts = [0] * (len(bins) - 1)

for val in test_values:
    for i in range(len(bins) - 1):
        if bins[i] <= val < bins[i+1]:
            counts[i] += 1
            break

for i in range(len(counts)):
    print(f"{bins[i]} to {bins[i+1]}: {'#' * (counts[i] // 50)}")