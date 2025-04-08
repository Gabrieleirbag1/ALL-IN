import random

liste = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]

random_value = random.choice(liste)
print(random_value)

max_value = 10

# if in the 10%: legendary
# if in the 20%: epic
# if in the 30%: rare
# other values: common

def determine_rarity(number, number_list, rarity_thresholds=None):
    """
    Determines the rarity of a number based on its position in the sorted list.
    
    Parameters:
    - number: The number to check
    - number_list: The list of all possible numbers
    - rarity_thresholds: Dictionary with rarity names as keys and percentile thresholds as values
                         (defaults to legendary: 90%, epic: 70%, rare: 40%, common: rest)
    
    Returns:
    - String indicating the rarity level
    """
    if rarity_thresholds is None:
        rarity_thresholds = {
            "legendary": 90,  # Top 10%
            "epic": 70,       # Next 20%
            "rare": 40,       # Next 30%
            "common": 0       # Remaining 40%
        }
    
    # Sort the list if it's not already sorted
    sorted_list = sorted(number_list)
    
    # Calculate the percentile of the number
    if number not in sorted_list:
        return "unknown"
    
    index = sorted_list.index(number)
    # Handle duplicates by finding the last occurrence
    while index < len(sorted_list) - 1 and sorted_list[index + 1] == number:
        index += 1
        
    percentile = (index / (len(sorted_list) - 1)) * 100
    
    # Determine rarity based on percentile
    for rarity, threshold in sorted(rarity_thresholds.items(), key=lambda x: x[1], reverse=True):
        if percentile >= threshold:
            return rarity
    
    return "unknown"

# Example usage
liste = []

for i in range (100):
    liste.append(i)

random_value = random.choice(liste)
print(f"Number: {random_value}")
print(f"Rarity: {determine_rarity(random_value, liste)}")

# Test all values
print("\nRarity distribution:")
for value in sorted(liste):
    rarity = determine_rarity(value, liste)
    print(f"Number {value}: {rarity}")